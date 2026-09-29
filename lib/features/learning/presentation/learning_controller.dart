import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../data/learning_repository.dart';
import '../domain/learning_progress.dart';

final learningRepositoryProvider =
    Provider<LearningRepository>((ref) => LearningRepository(ref.watch(keyValueStoreProvider), ref.watch(collectionStoreProvider)));

class LearningController extends Notifier<LearningProgress> {
  @override
  LearningProgress build() => ref.read(learningRepositoryProvider).load();

  DateTime get _now => ref.read(clockProvider)();

  Future<void> _set(LearningProgress p) async {
    state = p;
    await ref.read(learningRepositoryProvider).save(p);
  }

  Future<void> markLearned(String signId) => _set(ProgressRules.markLearned(state, signId, _now));
  Future<void> toggleBookmark(String signId) => _set(ProgressRules.toggleBookmark(state, signId));

  Future<void> recordPractice(PracticeSession s) async {
    await ref.read(learningRepositoryProvider).addSession(s);
    await _set(ProgressRules.recordPractice(state, signId: s.signId, correct: s.correct, now: _now));
    ref.invalidate(practiceSessionsProvider);
  }

  Future<void> reset() async {
    await ref.read(learningRepositoryProvider).clear();
    state = const LearningProgress();
    ref.invalidate(practiceSessionsProvider);
  }
}

final learningProvider = NotifierProvider<LearningController, LearningProgress>(LearningController.new);

final practiceSessionsProvider =
    FutureProvider<List<PracticeSession>>((ref) => ref.watch(learningRepositoryProvider).sessions());

/// A lesson is a short run of signs from one category.
class LessonRef {
  const LessonRef({required this.categoryId, required this.index, required this.entries});
  final String categoryId;
  final int index; // 0-based
  final List<SignEntry> entries;

  String get id => '$categoryId-$index';
  int learnedCount(Set<String> learned) => entries.where((e) => learned.contains(e.id)).length;
  bool isComplete(Set<String> learned) => entries.isNotEmpty && learnedCount(learned) == entries.length;
}

const lessonSize = 5;

/// Splits a category's signs into lessons of [lessonSize].
List<LessonRef> lessonsFor(SignDictionary d, String categoryId) {
  final all = d.byCategory[categoryId] ?? const <SignEntry>[];
  return [
    for (var i = 0; i * lessonSize < all.length; i++)
      LessonRef(
        categoryId: categoryId,
        index: i,
        entries: all.sublist(i * lessonSize, (i + 1) * lessonSize > all.length ? all.length : (i + 1) * lessonSize),
      ),
  ];
}

LessonRef? lessonById(SignDictionary d, String id) {
  final dash = id.lastIndexOf('-');
  if (dash < 0) return null;
  final idx = int.tryParse(id.substring(dash + 1));
  if (idx == null) return null;
  final lessons = lessonsFor(d, id.substring(0, dash));
  return idx >= 0 && idx < lessons.length ? lessons[idx] : null;
}
