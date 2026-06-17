import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_event.dart';
import '../models/enums.dart';
import '../models/flashcard.dart';
import '../models/idea.dart';
import '../models/study_document.dart';
import '../models/summary.dart';
import '../models/user_profile.dart';
import 'hive_boxes.dart';

/// Seeds realistic sample data on first launch so the dashboard, Library and
/// Profile have something to show before real upload/AI flows exist.
///
/// Idempotent: guarded by a flag in the settings box, so it runs only once.
class SeedData {
  SeedData._();

  static const _uuid = Uuid();

  static Future<void> seedIfNeeded() async {
    final settings = Hive.box<dynamic>(HiveBoxes.settings);
    if (settings.get(HiveBoxes.seededKey) == true) return;

    final profiles = Hive.box<UserProfile>(HiveBoxes.profiles);
    final documents = Hive.box<StudyDocument>(HiveBoxes.documents);
    final summaries = Hive.box<Summary>(HiveBoxes.summaries);
    final flashcards = Hive.box<Flashcard>(HiveBoxes.flashcards);
    final ideas = Hive.box<Idea>(HiveBoxes.ideas);
    final activity = Hive.box<ActivityEvent>(HiveBoxes.activity);

    final now = DateTime.now().toUtc();
    final userId = _uuid.v4();
    final events = <ActivityEvent>[];

    ActivityEvent event(
        ActivityType type, String refId, String title, DateTime at) {
      return ActivityEvent(
        id: _uuid.v4(),
        userId: userId,
        type: type,
        referenceId: refId,
        title: title,
        createdAt: at,
      );
    }

    // ---- Profile ----
    await profiles.put(
      userId,
      UserProfile(
        id: userId,
        displayName: 'Kausian',
        username: 'Kausian',
        studyLevel: 'University',
        mainSubject: 'Computer Science',
        learningGoal: 'Prepare for exams and build better projects',
        preferredLanguage: 'English',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    );

    // ---- Document 1: Operating Systems ----
    final doc1Id = _uuid.v4();
    final doc1At = now.subtract(const Duration(days: 3));
    await documents.put(
      doc1Id,
      StudyDocument(
        id: doc1Id,
        userId: userId,
        title: 'Operating Systems: Deadlocks',
        type: DocumentType.text,
        rawText:
            'A deadlock is a state where processes are blocked because each '
            'holds a resource and waits for another.',
        cleanedText:
            'A deadlock is a state where processes are blocked because each '
            'holds a resource and waits for another.',
        createdAt: doc1At,
        updatedAt: doc1At,
      ),
    );
    events.add(event(ActivityType.documentUploaded, doc1Id,
        'Operating Systems: Deadlocks', doc1At));

    final sum1Id = _uuid.v4();
    await summaries.put(
      sum1Id,
      Summary(
        id: sum1Id,
        documentId: doc1Id,
        shortSummary:
            'Deadlocks happen when processes wait on each other in a cycle. '
            'They need four conditions to occur and can be prevented or avoided.',
        detailedSummary:
            'A deadlock occurs when a set of processes are each waiting for a '
            'resource held by another. The four Coffman conditions are mutual '
            'exclusion, hold and wait, no preemption, and circular wait. '
            'Strategies include prevention, avoidance (Banker\'s algorithm), '
            'detection and recovery.',
        keyPoints: const [
          'Four Coffman conditions cause deadlock',
          'Circular wait is the key condition to break',
          'Banker\'s algorithm avoids unsafe states',
          'Detection plus recovery is an alternative to prevention',
        ],
        createdAt: doc1At,
      ),
    );
    events.add(
        event(ActivityType.summaryCreated, sum1Id, 'Deadlocks summary', doc1At));

    final doc1Cards = <List<dynamic>>[
      [
        'What are the four Coffman conditions for deadlock?',
        'Mutual exclusion, hold and wait, no preemption, and circular wait.',
        Difficulty.medium,
      ],
      [
        'Which condition does resource ordering remove?',
        'Circular wait.',
        Difficulty.easy,
      ],
      [
        'What does the Banker\'s algorithm guarantee?',
        'It only grants requests that keep the system in a safe state.',
        Difficulty.hard,
      ],
    ];
    for (final card in doc1Cards) {
      final id = _uuid.v4();
      await flashcards.put(
        id,
        Flashcard(
          id: id,
          documentId: doc1Id,
          question: card[0] as String,
          answer: card[1] as String,
          difficulty: card[2] as Difficulty,
          isReviewed: false,
          createdAt: doc1At,
        ),
      );
    }
    events.add(event(ActivityType.flashcardCreated, doc1Id,
        '3 flashcards from Deadlocks', doc1At));

    // ---- Document 2: Neural Networks ----
    final doc2Id = _uuid.v4();
    final doc2At = now.subtract(const Duration(days: 1));
    await documents.put(
      doc2Id,
      StudyDocument(
        id: doc2Id,
        userId: userId,
        title: 'Neural Networks: The Basics',
        type: DocumentType.text,
        rawText:
            'A neural network is made of layers of neurons that transform '
            'inputs using weights and an activation function.',
        cleanedText:
            'A neural network is made of layers of neurons that transform '
            'inputs using weights and an activation function.',
        createdAt: doc2At,
        updatedAt: doc2At,
      ),
    );
    events.add(event(ActivityType.documentUploaded, doc2Id,
        'Neural Networks: The Basics', doc2At));

    final doc2Cards = <List<dynamic>>[
      [
        'What does an activation function add to a network?',
        'Non-linearity, so the network can model complex patterns.',
        Difficulty.medium,
      ],
      [
        'What is backpropagation used for?',
        'Updating weights by propagating the error gradient backwards.',
        Difficulty.medium,
      ],
    ];
    for (final card in doc2Cards) {
      final id = _uuid.v4();
      await flashcards.put(
        id,
        Flashcard(
          id: id,
          documentId: doc2Id,
          question: card[0] as String,
          answer: card[1] as String,
          difficulty: card[2] as Difficulty,
          isReviewed: false,
          createdAt: doc2At,
        ),
      );
    }
    events.add(event(ActivityType.flashcardCreated, doc2Id,
        '2 flashcards from Neural Networks', doc2At));

    // ---- Idea ----
    final ideaId = _uuid.v4();
    final ideaAt = now.subtract(const Duration(hours: 5));
    await ideas.put(
      ideaId,
      Idea(
        id: ideaId,
        userId: userId,
        title: 'Offline StudyPilot AI',
        problem:
            'Students cannot always rely on internet or paid AI tools to study.',
        targetUsers: const ['University students', 'Self-learners'],
        features: const [
          'Summarize notes offline',
          'Generate flashcards',
          'Build project ideas',
        ],
        techStack: const ['Flutter', 'Kotlin', 'On-device AI', 'Hive'],
        difficulty: Difficulty.medium,
        mvpPlan:
            'Start with paste-text summaries and flashcards using a mock AI '
            'service, then add on-device AI.',
        notes: 'Strong CV project: shows offline-first and native integration.',
        createdAt: ideaAt,
        updatedAt: ideaAt,
      ),
    );
    events.add(
        event(ActivityType.ideaSaved, ideaId, 'Offline StudyPilot AI', ideaAt));

    // ---- Persist activity + mark as seeded ----
    await activity.putAll({for (final e in events) e.id: e});
    await settings.put(HiveBoxes.seededKey, true);
  }
}
