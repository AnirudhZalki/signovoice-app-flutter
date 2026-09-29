import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/core/services/usage_service.dart';
import 'package:signovoice/features/history/data/history_repository.dart';
import 'package:signovoice/features/history/domain/history_entry.dart';

HistoryEntry e(String id, String text, DateTime t, {List<String> g = const []}) => HistoryEntry(
    id: id, inputType: HistoryInputType.signToText, glosses: g, text: text, timestamp: t, languageCode: 'en', durationMs: 1000);

void main() {
  group('HistoryRepository', () {
    late HistoryRepository repo;
    setUp(() => repo = HistoryRepository(InMemoryCollectionStore()));

    test('stores newest first', () async {
      await repo.add(e('1', 'Hello', DateTime(2026, 1, 1)));
      await repo.add(e('2', 'Thank you', DateTime(2026, 1, 2)));
      expect((await repo.all()).map((x) => x.id), ['2', '1']);
    });

    test('deletes one and clears all', () async {
      await repo.add(e('1', 'Hello', DateTime(2026, 1, 1)));
      await repo.add(e('2', 'Yes', DateTime(2026, 1, 2)));
      await repo.delete('1');
      expect((await repo.all()).length, 1);
      await repo.clear();
      expect(await repo.all(), isEmpty);
    });

    test('search matches text and glosses, case-insensitively', () async {
      final all = [e('1', 'Hello there', DateTime(2026, 1, 1), g: ['HELLO']), e('2', 'Yes', DateTime(2026, 1, 2), g: ['YES'])];
      expect(HistoryRepository.search(all, 'HELL').map((x) => x.id), ['1']);
      expect(HistoryRepository.search(all, 'yes').map((x) => x.id), ['2']);
      expect(HistoryRepository.search(all, '  ').length, 2);
    });

    test('json round trip', () {
      final x = e('1', 'Hello', DateTime(2026, 1, 1), g: ['HELLO']);
      expect(HistoryEntry.fromJson(x.toJson()), x);
    });
  });

  group('UsageService', () {
    test('counts per day and resets on a new day', () async {
      var now = DateTime(2026, 5, 1, 10);
      final u = UsageService(InMemoryKeyValueStore(), () => now);
      expect(u.signsToday, 0);
      await u.recordSigns();
      await u.recordSigns(2);
      expect(u.signsToday, 3);
      expect(u.isLimitReached(3), isTrue);
      expect(u.isLimitReached(-1), isFalse);
      expect(u.remaining(10), 7);
      now = DateTime(2026, 5, 2, 9);
      expect(u.signsToday, 0);
    });
  });
}
