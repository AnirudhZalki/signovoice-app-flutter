import '../../../core/services/storage.dart';
import '../domain/history_entry.dart';

/// Local, on-device history. Newest first. [limit] < 0 means unlimited.
class HistoryRepository {
  HistoryRepository(this._store);
  final CollectionStore _store;
  static const _name = 'history';

  Future<List<HistoryEntry>> all() async {
    final rows = await _store.read(_name);
    final list = <HistoryEntry>[];
    for (final r in rows) {
      try {
        list.add(HistoryEntry.fromJson(r));
      } catch (_) {/* skip corrupt row */}
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> add(HistoryEntry e) async {
    final list = await all();
    list.insert(0, e);
    await _write(list);
  }

  Future<void> delete(String id) async => _write((await all()).where((e) => e.id != id).toList());

  Future<void> clear() => _store.delete(_name);

  Future<void> _write(List<HistoryEntry> list) => _store.write(_name, [for (final e in list) e.toJson()]);

  /// Case-insensitive search over text and glosses.
  static List<HistoryEntry> search(List<HistoryEntry> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((e) => e.text.toLowerCase().contains(q) || e.glosses.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }
}
