import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/profile_domain.dart';
import '../application/settings_controller.dart';
import '../domain/settings_domain.dart';

const _currencies = <String>[
  'USD',
  'EUR',
  'GBP',
  'AED',
  'SAR',
  'EGP',
  'NGN',
  'KES',
  'ZAR',
  'INR',
];

const _timezones = <String>[
  'UTC',
  'Africa/Cairo',
  'Africa/Lagos',
  'Africa/Nairobi',
  'Africa/Johannesburg',
  'Asia/Dubai',
  'Asia/Riyadh',
  'Europe/London',
  'America/New_York',
];

const _notificationEvents = <String>[
  'order_updates',
  'low_stock',
  'new_messages',
  'conversation_assignments',
  'delivery_failures',
  'approvals',
  'weekly_summary',
  'product_news',
];

String _eventLabel(BuildContext context, String event) {
  switch (event) {
    case 'order_updates':
      return context.tr('orderUpdates');
    case 'low_stock':
      return context.tr('lowStock');
    case 'new_messages':
      return context.tr('newMessages');
    case 'conversation_assignments':
      return context.tr('conversationAssignments');
    case 'delivery_failures':
      return context.tr('deliveryFailures');
    case 'approvals':
      return context.tr('approvals');
    case 'weekly_summary':
      return context.tr('weeklySummary');
    case 'product_news':
      return context.tr('productNews');
    default:
      return event.replaceAll('_', ' ');
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _AppearanceCard(),
          const SizedBox(height: 12),
          const _LanguageCard(),
          const SizedBox(height: 12),
          if (permissions.canViewSettings) ...[
            const _WorkspaceCard(),
            const SizedBox(height: 12),
          ],
          const _NotificationsCard(),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('account'),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(context.tr('profile')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.profile),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout),
                  title: Text(context.tr('logout')),
                  onTap: () => _signOut(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${context.tr('appName')} ${context.tr('version')}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('logout'),
      message: context.tr('signOutMessage'),
      confirmLabel: context.tr('logout'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);

    return SectionCard(
      title: context.tr('theme'),
      child: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(
            value: ThemeMode.system,
            label: Text(context.tr('system')),
            icon: const Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            label: Text(context.tr('light')),
            icon: const Icon(Icons.light_mode_outlined, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text(context.tr('dark')),
            icon: const Icon(Icons.dark_mode_outlined, size: 18),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) =>
            ref.read(themeControllerProvider.notifier).setMode(selection.first),
      ),
    );
  }
}

class _LanguageCard extends ConsumerWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final code = locale?.languageCode ?? 'system';

    return SectionCard(
      title: context.tr('language'),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'system',
            label: Text(context.tr('system')),
          ),
          ButtonSegment(
            value: 'en',
            label: Text(context.tr('english')),
          ),
          ButtonSegment(
            value: 'ar',
            label: Text(context.tr('arabic')),
          ),
        ],
        selected: {code},
        onSelectionChanged: (selection) => ref
            .read(localeControllerProvider.notifier)
            .setLocale(
                selection.first == 'system' ? null : Locale(selection.first)),
      ),
    );
  }
}

class _WorkspaceCard extends ConsumerWidget {
  const _WorkspaceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(workspaceSettingsProvider);
    final permissions = ref.watch(permissionsProvider);

    return settings.when(
      loading: () => const SectionCard(
        title: '',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: LoadingView(),
        ),
      ),
      error: (error, stack) => SectionCard(
        title: context.tr('workspaceSettings'),
        child: ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(workspaceSettingsProvider),
        ),
      ),
      data: (data) => _WorkspaceForm(
        settings: data,
        canManage: permissions.canManageSettings,
      ),
    );
  }
}

class _WorkspaceForm extends ConsumerStatefulWidget {
  const _WorkspaceForm({required this.settings, required this.canManage});

  final WorkspaceSettings settings;
  final bool canManage;

  @override
  ConsumerState<_WorkspaceForm> createState() => _WorkspaceFormState();
}

