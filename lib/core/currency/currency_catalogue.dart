import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_paths.dart';
import '../providers.dart';

/// One ISO 4217 currency, localised by the server.
///
/// The backend owns the catalogue: it knows which codes exist, their official
/// minor-unit precision and their Arabic/English names and symbols. The client
/// only searches and renders what it was given, so a currency can never be
/// invented on the device.
class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.nameEn = '',
    this.nameAr = '',
    this.symbolEn = '',
    this.symbolAr = '',
  });

  final String code;
  final String name;
  final String symbol;
  final int decimals;
  final String nameEn;
  final String nameAr;
  final String symbolEn;
  final String symbolAr;

  static CurrencyOption fromJson(Map<String, dynamic> json) {
    final code = '${json['code'] ?? ''}'.toUpperCase();
    final name = '${json['name'] ?? code}';

    return CurrencyOption(
      code: code,
      name: name.isEmpty ? code : name,
      symbol: '${json['symbol'] ?? code}',
      decimals: _int(json['decimals'], fallback: 2),
      nameEn: '${json['name_en'] ?? name}',
      nameAr: '${json['name_ar'] ?? name}',
      symbolEn: '${json['symbol_en'] ?? json['symbol'] ?? code}',
      symbolAr: '${json['symbol_ar'] ?? json['symbol'] ?? code}',
    );
  }

  /// The line shown in a picker and a read-only summary.
  String get label => name.isEmpty || name == code ? code : '$code · $name';

  /// Search across code, both names and both symbols.
  ///
  /// Arabic users may type the Arabic name while the interface is in English
  /// (or vice versa), so every available spelling is searched rather than only
  /// the currently displayed one.
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      code,
      name,
      nameEn,
      nameAr,
      symbol,
      symbolEn,
      symbolAr,
    ].any((value) => value.toLowerCase().contains(needle));
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}

/// The server's currency payload: default code, resolved locale and options.
class CurrencyCatalogue {
  const CurrencyCatalogue({
    required this.defaultCode,
    required this.locale,
    required this.currencies,
  });

  final String defaultCode;
  final String locale;
  final List<CurrencyOption> currencies;

  static CurrencyCatalogue fromJson(Map<String, dynamic> json) {
    final raw = json['currencies'];
    final currencies = raw is List
        ? raw
            .whereType<Map>()
            .map((entry) =>
                CurrencyOption.fromJson(Map<String, dynamic>.from(entry)))
            .where((currency) => currency.code.isNotEmpty)
            .toList()
        : <CurrencyOption>[];

    return CurrencyCatalogue(
      defaultCode: '${json['default'] ?? 'USD'}'.toUpperCase(),
      locale: '${json['locale'] ?? 'en'}',
      currencies: currencies,
    );
  }

  CurrencyOption? find(String? code) {
    final wanted = (code ?? '').toUpperCase();
    for (final currency in currencies) {
      if (currency.code == wanted) return currency;
    }
    return null;
  }
}

class CurrencyCatalogueRemoteDataSource {
  CurrencyCatalogueRemoteDataSource(this._api);

  final ApiClient _api;

  Future<CurrencyCatalogue> fetch() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.currencyCatalogue,
      decode: _asMap,
    );
    return CurrencyCatalogue.fromJson(data);
  }

  static Map<String, dynamic> _asMap(Object? data) {
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }
}

class CurrencyCatalogueRepository {
  CurrencyCatalogueRepository(this._remote);

  final CurrencyCatalogueRemoteDataSource _remote;

  Future<CurrencyCatalogue> fetch() => _remote.fetch();
}

final currencyCatalogueRepositoryProvider =
    Provider<CurrencyCatalogueRepository>((ref) {
  return CurrencyCatalogueRepository(
    CurrencyCatalogueRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// Currency metadata for personal surfaces (profile, platform screens).
///
/// This endpoint is deliberately outside the tenant group, so a person can
/// choose a display currency before entering a workspace.
final currencyCatalogueProvider = FutureProvider<CurrencyCatalogue>((ref) {
  return ref.watch(currencyCatalogueRepositoryProvider).fetch();
});
