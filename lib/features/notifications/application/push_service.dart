import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/storage/app_preferences.dart';
import 'notification_controller.dart';

/// Push is optional: an installation without Firebase credentials still runs,
/// it simply reports [PushAvailability.unconfigured] and keeps using the in-app
/// centre.
enum PushAvailability { unconfigured, denied, ready, failed }

/// Android notification channels the backend addresses by category.
///
/// A channel is created once per installation; changing its importance later
/// does not override the user's own choice, which is why the ids are stable.
class PushChannel {
  const PushChannel(this.id, this.name, this.description, this.importance);

  final String id;
  final String name;
  final String description;
  final Importance importance;
}

const _channels = <PushChannel>[
  PushChannel('orders', 'Orders',
      'New orders, cancellations and delivery updates', Importance.high),
  PushChannel('inventory', 'Inventory', 'Low stock and stock adjustments',
      Importance.defaultImportance),
  PushChannel('messages', 'Messages', 'Customer and WhatsApp messages',
      Importance.high),
  PushChannel('ai', 'AI insights', 'AI recommendations and approvals',
      Importance.defaultImportance),
  PushChannel('security', 'Security',
      'Sign-ins, password changes and account alerts', Importance.max),
  PushChannel('reports', 'Reports', 'Weekly and monthly business summaries',
      Importance.defaultImportance),
  PushChannel('announcements', 'Announcements',
      'Dukavo news and platform notices', Importance.defaultImportance),
];

/// Firebase Cloud Messaging plus local notification presentation.
///
/// FCM transports a short alert; Laravel remains the source of truth. The
/// payload therefore contains only ids and an action path, and tapping fetches
/// or opens Laravel's own history rather than rendering the push body as a
/// record.
///
/// Initialisation is deliberately best-effort. Missing build-time credentials,
/// a denied permission or a platform without local notifications must never
/// stop the merchant from using the rest of the app.
class PushService {
  PushService(this._api, this._preferences, {this.onForeground});

  final ApiClient _api;
  final AppPreferences _preferences;

  /// Called after a foreground push so the bell can refresh its count.
  final Future<void> Function()? onForeground;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _taps = StreamController<String>.broadcast();
  final Set<String> _seen = <String>{};

  Future<void>? _initialising;
  bool _ready = false;
  String? _token;
  StreamSubscription<String>? _tokenRefresh;
  StreamSubscription<RemoteMessage>? _foregroundMessages;
  StreamSubscription<RemoteMessage>? _openedMessages;

  PushAvailability availability = PushAvailability.unconfigured;

  /// Deep links emitted when a notification is tapped.
  Stream<String> get taps => _taps.stream;

  bool get isReady => _ready;

  /// Initialise Firebase once, after the first frame.
  Future<void> initialize() {
    return _initialising ??= _initialize();
  }

