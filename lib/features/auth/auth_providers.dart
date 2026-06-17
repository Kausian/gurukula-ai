import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';

/// The single [AuthService] instance.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Streams the Firebase auth state (signed-in user or null).
///
/// Override this in tests to avoid touching Firebase.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// The currently signed-in Firebase user, or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
