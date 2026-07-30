import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/utils/pin_hasher.dart';
import '../../data/local/app_storage.dart';
import '../../data/local/hive_boxes.dart';

/// Immutable Privacy Lock state (v1.21.0).
class PrivacyLockState {
  const PrivacyLockState({
    required this.enabled,
    required this.biometricEnabled,
    required this.hasPin,
    required this.unlocked,
  });

  /// Whether Privacy Lock is turned on.
  final bool enabled;

  /// Whether the user opted into biometric unlock (only meaningful when
  /// [enabled]).
  final bool biometricEnabled;

  /// Whether a PIN has been set.
  final bool hasPin;

  /// Whether the app is unlocked for this session.
  final bool unlocked;

  /// The lock screen should be shown when the lock is active but not yet
  /// unlocked. A missing PIN can never lock the user out.
  bool get isLocked => enabled && hasPin && !unlocked;

  PrivacyLockState copyWith({
    bool? enabled,
    bool? biometricEnabled,
    bool? hasPin,
    bool? unlocked,
  }) {
    return PrivacyLockState(
      enabled: enabled ?? this.enabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

/// Persists Privacy Lock preferences locally (settings box) and drives the
/// lock/unlock lifecycle. No PIN is ever stored in plain text — only a salted
/// hash (see [PinHasher]).
final privacyLockControllerProvider =
    NotifierProvider<PrivacyLockController, PrivacyLockState>(
        PrivacyLockController.new);

class PrivacyLockController extends Notifier<PrivacyLockState> {
  static const _kEnabled = 'privacyLockEnabled';
  static const _kBiometric = 'privacyLockBiometric';
  static const _kPinHash = 'privacyLockPinHash';
  static const _kPinSalt = 'privacyLockPinSalt';

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.settings);

  @override
  PrivacyLockState build() {
    final enabled = _box.get(_kEnabled, defaultValue: false) as bool;
    final biometric = _box.get(_kBiometric, defaultValue: false) as bool;
    final hasPin = _box.get(_kPinHash) is String;
    // On a fresh app start the app is locked whenever the lock is active.
    return PrivacyLockState(
      enabled: enabled,
      biometricEnabled: biometric,
      hasPin: hasPin,
      unlocked: !(enabled && hasPin),
    );
  }

  bool _verify(String pin) {
    final salt = _box.get(_kPinSalt);
    final hash = _box.get(_kPinHash);
    if (salt is! String || hash is! String) return false;
    return PinHasher.verify(pin, salt, hash);
  }

  /// Turns on Privacy Lock with a freshly set [pin] (and optional biometric).
  /// The app stays unlocked for the current session after setup.
  Future<void> enable({required String pin, required bool biometric}) async {
    final salt = PinHasher.newSalt();
    await _box.put(_kPinSalt, salt);
    await _box.put(_kPinHash, PinHasher.hashPin(pin, salt));
    await _box.put(_kBiometric, biometric);
    await _box.put(_kEnabled, true);
    state = state.copyWith(
      enabled: true,
      biometricEnabled: biometric,
      hasPin: true,
      unlocked: true,
    );
  }

  /// Turns off Privacy Lock. Requires the current [pin] so it can't be disabled
  /// by someone who doesn't know it. Returns false if the PIN is wrong.
  Future<bool> disable(String pin) async {
    if (!_verify(pin)) return false;
    await _box.delete(_kPinHash);
    await _box.delete(_kPinSalt);
    await _box.put(_kBiometric, false);
    await _box.put(_kEnabled, false);
    state = state.copyWith(
      enabled: false,
      biometricEnabled: false,
      hasPin: false,
      unlocked: true,
    );
    return true;
  }

  /// Changes the PIN after confirming the current one. Returns false on
  /// mismatch.
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!_verify(currentPin)) return false;
    final salt = PinHasher.newSalt();
    await _box.put(_kPinSalt, salt);
    await _box.put(_kPinHash, PinHasher.hashPin(newPin, salt));
    return true;
  }

  /// Enables/disables biometric unlock (only relevant while the lock is on).
  Future<void> setBiometric(bool value) async {
    await _box.put(_kBiometric, value);
    state = state.copyWith(biometricEnabled: value);
  }

  /// Attempts to unlock with a PIN. Returns true on success.
  bool unlockWithPin(String pin) {
    if (_verify(pin)) {
      state = state.copyWith(unlocked: true);
      return true;
    }
    return false;
  }

  /// Marks the session unlocked after a successful biometric check.
  void unlockWithBiometric() => state = state.copyWith(unlocked: true);
}

/// Whether study-data boxes are encrypted at rest on this device (v1.22.0).
/// Set once during storage init, so a plain [Provider] reflecting the flag is
/// enough.
final storageProtectionActiveProvider =
    Provider<bool>((ref) => AppStorage.encryptionActive);

/// The device's biometric authenticator (v1.21.0).
final localAuthProvider =
    Provider<LocalAuthentication>((ref) => LocalAuthentication());

/// Whether this device can do biometric authentication right now. Never throws.
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final auth = ref.read(localAuthProvider);
  try {
    final supported = await auth.isDeviceSupported();
    final canCheck = await auth.canCheckBiometrics;
    return supported && canCheck;
  } catch (_) {
    return false;
  }
});

/// Runs a biometric prompt. Returns true only on a confirmed success; never
/// throws, so a failure simply falls back to the PIN.
Future<bool> runBiometricUnlock(LocalAuthentication auth) async {
  try {
    return await auth.authenticate(
      localizedReason: 'Unlock Gurukula AI',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (_) {
    return false;
  }
}
