import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/translation_domain.dart';

/// The review ledger, reached through one generic route per surface.
///
/// Every call carries the surface explicitly so merchant content can never be
/// resolved through the platform half (or the reverse). The server does the
/// real guard; this is only the transport.
class TranslationRemoteDataSource {
  TranslationRemoteDataSource(this._api);

  final ApiClient _api;

  Future<TranslationOverview> overview({
    required String surface,
    required String entity,
    required int recordId,
    String? sourceLocale,
  }) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.translationOverview(surface, entity, recordId),
      query: sourceLocale == null || sourceLocale.isEmpty
          ? null
          : {'source_locale': sourceLocale},
      decode: _asMap,
    );

    return TranslationOverview.fromJson(data);
  }

  Future<TranslationUsage> usage(String surface) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.translationUsage(surface),
      decode: _asMap,
    );

    return TranslationUsage.fromJson(data);
  }

  Future<GenerateTranslationsResult> generate({
    required String surface,
    required String entity,
    required int recordId,
    required List<String> fields,
    required List<String> targetLocales,
    String? sourceLocale,
    bool confirmOverwrite = false,
  }) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.translationGenerate(surface, entity, recordId),
      body: {
        'fields': fields,
        'target_locales': targetLocales,
        if (sourceLocale != null && sourceLocale.isNotEmpty)
          'source_locale': sourceLocale,
        'confirm_overwrite': confirmOverwrite,
      },
      decode: _asMap,
    );

    return GenerateTranslationsResult.fromJson(data);
  }

  Future<TranslationRow> update({
    required String surface,
    required int id,
    required String translatedText,
  }) async {
    final data = await _api.patch<JsonMap>(
      ApiPaths.translation(surface, id),
      body: {'translated_text': translatedText},
      decode: _asMap,
    );

    return TranslationRow.fromJson(data);
  }

  Future<TranslationRow> approve({
    required String surface,
    required int id,
  }) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.translationApprove(surface, id),
      decode: _asMap,
    );

    return TranslationRow.fromJson(data);
  }

  Future<TranslationRow> reject({
    required String surface,
    required int id,
    String? reason,
  }) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.translationReject(surface, id),
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      decode: _asMap,
    );

    return TranslationRow.fromJson(data);
  }

  Future<GenerateTranslationsResult> regenerate({
    required String surface,
    required int id,
    bool confirmOverwrite = false,
  }) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.translationRegenerate(surface, id),
      body: {'confirm_overwrite': confirmOverwrite},
      decode: _asMap,
    );

    return GenerateTranslationsResult.fromJson(data);
  }

  Future<List<TranslationRow>> approveMany({
    required String surface,
    required String entity,
    required int recordId,
    required List<int> ids,
  }) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.translationApproveAll(surface, entity, recordId),
      body: {'ids': ids},
      decode: _asMap,
    );
    final raw = data['approved'];

    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((entry) => TranslationRow.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();
  }
}

abstract class TranslationRepository {
  Future<TranslationOverview> overview({
    required String surface,
    required String entity,
    required int recordId,
    String? sourceLocale,
  });

  Future<TranslationUsage> usage(String surface);

  Future<GenerateTranslationsResult> generate({
    required String surface,
    required String entity,
    required int recordId,
    required List<String> fields,
    required List<String> targetLocales,
    String? sourceLocale,
    bool confirmOverwrite = false,
  });

  Future<TranslationRow> update({
    required String surface,
    required int id,
    required String translatedText,
  });

  Future<TranslationRow> approve({
    required String surface,
    required int id,
  });

  Future<TranslationRow> reject({
    required String surface,
    required int id,
    String? reason,
  });

  Future<GenerateTranslationsResult> regenerate({
    required String surface,
    required int id,
    bool confirmOverwrite = false,
  });

  Future<List<TranslationRow>> approveMany({
    required String surface,
    required String entity,
    required int recordId,
    required List<int> ids,
  });
}

class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl(this._remote);

  final TranslationRemoteDataSource _remote;

  @override
  Future<TranslationOverview> overview({
    required String surface,
    required String entity,
    required int recordId,
    String? sourceLocale,
  }) {
    return _remote.overview(
      surface: surface,
      entity: entity,
      recordId: recordId,
      sourceLocale: sourceLocale,
    );
  }

  @override
  Future<TranslationUsage> usage(String surface) => _remote.usage(surface);

  @override
  Future<GenerateTranslationsResult> generate({
    required String surface,
    required String entity,
    required int recordId,
    required List<String> fields,
    required List<String> targetLocales,
    String? sourceLocale,
    bool confirmOverwrite = false,
  }) {
    return _remote.generate(
      surface: surface,
      entity: entity,
      recordId: recordId,
      fields: fields,
      targetLocales: targetLocales,
      sourceLocale: sourceLocale,
      confirmOverwrite: confirmOverwrite,
    );
  }

  @override
  Future<TranslationRow> update({
    required String surface,
    required int id,
    required String translatedText,
  }) {
    return _remote.update(
      surface: surface,
      id: id,
      translatedText: translatedText,
    );
  }

  @override
  Future<TranslationRow> approve({
    required String surface,
    required int id,
  }) {
    return _remote.approve(surface: surface, id: id);
  }

  @override
  Future<TranslationRow> reject({
    required String surface,
    required int id,
    String? reason,
  }) {
    return _remote.reject(surface: surface, id: id, reason: reason);
  }

  @override
  Future<GenerateTranslationsResult> regenerate({
    required String surface,
    required int id,
    bool confirmOverwrite = false,
  }) {
    return _remote.regenerate(
      surface: surface,
      id: id,
      confirmOverwrite: confirmOverwrite,
    );
  }

  @override
  Future<List<TranslationRow>> approveMany({
    required String surface,
    required String entity,
    required int recordId,
    required List<int> ids,
  }) {
    return _remote.approveMany(
      surface: surface,
      entity: entity,
      recordId: recordId,
      ids: ids,
    );
  }
}

JsonMap _asMap(Object? data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data == null) return <String, dynamic>{};
  throw StateError('Expected a translation object.');
}
