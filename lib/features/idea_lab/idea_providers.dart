import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/activity_event.dart';
import '../../data/models/enums.dart';
import '../../data/models/idea.dart';
import '../../data/providers.dart';
import '../../services/ai_service.dart';
import '../study/study_providers.dart';

/// All saved ideas, newest first.
final ideasListProvider = Provider<List<Idea>>((ref) {
  ref.watch(dataChangesProvider);
  final ideas = ref.watch(ideaRepositoryProvider).getAll()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return ideas;
});

/// A single idea by id (reactive).
final ideaByIdProvider = Provider.family<Idea?, String>((ref, id) {
  ref.watch(dataChangesProvider);
  return ref.watch(ideaRepositoryProvider).getById(id);
});

final ideaControllerProvider =
    Provider<IdeaController>((ref) => IdeaController(ref));

/// Generates, saves and refines project ideas via the [AiService] (mock for
/// now). All ideas live locally in Hive.
class IdeaController {
  IdeaController(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  AiService get _ai => _ref.read(aiServiceProvider);
  String get _userId => _ref.read(currentProfileProvider)?.id ?? 'local';

  Future<void> _log(ActivityType type, String referenceId, String title) {
    return _ref.read(activityRepositoryProvider).save(
          ActivityEvent(
            id: _uuid.v4(),
            userId: _userId,
            type: type,
            referenceId: referenceId,
            title: title,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Generates a draft idea (not yet saved) for the preview step.
  Future<AiIdea> generate(IdeaBrief brief) => _ai.generateIdea(brief);

  /// Persists a generated idea to Hive and returns its id.
  Future<String> save(AiIdea idea) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _ref.read(ideaRepositoryProvider).save(
          Idea(
            id: id,
            userId: _userId,
            title: idea.title,
            problem: idea.problem,
            targetUsers: idea.targetUsers,
            features: idea.features,
            techStack: idea.techStack,
            difficulty: idea.difficulty,
            mvpPlan: idea.mvpPlan,
            notes: '',
            createdAt: now,
            updatedAt: now,
            whyUnique: idea.whyUnique,
          ),
        );
    await _log(ActivityType.ideaSaved, id, idea.title);
    return id;
  }

  Future<void> improve(String ideaId, {String guidance = ''}) async {
    final idea = _ref.read(ideaRepositoryProvider).getById(ideaId);
    if (idea == null) return;
    final improved = await _ai.improveIdea(_toAiIdea(idea), guidance: guidance);
    await _ref.read(ideaRepositoryProvider).save(
          idea.copyWith(
            title: improved.title,
            problem: improved.problem,
            targetUsers: improved.targetUsers,
            features: improved.features,
            techStack: improved.techStack,
            difficulty: improved.difficulty,
            whyUnique: improved.whyUnique,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> makeProjectPlan(String ideaId) async {
    final idea = _ref.read(ideaRepositoryProvider).getById(ideaId);
    if (idea == null) return;
    final plan = await _ai.projectPlanFor(_toAiIdea(idea));
    await _ref.read(ideaRepositoryProvider).save(
          idea.copyWith(mvpPlan: plan, updatedAt: DateTime.now().toUtc()),
        );
  }

  Future<void> makeCvWorthy(String ideaId) async {
    final idea = _ref.read(ideaRepositoryProvider).getById(ideaId);
    if (idea == null) return;
    final pitch = await _ai.cvPitchFor(_toAiIdea(idea));
    await _ref.read(ideaRepositoryProvider).save(
          idea.copyWith(notes: pitch, updatedAt: DateTime.now().toUtc()),
        );
  }

  Future<void> updateNotes(String ideaId, String notes) async {
    final idea = _ref.read(ideaRepositoryProvider).getById(ideaId);
    if (idea == null) return;
    await _ref.read(ideaRepositoryProvider).save(
          idea.copyWith(notes: notes, updatedAt: DateTime.now().toUtc()),
        );
  }

  AiIdea _toAiIdea(Idea idea) => AiIdea(
        title: idea.title,
        problem: idea.problem,
        targetUsers: idea.targetUsers,
        features: idea.features,
        techStack: idea.techStack,
        difficulty: idea.difficulty,
        mvpPlan: idea.mvpPlan,
        whyUnique: idea.whyUnique ?? '',
      );
}
