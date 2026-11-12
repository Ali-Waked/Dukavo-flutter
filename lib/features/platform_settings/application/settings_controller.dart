import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/settings_data.dart';
import '../domain/settings_models.dart';

/// One repository for the platform configuration surface.
final settingsRepositoryProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(ref.watch(apiClientProvider));
});

/// The catalogue: every category, its definition count and its override count.
///
/// The hub reads this; a section screen reads its own category so a save only
/// refetches what changed.
final settingsCatalogueProvider =
    FutureProvider.autoDispose<SettingsCatalogue>((ref) {
  return ref.watch(settingsRepositoryProvider).catalogue();
});

/// One category with every resolved setting. Keyed by category so opening
/// General never rebuilds the WhatsApp form.
final settingsSectionProvider =
    FutureProvider.autoDispose.family<SettingsSection, String>((ref, category) {
  return ref.watch(settingsRepositoryProvider).section(category);
});

final platformFeaturesProvider =
    FutureProvider.autoDispose<List<PlatformFeatureFlag>>((ref) {
  return ref.watch(settingsRepositoryProvider).features();
});

final integrationHealthProvider =
    FutureProvider.autoDispose<List<IntegrationHealth>>((ref) {
  return ref.watch(settingsRepositoryProvider).health();
});

/// The last [limit] changes, optionally narrowed to one setting key.
final settingsHistoryProvider = FutureProvider.autoDispose
    .family<List<SettingsHistoryEntry>, SettingsHistoryQuery>((ref, query) {
  return ref
      .watch(settingsRepositoryProvider)
      .history(key: query.key, limit: query.limit);
});

final platformSystemProvider =
    FutureProvider.autoDispose<PlatformSystemSummary>((ref) {
  return ref.watch(settingsRepositoryProvider).system();
});

/// Actions that write. Each one refreshes only the futures it invalidates.
class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  Future<SettingsSection> save(
    String category,
    Map<String, Object?> values,
  ) async {
    final updated =
        await _ref.read(settingsRepositoryProvider).updateSection(category, values);
    _ref.invalidate(settingsSectionProvider(category));
    _ref.invalidate(settingsCatalogueProvider);
    _ref.invalidate(settingsHistoryProvider);
    _ref.invalidate(platformSystemProvider);

    return updated;
  }

  Future<void> setFeature(String key, bool enabled) async {
    await _ref.read(settingsRepositoryProvider).toggleFeature(key, enabled);
    _ref.invalidate(platformFeaturesProvider);
    _ref.invalidate(settingsCatalogueProvider);
  }

  Future<void> checkIntegration(String integration) async {
    await _ref.read(settingsRepositoryProvider).check(integration);
    _ref.invalidate(integrationHealthProvider);
    _ref.invalidate(settingsCatalogueProvider);
  }
}

final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);

/// The query part of the history screen. Value equality so Riverpod treats two
/// identical filters as the same provider and does not refetch.
class SettingsHistoryQuery {
  const SettingsHistoryQuery({this.key, this.limit = 50});

  final String? key;
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is SettingsHistoryQuery &&
        other.key == key &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(key, limit);
}