  Future<void> _initialize() async {
    if (kIsWeb || !AppConfig.firebaseConfigured) {
      availability = PushAvailability.unconfigured;
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: AppConfig.firebaseApiKey,
            appId: AppConfig.firebaseAppId,
            messagingSenderId: AppConfig.firebaseMessagingSenderId,
            projectId: AppConfig.firebaseProjectId,
            storageBucket: AppConfig.firebaseStorageBucket.isEmpty
                ? null
                : AppConfig.firebaseStorageBucket,
            iosBundleId: defaultTargetPlatform == TargetPlatform.iOS
                ? AppConfig.firebaseIosBundleId
                : null,
          ),
        );
      }

      await _prepareLocalNotifications();

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        availability = PushAvailability.denied;
        return;
      }

      _foregroundMessages = FirebaseMessaging.onMessage.listen(
        (message) => unawaited(_showForeground(message)),
      );
      _openedMessages = FirebaseMessaging.onMessageOpenedApp.listen(_open);
      // `getToken`/`onTokenRefresh` still return the FCM registration token
      // Laravel pushes to. The newer `onRegistered` stream carries a Firebase
      // Installation ID, which the HTTP v1 `token` field does not accept.
      // ignore: deprecated_member_use
      _tokenRefresh = messaging.onTokenRefresh.listen((token) {
        unawaited(_register(token));
      });

      // A notification that launched a terminated app. Reading it here means
      // the merchant lands on the relevant screen instead of the dashboard.
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        // Give the router one frame to attach before navigating.
        scheduleMicrotask(() => _open(initial));
      }

      availability = PushAvailability.ready;
      _ready = true;
    } catch (error, stack) {
      availability = PushAvailability.failed;
      debugPrint('Push initialisation failed: $error\n$stack');
    }
  }

  /// Register the current token after login or a tenant switch.
  ///
  /// Registration is idempotent on the server: the same installation replaces
  /// its previous row, and a rotated token revokes the old one.
  Future<void> syncDeviceToken() async {
    await initialize();

    if (!_ready) return;

    try {
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await _register(token);
    } catch (error) {
      debugPrint('Push token lookup failed: $error');
    }
  }

  /// Revoke this installation's token before logout clears the bearer token.
  Future<void> unregisterToken() async {
    final token = _token;
    _token = null;

    if (token == null || token.isEmpty) return;

    try {
      await _api.postVoid(
        ApiPaths.profileDevicesUnregister,
        body: {'token': token},
      );
    } catch (_) {
      // Logout must succeed even when the network is down. The token is
      // deleted from the device by Firebase, and the backend expiry sweep
      // eventually retires the row.
    }
  }

  Future<void> _register(String token) async {
    if (token.isEmpty || !_ready) return;

    final previous = _token;
    if (previous == token) return;

    _token = token;

    try {
      await _api.post<Map<String, dynamic>>(
        ApiPaths.profileDevices,
        body: {
          'token': token,
          'platform': _platformName,
          'device_id': await _installationId(),
          'device_name': _deviceName,
          'app_version': AppConfig.appVersion,
          'locale': PlatformDispatcher.instance.locale.languageCode == 'ar'
              ? 'ar'
              : 'en',
        },
        decode: (raw) => raw is Map
            ? Map<String, dynamic>.from(raw)
            : const <String, dynamic>{},
      );
    } catch (error) {
      // Keep the token so a later foreground retry can register it.
      _token = previous;
      debugPrint('Push token registration failed: $error');
    }
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'unknown',
    };
  }

  String get _deviceName {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android device',
      TargetPlatform.iOS => 'iPhone or iPad',
      _ => 'Dukavo device',
    };
  }

  /// A stable per-installation id without adding another plugin.
  ///
  /// Firebase tokens rotate; the device id lets the backend revoke the previous
  /// token for the same phone instead of leaving two rows that both alert.
  Future<String> _installationId() async {
    final stored = _preferences.pushInstallationId;
    if (stored != null && stored.isNotEmpty) return stored;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id =
        bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();

    await _preferences.setPushInstallationId(id);

    return id;
  }

  Future<void> _prepareLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _taps.add(payload);
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      for (final channel in _channels) {
        await android?.createNotificationChannel(
          AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: channel.importance,
          ),
        );
      }
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    if (!_ready) return;

    final data = message.data;
    final notificationId =
        '${data['notification_id'] ?? message.messageId ?? ''}';
    final dedupe = notificationId.isEmpty ? message.messageId : notificationId;

    if (dedupe != null && dedupe.isNotEmpty) {
      if (_seen.contains(dedupe)) return;
      _seen.add(dedupe);
      if (_seen.length > 100) {
        _seen.remove(_seen.first);
      }
    }

    final title = message.notification?.title ?? '${data['title'] ?? 'Dukavo'}';
    final body = message.notification?.body ?? '${data['body'] ?? ''}';
    final category = '${data['category'] ?? 'announcements'}';
    final path = resolveNotificationPath(
      data['action_url']?.toString(),
      notificationId: notificationId.isEmpty ? null : notificationId,
    );

    final channel = _channelFor(category);

    await _local.show(
      id: _notificationKey(notificationId),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: _priorityFor(category),
          icon: '@mipmap/ic_launcher',
          onlyAlertOnce: true,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: path,
    );

    if (notificationId.isNotEmpty) {
      // Opening the notification in the centre must show the read state the
      // merchant expects, but a foreground alert is not an automatic read.
      unawaited(onForeground?.call() ?? Future<void>.value());
    }
  }

  void _open(RemoteMessage message) {
    final data = message.data;
    final path = resolveNotificationPath(
      data['action_url']?.toString(),
      notificationId: data['notification_id']?.toString(),
    );

    final id = data['notification_id']?.toString();
    if (id != null && id.isNotEmpty) {
      unawaited(_markRead(id));
    }

    _taps.add(path);
  }

  Future<void> _markRead(String id) async {
    try {
      await _api.postVoid('${ApiPaths.notifications}/$id/read');
      await onForeground?.call();
    } catch (_) {
      // The detail screen will mark it read when it opens.
    }
  }

  PushChannel _channelFor(String category) {
    final normalized = switch (category) {
      'order' || 'orders' => 'orders',
      'inventory' || 'stock' => 'inventory',
      'message' || 'messages' || 'conversations' => 'messages',
      'ai' || 'ai_actions' || 'approvals' || 'automation' => 'ai',
      'security' || 'team' => 'security',
      'reports' || 'weekly_summary' => 'reports',
      _ => 'announcements',
    };

    return _channels.firstWhere((channel) => channel.id == normalized);
  }

  Priority _priorityFor(String category) {
    return switch (category) {
      'security' || 'orders' || 'messages' => Priority.high,
      _ => Priority.defaultPriority,
    };
  }

  int _notificationKey(String id) {
    if (id.isEmpty) {
      return DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    }

    return id.hashCode & 0x7fffffff;
  }

  void dispose() {
    _tokenRefresh?.cancel();
    _foregroundMessages?.cancel();
    _openedMessages?.cancel();
    _taps.close();
  }
}

