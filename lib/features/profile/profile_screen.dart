import 'package:flutter/material.dart';
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

/// Profile: student card, study stats, AI status, settings and about.
///
/// The student card and stats read from local data. Google Sign-In replaces
/// the seeded profile in Phase 3; settings become functional in Phase 8.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a later phase')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(currentProfileProvider);
    final stats = ref.watch(dashboardStatsProvider);

    final name = profile?.username ?? 'Guest student';
    final subtitle = profile == null
        ? 'Sign in to personalise your space.'
        : '${profile.studyLevel} · ${profile.mainSubject}';

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
                    child: Icon(Icons.person_rounded,
                        size: 36, color: scheme.primary),
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
                          label: profile == null
                              ? 'Not signed in'
                              : 'Local profile',
                          tone: profile == null
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
            const SizedBox(height: 28),

            // AI status.
            const SectionHeader(title: 'AI and offline status'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: const [
                  _StatusRow(
                      label: 'Gemini Nano',
                      badge: StatusBadge(
                          label: 'Mock mode', tone: BadgeTone.neutral)),
                  Divider(height: 1),
                  _StatusRow(
                      label: 'Offline AI',
                      badge: StatusBadge(
                          label: 'Ready', tone: BadgeTone.success)),
                  Divider(height: 1),
                  _StatusRow(
                      label: 'Local storage',
                      badge: StatusBadge(
                          label: 'Ready', tone: BadgeTone.success)),
                  Divider(height: 1),
                  _StatusRow(
                      label: 'OCR',
                      badge:
                          StatusBadge(label: 'Later', tone: BadgeTone.neutral)),
                ],
              ),
            ),
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
                      value: 'System',
                      onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.translate_rounded,
                      label: 'Language',
                      value: profile?.preferredLanguage ?? 'English',
                      onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.short_text_rounded,
                      label: 'Summary length',
                      value: 'Medium',
                      onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _SettingRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Privacy',
                      onTap: () => _comingSoon(context)),
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
                  Text('${AppStrings.tagline}. Version 1.0.0',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text('Flutter · Riverpod · Hive · Material 3 · On-device AI',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
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
            if (value != null) ...[
              Text(value!, style: theme.textTheme.bodySmall),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded,
                size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
