/// Normalises raw sign labels into upper-case glosses and cleans a running
/// gloss sequence (duplicate suppression, fingerspelling merge).
class GlossProcessor {
  const GlossProcessor();

  static final RegExp _letter = RegExp(r'^[A-Z]$');

  String normalize(String label) => label.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

  /// Appends [label] unless it repeats the previous gloss.
  List<String> append(List<String> current, String label) {
    final g = normalize(label);
    if (g.isEmpty) return current;
    if (current.isNotEmpty && current.last == g) return current;
    return [...current, g];
  }

  /// Merges runs of two or more single letters (A B C) into one fingerspelled
  /// token ("ABC"). A lone letter is left as-is.
  List<String> mergeFingerspelling(List<String> glosses) {
    final out = <String>[];
    final run = StringBuffer();
    void flush() {
      if (run.isEmpty) return;
      out.add(run.toString());
      run.clear();
    }

    var runLen = 0;
    for (final g in glosses) {
      if (_letter.hasMatch(g)) {
        run.write(g);
        runLen++;
      } else {
        if (runLen == 1) {
          // single letter stays a letter
        }
        flush();
        runLen = 0;
        out.add(g);
      }
    }
    flush();
    return out;
  }
}
