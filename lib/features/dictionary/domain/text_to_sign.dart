import 'sign_dictionary.dart';

/// One unit of the voice/text → sign output.
class SignToken {
  const SignToken({required this.surface, this.entry});

  /// What the person said/typed for this unit.
  final String surface;

  /// The dictionary sign, or null when no sign is available for [surface].
  final SignEntry? entry;

  bool get hasSign => entry != null;
}

/// Maps spoken/typed text to dictionary signs: longest phrase match first
/// (up to the longest dictionary phrase), skipping filler words only when
/// nothing matches. Unmatched words are kept and flagged, never invented.
class TextToSignConverter {
  const TextToSignConverter(this.dictionary);
  final SignDictionary dictionary;

  static const _fillers = {
    'is', 'are', 'am', 'was', 'were', 'the', 'a', 'an', 'to', 'of', 'do', 'does', 'did', 'be',
    'for', 'in', 'on', 'at', 'it', 'this', 'that', 'and', 'can', 'will', 'would', 'could', 'my', 'your',
  };

  List<SignToken> convert(String text) {
    final words = SignDictionary.normalize(text).split(' ').where((w) => w.isNotEmpty).toList();
    final out = <SignToken>[];
    var i = 0;
    while (i < words.length) {
      SignEntry? hit;
      var used = 0;
      final maxN = dictionary.maxPhraseWords.clamp(1, words.length - i);
      for (var n = maxN; n >= 1; n--) {
        final phrase = words.sublist(i, i + n).join(' ');
        final e = dictionary.lookup(phrase);
        if (e != null) {
          hit = e;
          used = n;
          break;
        }
      }
      if (hit != null) {
        out.add(SignToken(surface: words.sublist(i, i + used).join(' '), entry: hit));
        i += used;
      } else {
        final w = words[i];
        if (!_fillers.contains(w)) out.add(SignToken(surface: w));
        i++;
      }
    }
    return out;
  }
}
