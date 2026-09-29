import 'package:equatable/equatable.dart';

import 'phrase_lexicon.dart';

class TranslationResult extends Equatable {
  const TranslationResult({
    required this.text,
    required this.glosses,
    required this.languageCode,
    required this.engineId,
  });

  final String text;
  final List<String> glosses;
  final String languageCode;

  /// Which engine produced [text] ("rule-based", "remote-ai").
  final String engineId;

  @override
  List<Object?> get props => [text, glosses, languageCode, engineId];
}

/// Gloss sequence → readable text. Implementations are interchangeable; a
/// remote AI model can be introduced without touching the UI.
abstract class TranslationEngine {
  String get id;
  Future<TranslationResult> translate(List<String> glosses, {required String languageCode});
}

/// Builds a readable sentence from glosses using [PhraseLexicon].
///
/// Steps: group fingerspelling → longest phrase match → word lookup →
/// punctuation (question marks for question words; full stop for multi-word
/// output) → capitalise. Unknown glosses are passed through in lower case,
/// never invented.
class SentenceBuilder {
  const SentenceBuilder({this.lexicon = PhraseLexicon.builtIn});

  final PhraseLexicon lexicon;

  static final RegExp _letter = RegExp(r'^[A-Z]$');

  String build(List<String> rawGlosses, {String languageCode = 'en'}) {
    if (rawGlosses.isEmpty) return '';
    final tokens = _tokenize(rawGlosses);
    final segments = <String>[];
    var hasQuestion = false;
    var phraseUsed = false;

    var i = 0;
    while (i < tokens.length) {
      PhraseEntry? match;
      for (final p in lexicon.phrases) {
        if (_matchesAt(tokens, i, p.glosses) && (match == null || p.glosses.length > match.glosses.length)) {
          match = p;
        }
      }
      if (match != null) {
        segments.add(match.text[languageCode] ?? match.text['en']!);
        phraseUsed = true;
        i += match.glosses.length;
        continue;
      }
      final t = tokens[i];
      if (t.spelled) {
        segments.add(t.gloss); // fingerspelled: keep letters as signed
      } else {
        if (lexicon.questionWords.contains(t.gloss)) hasQuestion = true;
        segments.add(lexicon.word(t.gloss, languageCode) ?? t.gloss.toLowerCase());
      }
      i++;
    }

    var text = segments.join(' ').trim();
    if (text.isEmpty) return '';
    if (!RegExp(r'[.?!।]$').hasMatch(text)) {
      if (hasQuestion && !phraseUsed) {
        text += '?';
      } else if (segments.length > 1) {
        text += languageCode == 'hi' ? '।' : '.';
      }
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Consecutive single letters become one fingerspelled token ("A","B" → "AB").
  List<_Token> _tokenize(List<String> glosses) {
    final out = <_Token>[];
    final run = StringBuffer();
    void flush() {
      if (run.isEmpty) return;
      out.add(_Token(run.toString(), spelled: true));
      run.clear();
    }

    for (final g in glosses) {
      if (_letter.hasMatch(g)) {
        run.write(g);
      } else {
        flush();
        out.add(_Token(g, spelled: false));
      }
    }
    flush();
    return out;
  }

  bool _matchesAt(List<_Token> t, int at, List<String> phrase) {
    if (at + phrase.length > t.length) return false;
    for (var k = 0; k < phrase.length; k++) {
      if (t[at + k].spelled || t[at + k].gloss != phrase[k]) return false;
    }
    return true;
  }
}

class _Token {
  const _Token(this.gloss, {required this.spelled});
  final String gloss;
  final bool spelled;
}

class RuleBasedTranslationEngine implements TranslationEngine {
  const RuleBasedTranslationEngine({this.builder = const SentenceBuilder()});
  final SentenceBuilder builder;

  @override
  String get id => 'rule-based';

  @override
  Future<TranslationResult> translate(List<String> glosses, {required String languageCode}) async =>
      TranslationResult(
        text: builder.build(glosses, languageCode: languageCode),
        glosses: List.unmodifiable(glosses),
        languageCode: languageCode,
        engineId: id,
      );
}
