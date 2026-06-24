import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/providers.dart';
import '../../services/ai_service.dart';
import '../auth/auth_providers.dart';
import '../settings/settings_providers.dart';
import '../study/study_providers.dart';

/// Profile: student card, study stats, AI status, settings and about.
///
/// The student card and stats read from local data. Google Sign-In replaces
/// the seeded profile in Phase 3; settings become functional in Phase 8.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(currentProfileProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    final aiMode = ref.watch(aiModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final version = ref.watch(appVersionProvider);

    final name = profile?.username ?? user?.displayName ?? 'Guest student';
    final subtitle = profile == null
        ? 'Sign in to personalise your space.'
        : '${profile.studyLevel} · ${profile.mainSubject}';
    final photoUrl = profile?.photoUrl ?? user?.photoURL;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            const PageHeader(title: 'Profile'),
            const SizedBox(height: 20),

            // Student card.
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.primary.withValues(alpha: 0.16),
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    // Swallow load failures (e.g. offline) so they don't throw;
                    // the avatar just shows the tinted circle / icon instead.
                    onBackgroundImageError:
                        photoUrl != null ? (_, _) {} : null,
                    child: photoUrl == null
                        ? Icon(Icons.person_rounded,
                            size: 36, color: scheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text(subtitle, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 10),
                        StatusBadge(
                          label: user == null ? 'Not signed in' : 'Signed in',
                          tone: user == null
                              ? BadgeTone.neutral
                              : BadgeTone.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Study stats.
            const SectionHeader(title: 'Study stats'),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                      icon: Icons.summarize_rounded,
                      value: '${stats.notes}',
                      label: 'Notes',
                      color: AppAccents.lavender.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.style_rounded,
                      value: '${stats.flashcards}',
                      label: 'Flashcards',
                      color: AppAccents.mint.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.lightbulb_rounded,
                      value: '${stats.ideas}',
                      label: 'Ideas',
                      color: AppAccents.coral.fill),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  IconChip(
                      icon: Icons.timeline_rounded, color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Total study sessions',
                        style: theme.textTheme.titleSmall),
                  ),
                  Text('${stats.sessions}',
                      style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  IconChip(icon: Icons.quiz_rounded, color: AppAccents.sky.fill),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Quizzes taken',
                        style: theme.textTheme.titleSmall),
                  ),
                  Text('${stats.quizzes}',
                      style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // AI status.
            const SectionHeader(title: 'AI and offline status'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _StatusRow(label: 'On-device AI', badge: _aiBadge(aiMode)),
                  const Divider(height: 1),
                  const _StatusRow(
                      label: 'Fallback mode',
                      badge: StatusBadge(
                          label: 'Active', tone: BadgeTone.success)),
                  const Divider(height: 1),
                  const _StatusRow(
                      label: 'Local storage',
                      badge: StatusBadge(
                          label: 'Ready', tone: BadgeTone.success)),
                  const Divider(height: 1),
                  const _StatusRow(
                      label: 'OCR',
                      badge:
                          StatusBadge(label: 'Ready', tone: BadgeTone.success)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _AiStatusHelp(mode: aiMode),
            const SizedBox(height: 28),

            // Settings.
            const SectionHeader(title: 'Settings'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingRow(
                      icon: Icons.brightness_6_rounded,
                      label: 'Theme',
                      value: _themeLabel(themeMode),
                      onTap: () => _pickTheme(context, ref)),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.translate_rounded,
                      label: 'Language',
                      value: profile?.preferredLanguage ?? 'English'),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Privacy',
                      onTap: () => _showPrivacy(context)),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Send feedback',
                      onTap: () => _sendFeedback(context)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About.
            const SectionHeader(title: 'About Gurukula'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.appName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    version.maybeWhen(
                      data: (v) => '${AppStrings.tagline}. Version $v',
                      orElse: () => '${AppStrings.tagline}.',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text('Flutter · Riverpod · Hive · Material 3 · On-device AI',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Delete local data.
            AppCard(
              onTap: () => _confirmDelete(context, ref),
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 22, color: scheme.error),
                  const SizedBox(width: 14),
                  Text('Delete local data',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: scheme.error)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sign out.
            AppCard(
              onTap: () => _signOut(context, ref),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 22, color: scheme.error),
                  const SizedBox(width: 14),
                  Text('Sign out',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: scheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeProvider);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          for (final mode in ThemeMode.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, mode),
              child: Row(
                children: [
                  Icon(
                    mode == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: mode == current
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 14),
                  Text(_themeLabel(mode)),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(themeModeProvider.notifier).set(selected);
    }
  }

  void _sendFeedback(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send feedback'),
        content: const Text(
          "We'd love your feedback or to hear about any issues. Email us at:"
          '\n\n${AppStrings.feedbackEmail}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              await Clipboard.setData(
                  const ClipboardData(text: AppStrings.feedbackEmail));
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Email copied')),
              );
            },
            child: const Text('Copy email'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your privacy'),
        content: const Text(
          'All your study data is stored only on this device, using local '
          'storage. Nothing is uploaded to a server. Google Sign-In is used '
          'for identity only.',
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it')),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete local data?'),
        content: const Text(
          'This permanently removes all notes, summaries, flashcards, ideas '
          'and quizzes from this device. Your profile stays. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await deleteLocalStudyData(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local study data deleted')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).signOut();
      // The auth gate redirects to /welcome automatically.
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out. Please try again.')),
        );
      }
    }
  }
}

/// Maps the on-device AI availability to a status badge.
StatusBadge _aiBadge(AsyncValue<AiAvailability> mode) {
  return mode.when(
    loading: () =>
        const StatusBadge(label: 'Checking', tone: BadgeTone.neutral),
    error: (_, _) =>
        const StatusBadge(label: 'Mock mode', tone: BadgeTone.neutral),
    data: (availability) {
      switch (availability) {
        case AiAvailability.available:
          return const StatusBadge(label: 'Available', tone: BadgeTone.success);
        case AiAvailability.downloading:
          return const StatusBadge(label: 'Downloading', tone: BadgeTone.info);
        case AiAvailability.unsupported:
          return const StatusBadge(
              label: 'Not supported', tone: BadgeTone.neutral);
        case AiAvailability.mock:
          return const StatusBadge(label: 'Mock mode', tone: BadgeTone.neutral);
      }
    },
  );
}

/// A short, plain-language explanation under the AI status card (Phase 16B
/// follow-up), tailored to the current on-device AI availability.
class _AiStatusHelp extends StatelessWidget {
  const _AiStatusHelp({required this.mode});

  final AsyncValue<AiAvailability> mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = switch (mode.value) {
      AiAvailability.available =>
        'On-device AI is available for supported study features.',
      AiAvailability.downloading =>
        'On-device AI is preparing. Fallback mode will be used until it is '
            'ready.',
      _ => 'On-device AI is not available on this device yet. Gurukula AI '
          'will continue using fallback mode.',
    };
    final secondary =
        theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: secondary),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Your study data still stays on your device.',
                    style: secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A label-and-badge row used in the AI status card.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.badge});

  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          badge,
        ],
      ),
    );
  }
}

/// A tappable settings row with an icon, label and optional value.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: scheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            if (value != null) Text(value!, style: theme.textTheme.bodySmall),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: scheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}
