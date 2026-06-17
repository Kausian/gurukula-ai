import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/local/hive_init.dart';
import 'data/local/seed_data.dart';

Future<void> main() async {
  // Required before any async work prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Local-first storage: open Hive boxes, then seed sample data once.
  await initHive();
  await SeedData.seedIfNeeded();

  // ProviderScope is the root of Riverpod state management for the whole app.
  runApp(const ProviderScope(child: GurukulaApp()));
}
