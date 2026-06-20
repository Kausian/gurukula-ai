// Pure unit tests for the .txt export file-name sanitizer (Phase 13).

import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/core/utils/export_filename.dart';

void main() {
  test('keeps a normal title unchanged', () {
    expect(sanitizeFileName('Biology summary'), 'Biology summary');
  });

  test('removes illegal file-system characters', () {
    expect(sanitizeFileName('Notes: ch/1 *final?'), 'Notes ch 1 final');
  });

  test('collapses whitespace and trims', () {
    expect(sanitizeFileName('  too   many   spaces  '), 'too many spaces');
  });

  test('strips leading dots', () {
    expect(sanitizeFileName('...hidden'), 'hidden');
  });

  test('caps very long names', () {
    final long = 'a' * 200;
    expect(sanitizeFileName(long).length, 60);
  });

  test('falls back when nothing usable remains', () {
    expect(sanitizeFileName('   '), 'gurukula-export');
    expect(sanitizeFileName('/\\:*?'), 'gurukula-export');
  });
}
