import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../domain/user_preferences.dart';

class PreferencesController extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    final raw = ref.read(keyValueStoreProvider).getString(PrefKeys.preferences);
    if (raw == null) return const UserPreferences();
    try {
      return UserPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserPreferences(); // corrupt settings must never block start-up
    }
  }

  Future<void> update(UserPreferences Function(UserPreferences p) change) async {
    state = change(state);
    await ref.read(keyValueStoreProvider).setString(PrefKeys.preferences, jsonEncode(state.toJson()));
    ref.read(hapticsServiceProvider).enabled = state.haptics;
  }

  Future<void> reset() => update((_) => const UserPreferences());
}

final preferencesProvider =
    NotifierProvider<PreferencesController, UserPreferences>(PreferencesController.new);
