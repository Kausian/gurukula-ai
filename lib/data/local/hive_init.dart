import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../hive_registrar.g.dart';
import '../models/activity_event.dart';
import '../models/flashcard.dart';
import '../models/idea.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../models/rewrite.dart';
import '../models/study_document.dart';
import '../models/summary.dart';
import '../models/user_profile.dart';
import 'hive_boxes.dart';

/// Initializes Hive and opens every box the app needs.
///
/// Must complete before [runApp] so repositories can read their boxes
/// synchronously. All study data lives here, on the device, only.
Future<void> initHive() async {
  await Hive.initFlutter();

  // Registers every generated TypeAdapter (see hive_registrar.g.dart).
  Hive.registerAdapters();

  await Future.wait([
    Hive.openBox<UserProfile>(HiveBoxes.profiles),
    Hive.openBox<StudyDocument>(HiveBoxes.documents),
    Hive.openBox<Summary>(HiveBoxes.summaries),
    Hive.openBox<Flashcard>(HiveBoxes.flashcards),
    Hive.openBox<Rewrite>(HiveBoxes.rewrites),
    Hive.openBox<Idea>(HiveBoxes.ideas),
    Hive.openBox<Quiz>(HiveBoxes.quizzes),
    Hive.openBox<QuizResult>(HiveBoxes.quizResults),
    Hive.openBox<ActivityEvent>(HiveBoxes.activity),
    Hive.openBox<dynamic>(HiveBoxes.settings),
  ]);
}
