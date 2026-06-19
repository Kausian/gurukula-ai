import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// The result of importing a file: its extracted text and original file name.
class ImportedFile {
  const ImportedFile({required this.text, required this.fileName});

  final String text;
  final String fileName;
}

/// A user-facing failure while importing a file. The [message] is safe to show
/// directly in a SnackBar.
class FileImportException implements Exception {
  const FileImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Imports study material from local files, fully on-device.
///
/// Phase 9A handles `.txt`; Phase 9B adds text-based `.pdf` extraction. Both
/// return the same [ImportedFile] so the rest of the import flow (preview →
/// edit → StudyDocument) stays identical regardless of source.
class FileImportService {
  const FileImportService();

  /// Caps extracted text so a huge document can't freeze the editor or the
  /// on-device summary. ~100k characters is far more than any lecture handout.
  static const int _maxChars = 100000;

  /// Opens the OS picker for a `.txt` file and reads its text locally.
  ///
  /// Returns `null` if the user cancels the picker. Throws a
  /// [FileImportException] with a friendly message if the chosen file isn't a
  /// `.txt`, can't be read, or has no usable text.
  Future<ImportedFile?> pickTextFile() async {
    const typeGroup = XTypeGroup(
      label: 'Text files',
      extensions: <String>['txt'],
      // Android filters by MIME type rather than extension.
      mimeTypes: <String>['text/plain'],
      uniformTypeIdentifiers: <String>['public.plain-text'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file == null) return null; // cancelled

    final name = file.name;
    if (!name.toLowerCase().endsWith('.txt')) {
      throw const FileImportException(
        'Please choose a .txt file. Other formats are not supported yet.',
      );
    }

    final content = await _readText(file);
    if (content.trim().isEmpty) {
      throw const FileImportException('This file has no readable text.');
    }
    return ImportedFile(text: _cap(content), fileName: name);
  }

  /// Opens the OS picker for a `.pdf` file and extracts its text locally.
  ///
  /// Returns `null` if the user cancels the picker. Throws a
  /// [FileImportException] with a friendly message for protected, corrupt or
  /// scanned/image-only PDFs (which have no extractable text).
  Future<ImportedFile?> pickPdfFile() async {
    const typeGroup = XTypeGroup(
      label: 'PDF files',
      extensions: <String>['pdf'],
      mimeTypes: <String>['application/pdf'],
      uniformTypeIdentifiers: <String>['com.adobe.pdf'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file == null) return null; // cancelled

    final name = file.name;
    if (!name.toLowerCase().endsWith('.pdf')) {
      throw const FileImportException(
        'Please choose a .pdf file. Other formats are not supported yet.',
      );
    }

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      throw const FileImportException(
        'Could not read this PDF. Try another file or paste the text instead.',
      );
    }

    final text = await extractPdfText(bytes);
    return ImportedFile(text: text, fileName: name);
  }

  /// Extracts text from in-memory PDF [bytes]. Runs the parse on a background
  /// isolate so large PDFs don't jank the UI. Throws a [FileImportException]
  /// for protected, corrupt or scanned/no-text PDFs. Exposed for testing and
  /// reused by [pickPdfFile].
  Future<String> extractPdfText(Uint8List bytes) async {
    final result = await compute(_extractPdfText, bytes);
    switch (result.error) {
      case _PdfErrorKind.encrypted:
        throw const FileImportException(
          'This PDF is protected and cannot be read.',
        );
      case _PdfErrorKind.corrupt:
        throw const FileImportException(
          'Could not read this PDF. Try another file or paste the text instead.',
        );
      case null:
        break;
    }

    final text = result.text ?? '';
    if (text.trim().isEmpty) {
      throw const FileImportException(
        'This PDF looks like a scanned/image-based file, so there is no text '
        'to extract. OCR support will be added in a future version.',
      );
    }
    return _cap(text);
  }

  /// Reads an [XFile] as UTF-8, falling back to a lenient decode so an unusual
  /// encoding produces best-effort text instead of crashing.
  Future<String> _readText(XFile file) async {
    try {
      return await file.readAsString();
    } on FormatException {
      try {
        final bytes = await file.readAsBytes();
        return utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        throw const FileImportException("Couldn't read this file.");
      }
    } catch (_) {
      throw const FileImportException("Couldn't read this file.");
    }
  }

  /// Truncates overly long text to keep the editor and summary responsive.
  String _cap(String text) =>
      text.length <= _maxChars ? text : text.substring(0, _maxChars);
}

/// Outcome kinds the isolate can report back without throwing across the
/// isolate boundary.
enum _PdfErrorKind { encrypted, corrupt }

/// The isolate-safe result of a PDF extraction attempt.
class _PdfExtraction {
  const _PdfExtraction({this.text, this.error});

  final String? text;
  final _PdfErrorKind? error;
}

/// Parses [bytes] and extracts text. Top-level so it can run via [compute].
/// Distinguishes encrypted PDFs (caught at load time) from other failures.
_PdfExtraction _extractPdfText(Uint8List bytes) {
  PdfDocument document;
  try {
    document = PdfDocument(inputBytes: bytes);
  } catch (e) {
    final message = e.toString().toLowerCase();
    final encrypted = message.contains('password') ||
        message.contains('encrypt') ||
        message.contains('protected');
    return _PdfExtraction(
      error: encrypted ? _PdfErrorKind.encrypted : _PdfErrorKind.corrupt,
    );
  }

  try {
    final text = PdfTextExtractor(document).extractText();
    return _PdfExtraction(text: text);
  } catch (_) {
    return const _PdfExtraction(error: _PdfErrorKind.corrupt);
  } finally {
    document.dispose();
  }
}
