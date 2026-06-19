import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/enums.dart';
import '../../services/file_import_service.dart';
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
      );

  /// Picks a local `.pdf` file, extracts its text on-device, and opens the
  /// preview.
  Future<void> _importPdfFile(BuildContext context) => _runImport(
        context,
        const FileImportService().pickPdfFile(),
        DocumentType.pdf,
      );

  /// Shared import handler: await the [picker], open the preview on success,
  /// stay silent on cancel, and surface friendly errors as a SnackBar.
  Future<void> _runImport(
    BuildContext context,
    Future<ImportedFile?> picker,
    DocumentType type,
  ) async {
    try {
      final imported = await picker;
      if (imported == null || !context.mounted) return; // cancelled
      context.push(
        '/import-preview',
        extra: ImportPreviewArgs(
          text: imported.text,
          fileName: imported.fileName,
          type: type,
        ),
      );
    } on FileImportException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't import this file.")),
        );
      }
    }
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
              badge: const StatusBadge(label: 'Ready', tone: BadgeTone.success),
              onTap: () => context.push('/paste'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.lime.fill,
              icon: Icons.picture_as_pdf_rounded,
              title: 'Upload PDF',
              subtitle: 'Import a text-based PDF and extract its text.',
              badge: const StatusBadge(label: 'Ready', tone: BadgeTone.success),
              onTap: () => _importPdfFile(context),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.coral.fill,
              icon: Icons.document_scanner_rounded,
              title: 'Scan notes',
              subtitle: 'Capture handwritten or printed notes.',
              badge: const StatusBadge(label: 'Later', tone: BadgeTone.neutral),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              accent: AppAccents.mint.fill,
              icon: Icons.folder_open_rounded,
              title: 'Import from files',
              subtitle: 'Bring in a saved .txt document.',
              badge: const StatusBadge(label: 'Ready', tone: BadgeTone.success),
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

/// A large upload-method card with an icon chip, copy and a status badge.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;
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
                Row(
                  children: [
                    Expanded(
                        child:
                            Text(title, style: theme.textTheme.titleMedium)),
                    const SizedBox(width: 8),
                    badge,
                  ],
                ),
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
