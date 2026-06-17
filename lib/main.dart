import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/local/hive_init.dart';
import 'data/local/seed_data.dart';

Future<void> main() async {
  // Required before any async work prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (identity only). On Android this reads android/app/google-services.json.
  // After running `flutterfire configure`, you may switch to:
  //   Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
  await Firebase.initializeApp();

  // Local-first storage: open Hive boxes, then seed sample data once.
  await initHive();
  await SeedData.seedIfNeeded();

  runApp(const ProviderScope(child: GurukulaApp()));
}
