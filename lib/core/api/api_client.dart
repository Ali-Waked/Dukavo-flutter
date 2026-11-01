import 'dart:convert';

import 'package:dio/dio.dart';

import '../storage/app_preferences.dart';
import '../storage/secure_token_store.dart';
import 'api_exception.dart';
import 'cookie_store.dart';
import 'paginated.dart';

typedef JsonMap = Map<String, dynamic>;

/// The single HTTP client for the app.
///
/// Everything about *how* a request is made lives here: the bearer token, the
/// `X-Tenant` header, the interface language, Sanctum's CSRF handshake, the
/// response envelope and the normalised error type. Repositories call typed
/// helpers; widgets never import Dio.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required String csrfUrl,
    required SecureTokenStore tokenStore,
    required AppPreferences preferences,
    Dio? dio,
    CookieStore? cookies,
  })  : _baseUrl = baseUrl,
        _csrfUrl = csrfUrl,
        _tokenStore = tokenStore,
        _preferences = preferences,
        _cookies = cookies ?? CookieStore(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                responseType: ResponseType.json,
                headers: const {
                  'Accept': 'application/json',
                  'X-Requested-With': 'XMLHttpRequest',
                },
              ),
            );

  final String _baseUrl;
  final String _csrfUrl;
  final SecureTokenStore _tokenStore;
  final AppPreferences _preferences;
  final CookieStore _cookies;
  final Dio _dio;

  String? _tenantSlug;
  Future<void>? _csrfInFlight;

  /// Called once when the server rejects an authenticated request with 401.
  void Function()? onUnauthorized;

  String get baseUrl => _baseUrl;
  String? get tenantSlug => _tenantSlug ?? _preferences.tenantSlug;

  void setTenantSlug(String? slug) {
    _tenantSlug = slug;
  }

  /// Fetch a fresh XSRF cookie. Concurrent callers share one request.
  Future<void> primeCsrf() {
    return _csrfInFlight ??= _fetchCsrf().whenComplete(() {
      _csrfInFlight = null;
    });
  }

  Future<void> _fetchCsrf() async {
    try {
      final response = await _dio.get<dynamic>(
        _csrfUrl,
        options: Options(
          validateStatus: (_) => true,
          headers: const {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      _cookies.absorb(response.headers['set-cookie']);
    } catch (_) {
      // A failed prime is not fatal on its own: the following request reports
      // the real problem (usually a 419 or a connection error).
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Object? data)? decode,
  }) async {
    final body = await _send('GET', path, query: query);
    return _decode<T>(body, decode);
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool csrf = false,
    T Function(Object? data)? decode,
  }) async {
    final envelope = await _send(
      'POST',
      path,
      body: body,
      query: query,
      headers: headers,
      csrf: csrf,
    );
    return _decode<T>(envelope, decode);
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool csrf = false,
    T Function(Object? data)? decode,
  }) async {
    final envelope =
        await _send('PATCH', path, body: body, headers: headers, csrf: csrf);
    return _decode<T>(envelope, decode);
  }

  Future<T> put<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool csrf = false,
    T Function(Object? data)? decode,
  }) async {
    final envelope =
        await _send('PUT', path, body: body, headers: headers, csrf: csrf);
    return _decode<T>(envelope, decode);
  }

  Future<void> postVoid(
    String path, {
    Object? body,
    bool csrf = false,
  }) async {
    await _send('POST', path, body: body, csrf: csrf);
  }

  Future<void> putVoid(
    String path, {
    Object? body,
    bool csrf = false,
  }) async {
    await _send('PUT', path, body: body, csrf: csrf);
  }

  Future<void> delete(
    String path, {
    Map<String, dynamic>? query,
    bool csrf = false,
  }) async {
    await _send('DELETE', path, query: query, csrf: csrf);
  }

  /// A delete that returns the resource the server sent back.
  Future<T> deleteJson<T>(
    String path, {
    Map<String, dynamic>? query,
    bool csrf = false,
    T Function(Object? data)? decode,
  }) async {
    final envelope = await _send('DELETE', path, query: query, csrf: csrf);
    return _decode<T>(envelope, decode);
  }

  Future<Paginated<T>> list<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(JsonMap json) item,
  }) async {
    final envelope = await _send('GET', path, query: query);
    final rawItems = envelope['data'];
    final items = <T>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map) {
          items.add(item(Map<String, dynamic>.from(raw)));
        }
      }
    }
    final rawMeta = envelope['meta'];
    final meta = rawMeta is Map
        ? PaginationMeta.fromJson(Map<String, dynamic>.from(rawMeta))
        : PaginationMeta.single(items.length);
    return Paginated<T>(items: items, meta: meta);
  }

  /// Fetch raw bytes from an authenticated route (conversation attachments).
  Future<List<int>> download(String path) async {
    final envelope = await _send(
      'GET',
      path,
      responseType: ResponseType.bytes,
    );
    final data = envelope['data'];
    if (data is List<int>) return data;
    if (data is List) return data.cast<int>();
    return const <int>[];
  }

  T _decode<T>(JsonMap envelope, T Function(Object? data)? decode) {
    final data = envelope['data'];
    if (decode != null) return decode(data);
    if (data is T) return data;
    if (data == null) return null as T;
    throw ApiException(
      'The server returned an unexpected response.',
      statusCode: 0,
    );
  }

  Future<JsonMap> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool csrf = false,
    ResponseType responseType = ResponseType.json,
    bool retryOnCsrfFailure = true,
  }) async {
    if (csrf) {
      await primeCsrf();
    }

    final requestHeaders = <String, dynamic>{
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Accept-Language': _preferences.locale?.languageCode ?? 'en',
    };

    final token = _tokenStore.token;
    if (token != null && token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    final slug = tenantSlug;
    if (slug != null && slug.isNotEmpty) {
      requestHeaders['X-Tenant'] = slug;
    }

    if (csrf) {
      final xsrf = _cookies.decodedXsrfToken;
      if (xsrf != null) requestHeaders['X-XSRF-TOKEN'] = xsrf;
      if (!_cookies.isEmpty) requestHeaders['Cookie'] = _cookies.cookieHeader;
    }

    if (headers != null) requestHeaders.addAll(headers);

    final options = Options(
      method: method,
      headers: requestHeaders,
      contentType: body is FormData ? null : Headers.jsonContentType,
      responseType: responseType,
      validateStatus: (status) => status != null && status < 500,
    );

    try {
      final response = await _dio.request<dynamic>(
        '$_baseUrl$path',
        data: body,
        queryParameters: query,
        options: options,
      );

      _cookies.absorb(response.headers['set-cookie']);

      final status = response.statusCode ?? 0;

      if (status == 419 && csrf && retryOnCsrfFailure) {
        _csrfInFlight = null;
        await primeCsrf();
        return await _send(
          method,
          path,
          body: body,
          query: query,
          headers: headers,
          csrf: csrf,
          responseType: responseType,
          retryOnCsrfFailure: false,
        );
      }

      if (status == 401) {
        if (token != null && token.isNotEmpty) {
          onUnauthorized?.call();
        }
        throw _errorFromResponse(response);
      }

      if (status >= 400) {
        throw _errorFromResponse(response);
      }

      if (responseType == ResponseType.bytes) {
        return <String, dynamic>{'data': response.data};
      }

      return _envelope(response.data);
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        throw _errorFromResponse(response);
      }
      throw ApiException(
        "We couldn't reach the server. Check your connection and try again.",
        isNetworkError: true,
      );
    }
  }

  JsonMap _envelope(Object? raw) {
    if (raw == null) return <String, dynamic>{};
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw ApiException(
      'The server returned an unexpected response.',
      statusCode: 0,
    );
  }

  ApiException _errorFromResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final raw = response.data;
    Map<String, dynamic>? envelope;
    if (raw is Map) {
      envelope = Map<String, dynamic>.from(raw);
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) envelope = Map<String, dynamic>.from(decoded);
      } on FormatException {
        envelope = null;
      }
    }

    final message = (envelope?['message'] as String?)?.trim();
    final rawErrors = envelope?['errors'];
    Map<String, List<String>>? fields;
    if (rawErrors is Map) {
      fields = <String, List<String>>{};
      rawErrors.forEach((key, value) {
        if (value is List) {
          fields!['$key'] = value.map((entry) => '$entry').toList();
        } else if (value != null) {
          fields!['$key'] = <String>['$value'];
        }
      });
    }

    return ApiException(
      message == null || message.isEmpty ? _fallbackMessage(status) : message,
      statusCode: status,
      fields: fields,
      code: envelope?['code'] as String?,
    );
  }

  String _fallbackMessage(int status) {
    switch (status) {
      case 400:
        return 'The request could not be completed.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return "You don't have permission to perform this action.";
      case 404:
        return "We couldn't find what you were looking for.";
      case 409:
        return 'This change conflicts with the current state.';
      case 419:
        return 'Your session expired. Please try again.';
      case 422:
        return 'Some of the details need attention.';
      case 429:
        return 'Too many requests. Please slow down and try again shortly.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
