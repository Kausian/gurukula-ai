import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/auth/auth_providers.dart';
import '../features/home/home_screen.dart';
import '../features/idea_lab/idea_detail_screen.dart';
import '../features/idea_lab/idea_form_screen.dart';
import '../features/idea_lab/idea_lab_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/create_profile_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/study/paste_text_screen.dart';
import '../features/study/study_workspace_screen.dart';
import '../features/upload/upload_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router with an auth gate.
///
/// Redirects are driven by the Firebase auth state plus whether a local profile
/// has been claimed by the signed-in account:
///   not signed in        -> /welcome
///   signed in, no profile -> /create-profile
///   signed in + profile   -> the bottom-nav shell
final routerProvider = Provider<GoRouter>((ref) {
  // Bridges the auth StreamProvider to a Listenable go_router can refresh on.
  final refresh = ValueNotifier<AsyncValue<User?>>(const AsyncValue.loading());
  ref.listen<AsyncValue<User?>>(
    authStateProvider,
    (_, next) => refresh.value = next,
    fireImmediately: true,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = refresh.value;
      final location = state.matchedLocation;

      // Still resolving the session.
      if (auth.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final user = auth.value;
      if (user == null) {
        return location == '/welcome' ? null : '/welcome';
      }

      // Signed in: is there a local profile for this account yet?
      final claimed =
          ref.read(profileRepositoryProvider).byGoogleUid(user.uid) != null;
      if (!claimed) {
        return location == '/create-profile' ? null : '/create-profile';
      }

      // Fully onboarded: keep out of the auth/onboarding screens.
      if (location == '/splash' ||
          location == '/welcome' ||
          location == '/create-profile') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/upload',
                builder: (context, state) => const UploadScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/idea-lab',
                builder: (context, state) => const IdeaLabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
      // Full-screen study routes (above the bottom nav).
      GoRoute(
        path: '/paste',
        builder: (context, state) => const PasteTextScreen(),
      ),
      GoRoute(
        path: '/workspace/:id',
        builder: (context, state) =>
            StudyWorkspaceScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/idea-lab/new',
        builder: (context, state) => const IdeaFormScreen(),
      ),
      GoRoute(
        path: '/idea/:id',
        builder: (context, state) =>
            IdeaDetailScreen(ideaId: state.pathParameters['id']!),
      ),
    ],
  );
});
