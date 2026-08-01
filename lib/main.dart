import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme.dart';
import 'data/local/hive_init.dart';
import 'data/local/seed_data.dart';

Future<void> main() async {
  // Required before any async work prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase (identity only). On Android this reads android/app/google-services.json.
    await Firebase.initializeApp();

    // Local-first storage: open Hive boxes (Encrypted Storage-aware). Seeding
    // is a safe no-op in production (v1.28.1).
    await initHive();
    await SeedData.seedIfNeeded();
  } catch (error, stack) {
    // Never leave the user stuck on the native splash screen (v1.29.0). If
    // startup init fails, show a small, recoverable message instead of a
    // frozen splash. Details go to the debug console only.
    debugPrint('Gurukula AI startup failed: $error\n$stack');
    runApp(const _StartupErrorApp());
    return;
  }

  runApp(const ProviderScope(child: GurukulaApp()));
}

/// Minimal fallback shown only if app startup initialization fails, so the user
/// sees a clear message and can retry (reopen the app) rather than a frozen
/// splash. No sensitive details are shown.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    "Couldn't start Gurukula AI",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please close and reopen the app. If this keeps happening, '
                    'reinstalling the app will fix it — your account can be '
                    'restored by signing in again.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
