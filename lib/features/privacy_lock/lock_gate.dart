import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lock_screen.dart';
import 'privacy_lock_providers.dart';

/// Wraps the whole app (via [MaterialApp.builder]) and overlays the
/// [LockScreen] while Privacy Lock is active and not yet unlocked (v1.21.0).
///
/// Placed above the router's navigator, so it covers every route until the
/// student unlocks. When the lock is off (the default), it renders [child]
/// unchanged, so existing behavior is untouched.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(
        privacyLockControllerProvider.select((state) => state.isLocked));

    return Stack(
      children: [
        child,
        if (locked)
          const Positioned.fill(
            child: LockScreen(),
          ),
      ],
    );
  }
}
