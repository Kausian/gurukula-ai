import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Manages the local AES key used to encrypt study-data Hive boxes (v1.22.0).
///
/// The key is a random 256-bit key generated once and kept only in the
/// platform secure store (Android Keystore-backed), never in a plain Hive box
/// and never derived from the user's PIN. If the secure store is unavailable
/// the caller runs unencrypted rather than risk losing data.
class EncryptionKeyStore {
  EncryptionKeyStore._();

  static const _storageKey = 'gurukula_hive_key_v1';

  // Defaults to Android Keystore-backed encrypted storage in v10+.
  static const _storage = FlutterSecureStorage();

  /// Returns the existing key, or creates and persists a new one. Returns null
  /// if the secure store cannot be used (so the app can fall back to
  /// unencrypted storage instead of failing).
  static Future<List<int>?> getOrCreateKey() async {
    try {
      final existing = await _storage.read(key: _storageKey);
      if (existing != null && existing.isNotEmpty) {
        final key = base64Decode(existing);
        if (key.length == 32) return key;
      }
      final key = Hive.generateSecureKey();
      await _storage.write(key: _storageKey, value: base64Encode(key));
      return key;
    } catch (_) {
      // Keystore/plugin unavailable or read/write failed. Do not throw — the
      // caller keeps data unencrypted rather than risk a lockout or data loss.
      return null;
    }
  }
}