/// Turn a server action URL into a path the mobile router owns.
///
/// Only same-origin Dukavo links and in-app absolute paths are allowed. A
/// payload cannot smuggle in `javascript:`, an arbitrary external host or a
/// protocol-relative URL, and an empty action falls back to the notification
/// detail screen rather than the dashboard.
String resolveNotificationPath(String? actionUrl, {String? notificationId}) {
  final fallback = notificationId == null || notificationId.isEmpty
      ? '/notifications'
      : '/notifications/${Uri.encodeComponent(notificationId)}';

  final raw = actionUrl?.trim();
  if (raw == null || raw.isEmpty) return fallback;

  final uri = Uri.tryParse(raw);
  if (uri == null) return fallback;

  if (uri.hasScheme) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return fallback;
    if (uri.userInfo.isNotEmpty) return fallback;

    final webHost = Uri.tryParse(AppConfig.webBaseUrl)?.host;
    if (webHost == null || webHost.isEmpty || uri.host != webHost) {
      return fallback;
    }

    return _pathWithQuery(uri.path, uri.query) ?? fallback;
  }

  // `//host` is a protocol-relative external URL dressed as a path. Dart
  // parses it with an authority even though it has no scheme.
  if (uri.hasAuthority || uri.path.startsWith('//')) return fallback;

  return _pathWithQuery(uri.path, uri.query) ?? fallback;
}

String? _pathWithQuery(String path, String query) {
  final clean = path.trim();
  if (clean.isEmpty) return null;
  final absolute = clean.startsWith('/') ? clean : '/$clean';
  return query.isEmpty ? absolute : '$absolute?$query';
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(
    ref.watch(apiClientProvider),
    ref.watch(appPreferencesProvider),
    onForeground: () => ref.read(notificationUnreadProvider.notifier).refresh(),
  );

  ref.onDispose(service.dispose);

  return service;
});
