import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_config.dart';

/// Wraps Google Sign-In + Firebase Authentication.
///
/// Identity only: a successful sign-in gives us the student's Google name,
/// email and photo. No study data ever leaves the device.
class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const serverClientId = AuthConfig.googleServerClientId;
    await _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _initialized = true;
  }

  /// Opens the Google account picker and signs in to Firebase.
  ///
  /// Throws if the user cancels or sign-in fails; callers should handle it.
  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  /// Creates a Firebase account with email + password (v1.26.0).
  ///
  /// Requires the Email/Password provider to be enabled in the Firebase
  /// Console; otherwise Firebase throws `operation-not-allowed`, which callers
  /// surface as a friendly message. Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs in with an existing email + password (v1.26.0).
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sends a password-reset email (v1.26.0). Firebase handles the email; the
  /// app never sees or stores the password.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Signs out of both Google and Firebase. Local study data is untouched.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ---- Account deletion (v1.27.0) ----

  /// The sign-in providers linked to the current account (e.g. 'password',
  /// 'google.com'), used to pick the right re-authentication path.
  List<String> currentProviderIds() =>
      _auth.currentUser?.providerData.map((p) => p.providerId).toList() ??
      const [];

  /// Deletes the Firebase account. May throw `requires-recent-login`, in which
  /// case the caller re-authenticates and retries.
  Future<void> deleteAccount() => _auth.currentUser?.delete() ?? Future.value();

  /// Re-authenticates an email/password user before a sensitive action.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) return;
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticates a Google user by re-running the Google sign-in and
  /// re-attaching the fresh credential.
  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _ensureInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await user.reauthenticateWithCredential(credential);
  }
}
