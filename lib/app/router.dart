import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/idea_lab/idea_lab_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/upload/upload_screen.dart';

/// Navigator key for the root (outside the bottom-nav shell).
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralised navigation for Gurukula AI.
///
/// The Welcome screen is the entry point. The 5 primary tabs live inside a
/// [StatefulShellRoute] so each tab keeps its own navigation stack when the
/// user switches between them.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/upload',
              builder: (context, state) => const UploadScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/idea-lab',
              builder: (context, state) => const IdeaLabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
