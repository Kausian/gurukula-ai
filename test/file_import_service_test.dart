// Tests for PDF text extraction and its friendly error handling (Phase 9B).
//
// We build PDFs in-memory with syncfusion (text, blank/scanned, encrypted) and
// feed their bytes to FileImportService.extractPdfText — the same code path the
// picker uses — so the error mapping is covered without real files or a device.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:gurukula_ai/services/file_import_service.dart';

Future<Uint8List> _buildPdf({String? text, String? password}) async {
  final document = PdfDocument();
  if (password != null) document.security.userPassword = password;
  final page = document.pages.add();
  if (text != null) {
    page.graphics.drawString(
      text,
      PdfStandardFont(PdfFontFamily.helvetica, 14),
    );
  }
  final bytes = await document.save();
  document.dispose();
  return Uint8List.fromList(bytes);
}

Matcher _importErrorContaining(String fragment) => throwsA(
      isA<FileImportException>()
          .having((e) => e.message, 'message', contains(fragment)),
    );

void main() {
  const service = FileImportService();

  test('extracts text from a text-based PDF', () async {
    final bytes = await _buildPdf(text: 'Photosynthesis basics for revision');
    final text = await service.extractPdfText(bytes);
    expect(text, contains('Photosynthesis'));
  });

  test('scanned/image-only PDF (no text) reports a friendly OCR message',
      () async {
    final bytes = await _buildPdf(); // a page but no drawn text
    expect(() => service.extractPdfText(bytes),
        _importErrorContaining('scanned'));
  });

  test('password-protected PDF reports a protected message', () async {
    final bytes = await _buildPdf(text: 'secret notes', password: 'open-me');
    expect(() => service.extractPdfText(bytes),
        _importErrorContaining('protected'));
  });

  test('corrupt bytes report a could-not-read message', () async {
    final bytes = Uint8List.fromList(List<int>.generate(512, (i) => i % 256));
    expect(() => service.extractPdfText(bytes),
        _importErrorContaining('Could not read'));
  });
}
