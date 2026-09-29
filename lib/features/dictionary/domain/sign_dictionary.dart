import 'package:equatable/equatable.dart';

class SignCategory extends Equatable {
  const SignCategory({required this.id, required this.icon});
  final String id;

  /// Material icon name key resolved in the UI (kept as data so packs can add categories).
  final String icon;

  factory SignCategory.fromJson(Map<String, dynamic> j) => SignCategory(id: j['id'] as String, icon: j['icon'] as String? ?? 'category');

  @override
  List<Object?> get props => [id, icon];
}

class SignEntry extends Equatable {
  const SignEntry({
    required this.id,
    required this.word,
    required this.meaning,
    required this.categoryId,
    this.aliases = const {},
    this.videoPath,
    this.imagePath,
    this.practiceLabel,
  });

  final String id;
  final String word;
  final String meaning;
  final String categoryId;

  /// Other-language spellings/words: language code -> list.
  final Map<String, List<String>> aliases;

  /// `assets/...` (bundled) or `https://...` (remote pack).
  final String? videoPath;
  final String? imagePath;

  /// Model label if the on-device recogniser can evaluate this sign (practice).
  final String? practiceLabel;

  bool get hasMedia => videoPath != null || imagePath != null;
  bool get isPracticeable => practiceLabel != null;

  factory SignEntry.fromJson(Map<String, dynamic> j) {
    final media = j['media'] as Map<String, dynamic>?;
    final al = <String, List<String>>{};
    (j['aliases'] as Map<String, dynamic>?)?.forEach((k, v) => al[k] = (v as List<dynamic>).cast<String>());
    return SignEntry(
      id: j['id'] as String,
      word: j['word'] as String,
      meaning: j['meaning'] as String? ?? '',
      categoryId: j['category'] as String,
      aliases: al,
      videoPath: media?['video'] as String?,
      imagePath: media?['image'] as String?,
      practiceLabel: j['practiceLabel'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, word, meaning, categoryId, aliases, videoPath, imagePath, practiceLabel];
}

/// In-memory, indexed dictionary. Lookups are O(1) by id / normalised word so
/// it stays fast with thousands of entries.
class SignDictionary {
  SignDictionary({required this.version, required this.categories, required List<SignEntry> entries})
      : entries = List.unmodifiable(entries) {
    for (final e in entries) {
      byId[e.id] = e;
      _addKey(e.word, e);
      for (final list in e.aliases.values) {
        for (final a in list) {
          _addKey(a, e);
        }
      }
    }
    for (final e in entries) {
      (byCategory[e.categoryId] ??= []).add(e);
    }
  }

  final int version;
  final List<SignCategory> categories;
  final List<SignEntry> entries;
  final Map<String, SignEntry> byId = {};
  final Map<String, List<SignEntry>> byCategory = {};
  final Map<String, SignEntry> _byKey = {};
  int _maxWords = 1;

  int get maxPhraseWords => _maxWords;

  /// Lower-cases, strips punctuation (keeps letters/digits/spaces in any script) and collapses spaces.
  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"['’`]"), '')
      .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void _addKey(String surface, SignEntry e) {
    final k = normalize(surface);
    if (k.isEmpty) return;
    _byKey.putIfAbsent(k, () => e);
    final words = k.split(' ').length;
    if (words > _maxWords) _maxWords = words;
  }

  SignEntry? lookup(String surface) => _byKey[normalize(surface)];

  factory SignDictionary.fromJson(Map<String, dynamic> j) => SignDictionary(
        version: j['version'] as int? ?? 1,
        categories: [for (final c in (j['categories'] as List<dynamic>? ?? const [])) SignCategory.fromJson(c as Map<String, dynamic>)],
        entries: [for (final e in (j['entries'] as List<dynamic>? ?? const [])) SignEntry.fromJson(e as Map<String, dynamic>)],
      );

  /// Ranked search: exact > prefix > word-prefix > contains, over word and aliases.
  List<SignEntry> search(String query, {String? categoryId}) {
    final q = normalize(query);
    final pool = categoryId == null ? entries : (byCategory[categoryId] ?? const <SignEntry>[]);
    if (q.isEmpty) return List.of(pool);
    final scored = <(int, SignEntry)>[];
    for (final e in pool) {
      var best = 99;
      for (final s in [e.word, ...e.aliases.values.expand((x) => x)]) {
        final n = normalize(s);
        final score = n == q
            ? 0
            : n.startsWith(q)
                ? 1
                : n.split(' ').any((w) => w.startsWith(q))
                    ? 2
                    : n.contains(q)
                        ? 3
                        : 99;
        if (score < best) best = score;
      }
      if (best < 99) scored.add((best, e));
    }
    scored.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.word.compareTo(b.$2.word));
    return [for (final s in scored) s.$2];
  }
}
