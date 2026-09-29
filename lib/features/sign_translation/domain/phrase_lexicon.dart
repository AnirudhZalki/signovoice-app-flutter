/// Gloss → natural-language lookup used by the rule-based translator.
///
/// This is deliberately small and data-driven; it is not sign-language
/// translation. Anything not covered falls back to the plain word so nothing
/// is invented. A stronger model can replace it via [TranslationEngine].
class PhraseLexicon {
  const PhraseLexicon({required this.words, required this.phrases, required this.questionWords});

  /// gloss -> language code -> text
  final Map<String, Map<String, String>> words;

  /// Multi-gloss phrases -> language code -> text
  final List<PhraseEntry> phrases;
  final Set<String> questionWords;

  static const builtIn = PhraseLexicon(
    words: {
      'HELLO': {'en': 'Hello', 'hi': 'नमस्ते', 'kn': 'ನಮಸ್ಕಾರ'},
      'THANKS': {'en': 'Thank you', 'hi': 'धन्यवाद', 'kn': 'ಧನ್ಯವಾದ'},
      'I LOVE YOU': {'en': 'I love you', 'hi': 'मुझे तुमसे प्यार है', 'kn': 'ನಾನು ನಿನ್ನನ್ನು ಪ್ರೀತಿಸುತ್ತೇನೆ'},
      'YES': {'en': 'Yes', 'hi': 'हाँ', 'kn': 'ಹೌದು'},
      'NO': {'en': 'No', 'hi': 'नहीं', 'kn': 'ಇಲ್ಲ'},
      'PLEASE': {'en': 'Please', 'hi': 'कृपया', 'kn': 'ದಯವಿಟ್ಟು'},
      'HELP': {'en': 'Help', 'hi': 'मदद', 'kn': 'ಸಹಾಯ'},
      'WATER': {'en': 'Water', 'hi': 'पानी', 'kn': 'ನೀರು'},
      'HOSPITAL': {'en': 'Hospital', 'hi': 'अस्पताल', 'kn': 'ಆಸ್ಪತ್ರೆ'},
      'WHERE': {'en': 'Where', 'hi': 'कहाँ', 'kn': 'ಎಲ್ಲಿ'},
    },
    phrases: [
      PhraseEntry(['WHERE', 'HOSPITAL'], {'en': 'Where is the hospital?', 'hi': 'अस्पताल कहाँ है?', 'kn': 'ಆಸ್ಪತ್ರೆ ಎಲ್ಲಿದೆ?'}),
      PhraseEntry(['HOSPITAL', 'WHERE'], {'en': 'Where is the hospital?', 'hi': 'अस्पताल कहाँ है?', 'kn': 'ಆಸ್ಪತ್ರೆ ಎಲ್ಲಿದೆ?'}),
      PhraseEntry(['PLEASE', 'HELP'], {'en': 'Please help me.', 'hi': 'कृपया मेरी मदद करें।', 'kn': 'ದಯವಿಟ್ಟು ನನಗೆ ಸಹಾಯ ಮಾಡಿ.'}),
      PhraseEntry(['HELP', 'PLEASE'], {'en': 'Please help me.', 'hi': 'कृपया मेरी मदद करें।', 'kn': 'ದಯವಿಟ್ಟು ನನಗೆ ಸಹಾಯ ಮಾಡಿ.'}),
      PhraseEntry(['PLEASE', 'WATER'], {'en': 'Water, please.', 'hi': 'कृपया पानी दें।', 'kn': 'ದಯವಿಟ್ಟು ನೀರು ಕೊಡಿ.'}),
      PhraseEntry(['THANKS', 'HELLO'], {'en': 'Hello, thank you.', 'hi': 'नमस्ते, धन्यवाद।', 'kn': 'ನಮಸ್ಕಾರ, ಧನ್ಯವಾದ.'}),
    ],
    questionWords: {'WHERE', 'WHAT', 'WHO', 'WHEN', 'WHY', 'HOW'},
  );

  String? word(String gloss, String lang) => words[gloss]?[lang] ?? words[gloss]?['en'];
}

class PhraseEntry {
  const PhraseEntry(this.glosses, this.text);
  final List<String> glosses;
  final Map<String, String> text;
}
