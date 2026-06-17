/// Configuration values for Google Sign-In.
class AuthConfig {
  AuthConfig._();

  /// The Firebase "Web client" OAuth 2.0 client ID.
  ///
  /// Google Sign-In needs this as the server client id so it can return an
  /// idToken that Firebase Auth accepts. Find it after creating the Firebase
  /// project under Authentication > Sign-in method > Google > Web SDK
  /// configuration, or as the `client_type: 3` entry in google-services.json.
  ///
  /// Provide it at run time with:
  ///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
  /// (or replace the empty default below).
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
