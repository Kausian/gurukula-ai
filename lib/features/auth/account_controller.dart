import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/user_profile.dart';
import '../../data/providers.dart';
import '../../data/repositories/profile_repository.dart';
import '../../services/app_data_reset_service.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';

/// Student profile fields collected during sign up / profile completion
/// (v1.26.0). Deliberately small: no phone, DOB, gender or address.
class StudentDetails {
  const StudentDetails({
    required this.fullName,
    required this.studyLevel,
    required this.subject,
    required this.studyGoal,
    this.institution,
  });

  final String fullName;
  final String studyLevel;
  final String subject;
  final String studyGoal;
  final String? institution;
}

final accountControllerProvider =
    Provider<AccountController>((ref) => AccountController(ref));

/// Orchestrates the redesigned auth flow (v1.26.0): email sign in/up, Google
/// sign in, and saving the local student profile. Identity comes from Firebase;
/// the student profile stays local-first in Hive.
class AccountController {
  AccountController(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  AuthService get _auth => _ref.read(authServiceProvider);
  ProfileRepository get _profiles => _ref.read(profileRepositoryProvider);

  Future<void> signInWithGoogle() => _auth.signInWithGoogle();

  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithEmail(email: email, password: password);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  /// Creates a Firebase email account, then saves the local student profile so
  /// the router sees a claimed profile and continues to onboarding/home.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required StudentDetails details,
  }) async {
    final credential =
        await _auth.signUpWithEmail(email: email, password: password);
    final user = credential.user;
    if (user != null) {
      await _saveProfile(user: user, details: details);
    }
  }

  /// Saves/updates the local student profile for the currently signed-in user
  /// (used by the Google "complete your profile" step).
  Future<void> saveProfileForCurrentUser(StudentDetails details) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _saveProfile(user: user, details: details);
  }

  // ---- Account deletion (v1.27.0) ----

  /// Whether the signed-in account uses email/password (so the delete flow
  /// should collect the password for re-authentication).
  bool get isPasswordAccount => _auth.currentProviderIds().contains('password');

  /// Deletes the Firebase account, re-authenticating if Firebase requires a
  /// recent login, then wipes all local data and signs out.
  ///
  /// Firebase is deleted FIRST: local data is only wiped after the account is
  /// gone, so a failed deletion never silently loses local data. Throws on
  /// failure (e.g. wrong password, cancelled Google re-auth) with local data
  /// left intact.
  Future<void> deleteAccount({String? password}) async {
    final providers = _auth.currentProviderIds();
    try {
      await _auth.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;
      // Re-authenticate, then retry the delete.
      if (providers.contains('password')) {
        if (password == null || password.isEmpty) {
          throw FirebaseAuthException(
              code: 'requires-recent-login', message: e.message);
        }
        await _auth.reauthenticateWithPassword(password);
      } else if (providers.contains('google.com')) {
        await _auth.reauthenticateWithGoogle();
      } else {
        rethrow;
      }
      await _auth.deleteAccount();
    }

    // Account is gone -> safe to wipe local data, then clear the session.
    await _ref.read(appDataResetProvider).wipeAllLocalData();
    await _auth.signOut();
  }

  Future<void> _saveProfile({
    required User user,
    required StudentDetails details,
  }) async {
    final existing = _profiles.current;
    final now = DateTime.now().toUtc();
    final institution = details.institution?.trim();

    await _profiles.save(
      UserProfile(
        id: existing?.id ?? _uuid.v4(),
        googleUid: user.uid,
        email: user.email,
        displayName: details.fullName.trim().isEmpty
            ? user.displayName
            : details.fullName.trim(),
        photoUrl: user.photoURL,
        username: details.fullName.trim().isEmpty
            ? (user.displayName ?? 'Student')
            : details.fullName.trim(),
        studyLevel: details.studyLevel,
        mainSubject: details.subject.trim(),
        learningGoal: details.studyGoal,
        preferredLanguage: existing?.preferredLanguage ?? 'English',
        institution: (institution == null || institution.isEmpty)
            ? null
            : institution,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
    _ref.invalidate(currentProfileProvider);
  }
}

/// Maps a [FirebaseAuthException] to a short, student-friendly message.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled yet. Please continue with Google.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'requires-recent-login':
        return 'For your security, please re-enter your password (or sign in '
            'again) to delete your account.';
    }
  }
  return 'Something went wrong. Please try again.';
}

/// Shared study-level and study-goal options for the student forms (v1.26.0).
const List<String> kStudyLevels = [
  'School',
  'University',
  'Self-study',
  'Other',
];

const List<String> kStudyGoals = [
  'Exams',
  'Assignments',
  'Revision',
  'Projects',
  'Other',
];
