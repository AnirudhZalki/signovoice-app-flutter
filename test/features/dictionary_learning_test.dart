import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/features/dictionary/domain/sign_dictionary.dart';
import 'package:signovoice/features/dictionary/domain/text_to_sign.dart';
import 'package:signovoice/features/learning/data/learning_repository.dart';
import 'package:signovoice/features/learning/domain/learning_progress.dart';
import 'package:signovoice/features/learning/presentation/learning_controller.dart';
import 'package:signovoice/features/practice/domain/practice_evaluator.dart';
import 'package:signovoice/features/sign_translation/domain/sign_prediction.dart';

SignDictionary loadDict() =>
    SignDictionary.fromJson(jsonDecode(File('assets/data/sign_dictionary.json').readAsStringSync()) as Map<String, dynamic>);

SignPrediction p(String l, double c) => SignPrediction(label: l, confidence: c);

void main() {
  final dict = loadDict();

  group('bundled dictionary', () {
    test('has 12 categories and every entry belongs to one', () {
      expect(dict.categories.length, 12);
      final ids = dict.categories.map((c) => c.id).toSet();
      expect(dict.entries.every((e) => ids.contains(e.categoryId)), isTrue);
    });
    test('every referenced media file exists (no faked assets)', () {
      for (final e in dict.entries.where((e) => e.videoPath != null)) {
        expect(File(e.videoPath!).existsSync(), isTrue, reason: e.videoPath);
      }
      expect(dict.entries.where((e) => e.hasMedia).length, 5);
    });
    test('practiceable signs map exactly to model labels', () {
      final manifest = jsonDecode(File('assets/models/labels.json').readAsStringSync()) as Map<String, dynamic>;
      final labels = (manifest['labels'] as List).cast<String>().toSet();
      final practice = dict.entries.where((e) => e.isPracticeable).map((e) => e.practiceLabel!).toSet();
      expect(practice, labels);
    });
  });

  group('search', () {
    test('finds by word, ranks exact first', () {
      expect(dict.search('hello').first.id, 'hello');
      expect(dict.search('THANK YOU').first.id, 'thank_you');
    });
    test('finds by Hindi/Kannada alias', () {
      expect(dict.search('अस्पताल').first.id, 'hospital');
      expect(dict.search('ನೀರು').first.id, 'water');
    });
    test('category filter and empty query', () {
      expect(dict.search('', categoryId: 'greetings').every((e) => e.categoryId == 'greetings'), isTrue);
      expect(dict.search('zzzz'), isEmpty);
    });
    test('partial match', () => expect(dict.search('hosp').map((e) => e.id), contains('hospital')));
  });

  group('TextToSignConverter', () {
    final c = TextToSignConverter(dict);
    test('"Where is the hospital?" -> where + hospital', () {
      final t = c.convert('Where is the hospital?');
      expect(t.map((x) => x.entry?.id), ['where', 'hospital']);
    });
    test('prefers longest phrase', () {
      expect(c.convert('thank you very much').map((x) => x.entry?.id), ['thank_you_very_much']);
      expect(c.convert('Thank you').map((x) => x.entry?.id), ['thank_you']);
    });
    test('unknown words are kept and flagged, not invented', () {
      final t = c.convert('hello zorblax');
      expect(t.length, 2);
      expect(t[1].hasSign, isFalse);
      expect(t[1].surface, 'zorblax');
    });
    test('handles Hindi input', () => expect(c.convert('नमस्ते').single.entry?.id, 'hello'));
    test('empty and punctuation-only input', () {
      expect(c.convert(''), isEmpty);
      expect(c.convert('?!'), isEmpty);
    });
  });

  group('ProgressRules', () {
    final d1 = DateTime(2026, 6, 1, 9);
    test('learning a sign gives XP once and starts a streak', () {
      var p = ProgressRules.markLearned(const LearningProgress(), 'hello', d1);
      expect(p.xp, 5);
      expect(p.streakDays, 1);
      expect(p.badges, contains(LearningBadge.firstSign));
      p = ProgressRules.markLearned(p, 'hello', d1);
      expect(p.xp, 5);
    });
    test('streak grows on consecutive days and resets after a gap', () {
      var p = ProgressRules.touchDay(const LearningProgress(), d1);
      p = ProgressRules.touchDay(p, d1.add(const Duration(days: 1)));
      p = ProgressRules.touchDay(p, d1.add(const Duration(days: 2)));
      expect(p.streakDays, 3);
      expect(p.badges, isEmpty); // badges are awarded by learning/practice, not by opening
      p = ProgressRules.touchDay(p, d1.add(const Duration(days: 5)));
      expect(p.streakDays, 1);
    });
    test('same-day activity does not double the streak', () {
      var p = ProgressRules.touchDay(const LearningProgress(), d1);
      p = ProgressRules.touchDay(p, d1.add(const Duration(hours: 3)));
      expect(p.streakDays, 1);
      expect(p.activity['2026-06-01'], 2);
    });
    test('practice awards XP and streak badges', () {
      var p = const LearningProgress();
      for (var i = 0; i < 3; i++) {
        p = ProgressRules.recordPractice(p, signId: 'hello', correct: true, now: d1.add(Duration(days: i)));
      }
      expect(p.practiceCorrect, 3);
      expect(p.xp, 3 * 12);
      expect(p.badges, containsAll([LearningBadge.firstCorrect, LearningBadge.streak3]));
      expect(p.accuracy, 1);
      p = ProgressRules.recordPractice(p, signId: 'hello', correct: false, now: d1.add(const Duration(days: 3)));
      expect(p.accuracy, 0.75);
    });
    test('bookmark toggles, level from xp, json round trip', () {
      var p = ProgressRules.toggleBookmark(const LearningProgress(), 'hello');
      expect(p.bookmarked, {'hello'});
      p = ProgressRules.toggleBookmark(p, 'hello');
      expect(p.bookmarked, isEmpty);
      expect(ProgressRules.level(0), 1);
      expect(ProgressRules.level(250), 3);
      final q = ProgressRules.markLearned(const LearningProgress(), 'a', d1);
      expect(LearningProgress.fromJson(q.toJson()), q);
    });
  });

  test('LearningRepository persists progress and sessions', () async {
    final repo = LearningRepository(InMemoryKeyValueStore(), InMemoryCollectionStore());
    await repo.save(ProgressRules.markLearned(const LearningProgress(), 'a', DateTime(2026, 1, 1)));
    expect(repo.load().learned, {'a'});
    await repo.addSession(PracticeSession(
        id: '1', signId: 'hello', recognized: 'Hello', confidence: 0.9, correct: true, timestamp: DateTime(2026, 1, 1)));
    expect((await repo.sessions()).single.correct, isTrue);
    await repo.clear();
    expect(repo.load().learned, isEmpty);
  });

  group('lessons', () {
    test('categories split into lessons of 5, ids resolvable', () {
      final ls = lessonsFor(dict, 'greetings');
      expect(ls.length, 2);
      expect(ls.first.entries.length, 5);
      expect(lessonById(dict, ls[1].id)!.entries.first.id, ls[1].entries.first.id);
      expect(lessonById(dict, 'greetings-99'), isNull);
      expect(lessonById(dict, 'nope'), isNull);
    });
  });

  group('PracticeEvaluator', () {
    const ev = PracticeEvaluator(threshold: 0.7);
    test('correct when the target wins with enough confidence', () {
      final r = ev.evaluate([p('Hello', 0.9), p('Hello', 0.8), p('Yes', 0.5)], target: 'Hello');
      expect(r.correct, isTrue);
      expect(r.recognized, 'Hello');
      expect(r.confidence, closeTo(0.85, 1e-9));
    });
    test('wrong sign -> try again', () {
      final r = ev.evaluate([p('No', 0.9), p('No', 0.9)], target: 'Hello');
      expect(r.correct, isFalse);
      expect(r.recognized, 'No');
    });
    test('low confidence is not correct even if the label matches', () {
      expect(ev.evaluate([p('Hello', 0.5), p('Hello', 0.6)], target: 'Hello').correct, isFalse);
    });
    test('too few predictions = no hand', () {
      final r = ev.evaluate([p('Hello', 0.9)], target: 'Hello');
      expect(r.noHand, isTrue);
      expect(r.correct, isFalse);
    });
  });
}
