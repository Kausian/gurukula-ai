import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope is the root of Riverpod state management for the whole app.
  runApp(const ProviderScope(child: GurukulaApp()));
}
