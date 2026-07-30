import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hashes and verifies the Privacy Lock PIN (v1.21.0).
///
/// The PIN is never stored in plain text. We store a random per-install salt
/// plus a salted, iterated SHA-256 hash of the PIN. This is a reasonable
/// deterrent-level protection for a local, offline lock (full at-rest
/// encryption is intentionally out of scope for this release).
class PinHasher {
  PinHasher._();

  /// Iteration count — high enough to slow brute force on short PINs, low
  /// enough to stay instant on the UI thread.
  static const int _iterations = 20000;

  /// A fresh, cryptographically random salt, base64 encoded.
  static String newSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Encode(bytes);
  }

  /// Salted, iterated SHA-256 hash of [pin] as a hex string.
  static String hashPin(String pin, String salt) {
    var digest = sha256.convert(utf8.encode('$salt|$pin'));
    for (var i = 0; i < _iterations; i++) {
      digest = sha256.convert(digest.bytes);
    }
    return digest.toString();
  }

  /// Constant-time-ish comparison of a candidate PIN against a stored hash.
  static bool verify(String pin, String salt, String expectedHash) {
    final actual = hashPin(pin, salt);
    if (actual.length != expectedHash.length) return false;
    var mismatch = 0;
    for (var i = 0; i < actual.length; i++) {
      mismatch |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return mismatch == 0;
  }
}
