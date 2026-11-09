import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukavo_mobile/core/api/api_client.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:dukavo_mobile/core/offline/memory_cache_store.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/core/storage/secure_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A Dio adapter that answers from a closure, so offline and cache behaviour can
/// be tested without a socket.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  Future<ResponseBody> Function(RequestOptions options) handler;

  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls += 1;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

DioException networkFailure(RequestOptions options) {
  return DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
    message: 'offline',
  );
}

class FakeTokenStore extends SecureTokenStore {
  FakeTokenStore([this._token]);

  String? _token;

  @override
  String? get token => _token;

  @override
  Future<void> init() async {}

  @override
  Future<void> save(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}

Future<AppPreferences> testPreferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return AppPreferences(await SharedPreferences.getInstance());
}

Future<ApiClient> buildTestApi({
  required FakeHttpAdapter adapter,
  required CacheManager cache,
  ConnectivityController? connectivity,
  SecureTokenStore? tokens,
  AppPreferences? preferences,
}) async {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'https://example.test/api/v1',
    csrfUrl: 'https://example.test/sanctum/csrf-cookie',
    tokenStore: tokens ?? FakeTokenStore(),
    preferences: preferences ?? await testPreferences(),
    cache: cache,
    connectivity: connectivity ?? ConnectivityController(),
    dio: dio,
  );
}

MemoryCacheStore memoryStore() => MemoryCacheStore();
