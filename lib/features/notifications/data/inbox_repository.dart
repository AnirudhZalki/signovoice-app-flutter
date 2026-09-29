import '../../../core/services/storage.dart';
import '../domain/notification_models.dart';

/// On-device inbox of received notifications (max 100, newest first).
class InboxRepository {
  InboxRepository(this._store);
  final CollectionStore _store;
  static const _name = 'notifications';

  Future<List<AppNotification>> all() async {
    final rows = await _store.read(_name);
    return [for (final r in rows) AppNotification.fromJson(r)]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> _write(List<AppNotification> l) => _store.write(_name, [for (final n in l.take(100)) n.toJson()]);

  Future<void> add(AppNotification n) async {
    final l = await all();
    if (l.any((e) => e.id == n.id)) return;
    await _write([n, ...l]);
  }

  Future<void> markAllRead() async => _write([for (final n in await all()) n.copyWith(read: true)]);
  Future<void> markRead(String id) async => _write([for (final n in await all()) n.id == id ? n.copyWith(read: true) : n]);
  Future<void> clear() => _store.delete(_name);
}
