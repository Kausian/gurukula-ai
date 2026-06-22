import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../data/models/enums.dart';
import '../../services/file_import_service.dart';
import '../../services/ocr_service.dart';
import '../study/import_preview_screen.dart';

/// Upload landing screen: interactive input-method cards.
///
/// Paste-text and PDF flows are wired up in Phase 4 / Phase 7; here each option
/// shows its readiness state.
class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  /// Picks a local `.txt` file, reads it on-device, and opens the preview.
  Future<void> _importTextFile(BuildContext context) => _runImport(
        context,
        const FileImportService().pickTextFile(),
        DocumentType.text,
        'Reading file…',
      );

  /// Picks a local `.pdf` file, extracts its text on-device, and opens the
  /// preview.
  Future<void> _importPdfFile(BuildContext context) => _runImport(
        context,
        const FileImportService().pickPdfFile(),
        DocumentType.pdf,
        'Extracting text…',
      );

  /// Lets the student choose between gallery and camera, then runs on-device
  /// OCR on the chosen image (Phase 14B gallery, 14C camera).
  void _scanNotes(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pick from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _scanFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _scanFromCamera(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _scanFromGallery(BuildContext context) => _runImport(
        context,
        const OcrService().pickImageAndExtract(),
        DocumentType.image,
        'Recognising text…',
      );

  Future<void> _scanFromCamera(BuildContext context) => _runImport(
        context,
        const OcrService().captureImageAndExtract(),
        DocumentType.image,
        'Recognising text…',
      );

  /// Shared import handler: show a loading overlay while the [picker] runs
  /// (extraction can take a second or two), open the preview on success, stay
  /// silent on cancel, and surface friendly errors as a SnackBar. The overlay
  /// is dismissed on every path so it can never get stuck.
  Future<void> _runImport(
    BuildContext context,
    Future<ImportedFile?> picker,
    DocumentType type,
    String loadingMessage,
  ) async {
    // Capture these before the async gap so we don't use `context` afterwards.
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    _showLoading(context, loadingMessage);
    try {
      final imported = await picker;
      navigator.pop(); // dismiss the loading overlay
      if (imported == null) return; // cancelled
      router.push(
        '/import-preview',
        extra: ImportPreviewArgs(
          text: imported.text,
          fileName: imported.fileName,
          type: type,
        ),
      );
    } on FileImportException catch (e) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  void _showLoading(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 18),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            const PageHeader(
              title: 'Upload',
              subtitle: 'Turn notes into summaries, flashcards and tools.',
            ),
            const SizedBox(height: 22),
            _OptionCard(
              accent: AppAccents.lavender.fill,
              icon: Icons.content_paste_rounded,
              title: 'Paste text',
              subtitle: 'Drop in lecture notes or any text.',
              onTap: () => context.push('/paste'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.lime.fill,
              icon: Icons.picture_as_pdf_rounded,
              title: 'Upload PDF',
              subtitle: 'Import a text-based PDF and extract its text.',
              onTap: () => _importPdfFile(context),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.coral.fill,
              icon: Icons.document_scanner_rounded,
              title: 'Scan notes',
              subtitle:
                  'Best for clear printed English text. Handwriting may be inaccurate.',
              onTap: () => _scanNotes(context),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.mint.fill,
              icon: Icons.folder_open_rounded,
              title: 'Import from files',
              subtitle: 'Bring in a saved .txt document.',
              onTap: () => _importTextFile(context),
            ),
            const SizedBox(height: 22),

            // Privacy.
            AppCard(
              color: scheme.surfaceContainer,
              child: Row(
                children: [
                  IconChip(
                      icon: Icons.shield_rounded, color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Local-first processing. Nothing is sent to a server.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A large upload-method card with an icon chip, title and subtitle.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconChip(icon: icon, color: accent, size: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
