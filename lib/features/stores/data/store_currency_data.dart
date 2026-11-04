import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/store_currency_domain.dart';

class StoreCurrencyRemoteDataSource {
  StoreCurrencyRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<CurrencyOption>> options() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.currencies,
      decode: _asMap,
    );
    final raw = data['currencies'];
    return raw is List
        ? raw
            .whereType<Map>()
            .map((entry) =>
                CurrencyOption.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const [];
  }

  Future<StoreCurrencyState> show(int storeId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.storeCurrency(storeId),
      decode: _asMap,
    );
    return StoreCurrencyState.fromJson(data);
  }

  Future<CurrencyPreview> preview(int storeId, String currency) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.storeCurrencyPreview(storeId),
      query: {'currency': currency},
      decode: _asMap,
    );
    return CurrencyPreview.fromJson(data);
  }

  Future<CurrencyConversion> convert(
    int storeId,
    String currency,
    String idempotencyKey,
  ) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.storeCurrency(storeId),
      body: {
        'currency': currency,
        'idempotency_key': idempotencyKey,
        'confirm': true,
      },
      decode: _asMap,
    );
    final raw = data['conversion'];
    return CurrencyConversion.fromJson(
      raw is Map ? Map<String, dynamic>.from(raw) : const {},
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }
}

abstract class StoreCurrencyRepository {
  Future<List<CurrencyOption>> options();

  Future<StoreCurrencyState> show(int storeId);

  Future<CurrencyPreview> preview(int storeId, String currency);

  Future<CurrencyConversion> convert(
    int storeId,
    String currency,
    String idempotencyKey,
  );
}

class StoreCurrencyRepositoryImpl implements StoreCurrencyRepository {
  StoreCurrencyRepositoryImpl(this._remote);

  final StoreCurrencyRemoteDataSource _remote;

  @override
  Future<List<CurrencyOption>> options() => _remote.options();

  @override
  Future<StoreCurrencyState> show(int storeId) => _remote.show(storeId);

  @override
  Future<CurrencyPreview> preview(int storeId, String currency) =>
      _remote.preview(storeId, currency);

  @override
  Future<CurrencyConversion> convert(
    int storeId,
    String currency,
    String idempotencyKey,
  ) =>
      _remote.convert(storeId, currency, idempotencyKey);
}
