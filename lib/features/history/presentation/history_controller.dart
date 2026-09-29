import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';

final historyRepositoryProvider =
    Provider<HistoryRepository>((ref) => HistoryRepository(ref.watch(collectionStoreProvider)));

class HistoryController extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() => ref.read(historyRepositoryProvider).all();

  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  /// Saves an entry unless the person turned history off. Returns whether it was saved.
  Future<bool> record(HistoryEntry e) async {
    if (!ref.read(preferencesProvider).saveHistory) return false;
    if (e.text.trim().isEmpty && e.glosses.isEmpty) return false;
    await _repo.add(e);
    state = AsyncData(await _repo.all());
    return true;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.all());
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncData([]);
  }
}

final historyProvider = AsyncNotifierProvider<HistoryController, List<HistoryEntry>>(HistoryController.new);

/// Free plan shows only the most recent entries; the rest stay stored and
/// reappear if the person upgrades (nothing is deleted by the limit).
final visibleHistoryProvider = Provider<AsyncValue<List<HistoryEntry>>>((ref) {
  final limit = ref.watch(entitlementProvider).historyLimit;
  return ref.watch(historyProvider).whenData((l) => limit < 0 || l.length <= limit ? l : l.take(limit).toList());
});

final historyHiddenCountProvider = Provider<int>((ref) {
  final limit = ref.watch(entitlementProvider).historyLimit;
  final total = ref.watch(historyProvider).value?.length ?? 0;
  return limit < 0 || total <= limit ? 0 : total - limit;
});
