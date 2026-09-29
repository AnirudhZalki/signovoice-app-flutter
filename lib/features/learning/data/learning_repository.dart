import 'dart:convert';

import '../../../core/services/storage.dart';
import '../domain/learning_progress.dart';

class LearningRepository {
  LearningRepository(this._kv, this._collections);
  final KeyValueStore _kv;
  final CollectionStore _collections;

  static const _progressKey = 'learning_progress_v1';
  static const _sessions = 'practice_sessions';

  LearningProgress load() {
    final raw = _kv.getString(_progressKey);
    if (raw == null) return const LearningProgress();
    try {
      return LearningProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const LearningProgress();
    }
  }

  Future<void> save(LearningProgress p) => _kv.setString(_progressKey, jsonEncode(p.toJson()));

  Future<List<PracticeSession>> sessions() async {
    final rows = await _collections.read(_sessions);
    return [for (final r in rows) PracticeSession.fromJson(r)]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addSession(PracticeSession s) async {
    final all = await sessions();
    all.insert(0, s);
    await _collections.write(_sessions, [for (final e in all.take(200)) e.toJson()]);
  }

  Future<void> clear() async {
    await _kv.remove(_progressKey);
    await _collections.delete(_sessions);
  }
}
