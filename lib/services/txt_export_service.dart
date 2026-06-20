import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../core/utils/export_filename.dart';

/// Exports study content as a real `.txt` file (Phase 13).
///
/// Writes the text to a file in the app's cache, then opens the Android share
/// sheet so the student can "Save to Files", send to Drive, email, etc. This
/// needs no storage permission and is scoped-storage safe.
class TxtExportService {
  const TxtExportService();

  /// Writes [text] to `<fileBaseName>.txt` and shares it. Returns true when the
  /// share completed (false if the user dismissed it). Throws on write failure.
  Future<bool> exportAsTxt({
    required String text,
    required String fileBaseName,
  }) async {
    final name = sanitizeFileName(fileBaseName);
    final dir = await Directory.systemTemp.createTemp('gurukula_export');
    final file = File('${dir.path}/$name.txt');
    await file.writeAsString(text);

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        fileNameOverrides: ['$name.txt'],
      ),
    );
    return result.status == ShareResultStatus.success;
  }
}
