/// Normalizes pasted text before it is stored or summarized.
///
/// Collapses runs of whitespace, trims each line, drops blank lines and
/// trims the result. Keeps single line breaks between paragraphs.
String cleanText(String input) {
  final lines = input
      .replaceAll('\r\n', '\n')
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
      .where((line) => line.isNotEmpty);
  return lines.join('\n').trim();
}

/// Splits text into trimmed, non-empty sentences.
List<String> splitSentences(String text) {
  return text
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// First [wordCount] words of [text], useful for deriving short titles.
String firstWords(String text, int wordCount) {
  final words =
      text.replaceAll('\n', ' ').split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  return words.take(wordCount).join(' ');
}
