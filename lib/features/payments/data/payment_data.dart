import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/payment_domain.dart';

class PaymentSettingsModel {
  const PaymentSettingsModel({
    required this.codEnabled,
    required this.methods,
    this.codInstructions,
  });

  final bool codEnabled;
  final String? codInstructions;
  final List<PaymentMethodOption> methods;

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    final rawSettings = json['settings'];
    final settings = rawSettings is Map
        ? Map<String, dynamic>.from(rawSettings)
        : const <String, dynamic>{};
    final rawMethods = json['methods'];

    return PaymentSettingsModel(
      codEnabled: settings['cod_enabled'] != false,
      codInstructions: settings['cod_instructions'] as String?,
      methods: rawMethods is List
          ? rawMethods
              .whereType<Map>()
              .map((entry) => _method(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
    );
  }

  PaymentSettings toEntity() => PaymentSettings(
        codEnabled: codEnabled,
        codInstructions: codInstructions,
        methods: methods,
      );

  static PaymentMethodOption _method(Map<String, dynamic> json) {
    return PaymentMethodOption(
      code: '${json['code'] ?? ''}',
      label: '${json['label'] ?? ''}',
      description: '${json['description'] ?? ''}',
      available: json['available'] == true,
      unavailableReason: json['unavailable_reason'] as String?,
    );
  }
}

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._api);

  final ApiClient _api;

  Future<PaymentSettings> get(int storeId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.storePayments(storeId),
      decode: _asMap,
    );
    return PaymentSettingsModel.fromJson(data).toEntity();
  }

  Future<PaymentSettings> update(
    int storeId,
    PaymentSettingsDraft draft,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.storePayments(storeId),
      body: {
        'cod_enabled': draft.codEnabled,
        'cod_instructions': _clean(draft.codInstructions),
      },
      decode: _asMap,
    );
    return PaymentSettingsModel.fromJson(data).toEntity();
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<PaymentSettings> get(int storeId) => _remote.get(storeId);

  @override
  Future<PaymentSettings> update(int storeId, PaymentSettingsDraft draft) =>
      _remote.update(storeId, draft);
}
