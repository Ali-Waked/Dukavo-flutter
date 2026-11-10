import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/translation_data.dart';
import '../domain/translation_domain.dart';

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return TranslationRepositoryImpl(
    TranslationRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// One review screen. [sourceLocale] is part of the key because correcting the
/// source language changes which locales are offered as targets.
class TranslationTarget {
  const TranslationTarget({
    required this.surface,
    required this.entity,
    required this.recordId,
    this.sourceLocale,
  });

  final String surface;
  final String entity;
  final int recordId;
  final String? sourceLocale;

  TranslationTarget withSource(String? locale) {
    return TranslationTarget(
      surface: surface,
      entity: entity,
      recordId: recordId,
      sourceLocale: locale,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TranslationTarget &&
        other.surface == surface &&
        other.entity == entity &&
        other.recordId == recordId &&
        other.sourceLocale == sourceLocale;
  }

  @override
  int get hashCode => Object.hash(surface, entity, recordId, sourceLocale);
}

final translationOverviewProvider =
    FutureProvider.autoDispose.family<TranslationOverview, TranslationTarget>(
  (ref, target) {
    return ref.watch(translationRepositoryProvider).overview(
          surface: target.surface,
          entity: target.entity,
          recordId: target.recordId,
          sourceLocale: target.sourceLocale,
        );
  },
);

final translationUsageProvider =
    FutureProvider.autoDispose.family<TranslationUsage, String>((ref, surface) {
  return ref.watch(translationRepositoryProvider).usage(surface);
});

/// Mutations invalidate the affected overview so the screen always renders the
/// server's status rather than an optimistic local guess.
class TranslationActions {
  TranslationActions(this._ref);

  final Ref _ref;

  TranslationRepository get _repository => _ref.read(translationRepositoryProvider);

  Future<GenerateTranslationsResult> generate({
    required TranslationTarget target,
    required List<String> fields,
    required List<String> targetLocales,
    String? sourceLocale,
    bool confirmOverwrite = false,
  }) async {
    final result = await _repository.generate(
      surface: target.surface,
      entity: target.entity,
      recordId: target.recordId,
      fields: fields,
      targetLocales: targetLocales,
      sourceLocale: sourceLocale,
      confirmOverwrite: confirmOverwrite,
    );
    _refresh(target);
    return result;
  }

  Future<TranslationRow> update({
    required TranslationTarget target,
    required int id,
    required String translatedText,
  }) async {
    final row = await _repository.update(
      surface: target.surface,
      id: id,
      translatedText: translatedText,
    );
    _refresh(target);
    return row;
  }

  Future<TranslationRow> approve({
    required TranslationTarget target,
    required int id,
  }) async {
    final row = await _repository.approve(surface: target.surface, id: id);
    _refresh(target);
    return row;
  }

  Future<TranslationRow> reject({
    required TranslationTarget target,
    required int id,
    String? reason,
  }) async {
    final row = await _repository.reject(
      surface: target.surface,
      id: id,
      reason: reason,
    );
    _refresh(target);
    return row;
  }

  Future<GenerateTranslationsResult> regenerate({
    required TranslationTarget target,
    required int id,
    bool confirmOverwrite = false,
  }) async {
    final result = await _repository.regenerate(
      surface: target.surface,
      id: id,
      confirmOverwrite: confirmOverwrite,
    );
    _refresh(target);
    return result;
  }

  Future<List<TranslationRow>> approveMany({
    required TranslationTarget target,
    required List<int> ids,
  }) async {
    final rows = await _repository.approveMany(
      surface: target.surface,
      entity: target.entity,
      recordId: target.recordId,
      ids: ids,
    );
    _refresh(target);
    return rows;
  }

  void _refresh(TranslationTarget target) {
    _ref.invalidate(translationOverviewProvider(target));
    _ref.invalidate(translationUsageProvider(target.surface));
  }
}

final translationActionsProvider =
    Provider<TranslationActions>(TranslationActions.new);
