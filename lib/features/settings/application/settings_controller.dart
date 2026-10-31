import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/settings_data.dart';
import '../domain/settings_domain.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    SettingsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final workspaceSettingsProvider = FutureProvider<WorkspaceSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).get();
});

class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  Future<WorkspaceSettings> update(WorkspaceSettingsDraft draft) async {
    final settings = await _ref.read(settingsRepositoryProvider).update(draft);
    _ref.invalidate(workspaceSettingsProvider);
    return settings;
  }
}

final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);