class _WorkspaceFormState extends ConsumerState<_WorkspaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.settings.name);
  late final TextEditingController _email =
      TextEditingController(text: widget.settings.contactEmail ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.settings.phone ?? '');
  late String _currency = widget.settings.currency;
  late String _timezone = widget.settings.timezone;
  late String _locale = widget.settings.locale ?? 'en';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.tr('workspaceSettings'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _name,
              label: context.tr('workspaceName'),
              enabled: widget.canManage,
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.tr('requiredField')
                  : null,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _email,
              label: context.tr('contactEmail'),
              enabled: widget.canManage,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _phone,
              label: context.tr('phone'),
              enabled: widget.canManage,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _currency,
              decoration: InputDecoration(labelText: context.tr('currency')),
              items: [
                for (final currency in _currencies)
                  DropdownMenuItem(value: currency, child: Text(currency)),
              ],
              onChanged: widget.canManage
                  ? (value) => setState(() => _currency = value ?? _currency)
                  : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _timezone,
              decoration: InputDecoration(labelText: context.tr('timezone')),
              items: [
                for (final timezone in _timezones)
                  DropdownMenuItem(value: timezone, child: Text(timezone)),
              ],
              onChanged: widget.canManage
                  ? (value) => setState(() => _timezone = value ?? _timezone)
                  : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _locale,
              decoration: InputDecoration(labelText: context.tr('locale')),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(context.tr('english')),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text(context.tr('arabic')),
                ),
              ],
              onChanged: widget.canManage
                  ? (value) => setState(() => _locale = value ?? _locale)
                  : null,
            ),
            if (widget.canManage) ...[
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('saveChanges'),
                expand: true,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(settingsActionsProvider).update(
            WorkspaceSettingsDraft(
              name: _name.text.trim(),
              contactEmail: _email.text.trim(),
              phone: _phone.text.trim(),
              currency: _currency,
              timezone: _timezone,
              locale: _locale,
            ),
          );
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, context.tr('settingsUpdated'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _NotificationsCard extends ConsumerWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    final channels = ref.watch(notificationChannelsProvider);

    return preferences.when(
      loading: () => const SectionCard(
        title: '',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: LoadingView(),
        ),
      ),
      error: (error, stack) => SectionCard(
        title: context.tr('notificationPreferences'),
        child: ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
      ),
      data: (data) => _NotificationSwitches(
        preferences: data,
        channels:
            channels.valueOrNull ?? const <String, NotificationChannelState>{},
      ),
    );
  }
}

class _NotificationSwitches extends ConsumerStatefulWidget {
  const _NotificationSwitches({
    required this.preferences,
    required this.channels,
  });

  final NotificationPreferences preferences;
  final Map<String, NotificationChannelState> channels;

  @override
  ConsumerState<_NotificationSwitches> createState() =>
      _NotificationSwitchesState();
}

class _NotificationSwitchesState extends ConsumerState<_NotificationSwitches> {
  late NotificationPreferences _draft = widget.preferences;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.tr('notificationPreferences'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChannelGroup(
            channel: 'email',
            title: context.tr('emailNotifications'),
            state: widget.channels['email'],
            preferences: _draft,
            events: _notificationEvents,
            onChanged: (event, value) => setState(
              () => _draft = _draft.copyWithEvent('email', event, value),
            ),
          ),
          const SizedBox(height: 8),
          _ChannelGroup(
            channel: 'whatsapp',
            title: context.tr('whatsappNotifications'),
            state: widget.channels['whatsapp'],
            preferences: _draft,
            events: const [
              'order_updates',
              'low_stock',
              'new_messages',
              'conversation_assignments',
              'delivery_failures',
            ],
            onChanged: (event, value) => setState(
              () => _draft = _draft.copyWithEvent('whatsapp', event, value),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: context.tr('savePreferences'),
            expand: true,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(profileActionsProvider)
          .saveNotificationPreferences(_draft);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, context.tr('preferencesUpdated'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _ChannelGroup extends StatelessWidget {
  const _ChannelGroup({
    required this.channel,
    required this.title,
    required this.state,
    required this.preferences,
    required this.events,
    required this.onChanged,
  });

  final String channel;
  final String title;
  final NotificationChannelState? state;
  final NotificationPreferences preferences;
  final List<String> events;
  final void Function(String event, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = state?.available ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (!available)
              Tooltip(
                message: state?.reason ?? context.tr('channelUnavailable'),
                child: Text(
                  context.tr('channelUnavailable'),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
        for (final event in events)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_eventLabel(context, event)),
            value: preferences.isEnabled(channel, event),
            onChanged: available ? (value) => onChanged(event, value) : null,
          ),
      ],
    );
  }
}
