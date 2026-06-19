import 'dart:convert';

import 'package:file_selector/file_selector.dart';

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
/// Phase 9A handles `.txt`; Phase 9B will add `.pdf` text extraction here so
/// the rest of the import flow (preview → edit → StudyDocument) stays the same.
class FileImportService {
  const FileImportService();

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
    return ImportedFile(text: content, fileName: name);
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
}
