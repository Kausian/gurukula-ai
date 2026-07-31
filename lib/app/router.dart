import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/auth/auth_landing_screen.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/idea_lab/idea_detail_screen.dart';
import '../features/idea_lab/idea_form_screen.dart';
import '../features/idea_lab/idea_lab_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/create_profile_screen.dart';
import '../features/onboarding/onboarding_providers.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/study_goal_form_screen.dart';
import '../features/planner/study_planner_screen.dart';
import '../features/privacy_lock/privacy_lock_settings_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/study/import_preview_screen.dart';
import '../features/study/note_editor_screen.dart';
import '../features/study/paste_text_screen.dart';
import '../features/study/quiz_screen.dart';
import '../features/study/revision_screen.dart';
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

  // Also refresh when the local student profile changes, so email sign-up
  // (which saves the profile after Firebase account creation) transitions
  // cleanly to onboarding/Home without a race (v1.26.0).
  final profileTick = ValueNotifier<int>(0);
  ref.listen(currentProfileProvider, (_, _) => profileTick.value++);
  ref.onDispose(profileTick.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([refresh, profileTick]),
    redirect: (context, state) {
      final auth = refresh.value;
      final location = state.matchedLocation;

      // v1.26.0 order: authenticate FIRST, then complete the student profile,
      // then onboarding. So a new user sees the Auth Landing before anything
      // else, and onboarding never precedes auth.

      // 1) Still resolving the Firebase session.
      if (auth.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      // 2) Signed out -> the auth screens (landing / login / sign up).
      const authRoutes = {'/welcome', '/login', '/signup'};
      final user = auth.value;
      if (user == null) {
        return authRoutes.contains(location) ? null : '/welcome';
      }

      // 3) Signed in but no local student profile -> complete it.
      final claimed =
          ref.read(profileRepositoryProvider).byGoogleUid(user.uid) != null;
      if (!claimed) {
        return location == '/create-profile' ? null : '/create-profile';
      }

      // 4) Signed in + profile, but onboarding not done -> onboarding.
      //    (/onboarding is left reachable when completed, so Profile's "View
      //    onboarding" still works; the onboarding screen navigates away on
      //    finish.)
      final onboarded = ref.read(onboardingCompletedProvider);
      if (!onboarded && location != '/onboarding') {
        return '/onboarding';
      }

      // 5) Fully ready: keep out of the pre-Home gate screens.
      const gateScreens = {
        '/splash',
        '/welcome',
        '/login',
        '/signup',
        '/create-profile',
      };
      if (gateScreens.contains(location)) {
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const AuthLandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
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
        path: '/import-preview',
        builder: (context, state) =>
            ImportPreviewScreen(args: state.extra as ImportPreviewArgs),
      ),
      GoRoute(
        path: '/workspace/:id',
        builder: (context, state) =>
            StudyWorkspaceScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/note/:id/edit',
        builder: (context, state) =>
            NoteEditorScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/idea-lab/new',
        builder: (context, state) => const IdeaFormScreen(),
      ),
      // Study Planner (v1.20.0).
      GoRoute(
        path: '/planner',
        builder: (context, state) => const StudyPlannerScreen(),
      ),
      GoRoute(
        path: '/planner/new',
        builder: (context, state) => const StudyGoalFormScreen(),
      ),
      GoRoute(
        path: '/planner/:id/edit',
        builder: (context, state) =>
            StudyGoalFormScreen(goalId: state.pathParameters['id']),
      ),
      // Privacy Lock settings (v1.21.0).
      GoRoute(
        path: '/privacy-lock',
        builder: (context, state) => const PrivacyLockSettingsScreen(),
      ),
      GoRoute(
        path: '/idea/:id',
        builder: (context, state) =>
            IdeaDetailScreen(ideaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) =>
            QuizScreen(quizId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/revision/:scope',
        builder: (context, state) =>
            RevisionScreen(scope: state.pathParameters['scope']!),
      ),
    ],
  );
});
