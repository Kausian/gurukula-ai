import 'package:flutter/services.dart';

import '../data/models/enums.dart';
import 'ai_service.dart';

/// On-device AI backed by a Kotlin MethodChannel (ML Kit GenAI / Gemini Nano).
///
/// Every call is defensive: if the native side is missing, the device does not
/// support Gemini Nano, or a feature errors, it transparently falls back to
/// [_fallback] (the MockAiService) for that call. This keeps the whole study
/// flow working everywhere, and silently upgrades to real on-device AI on
/// supported devices.
class OnDeviceAiService implements AiService {
  OnDeviceAiService({required this.fallback});

  final AiService fallback;

  static const MethodChannel _channel = MethodChannel('gurukula/ai');

  @override
  Future<AiAvailability> checkAvailability() async {
    try {
      final result = await _channel.invokeMethod<String>('checkAvailability');
      return _mapAvailability(result);
    } catch (_) {
      return AiAvailability.mock;
    }
  }

  @override
  Future<AiSummary> summarizeText(String text) async {
    try {
      final result =
          await _channel.invokeMethod<String>('summarize', {'text': text});
      if (result == null || result.trim().isEmpty) {
        return fallback.summarizeText(text);
      }
      final points = result
          .split('\n')
          .map((line) => line.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .toList();
      return AiSummary(
        shortSummary: points.isNotEmpty ? points.first : result.trim(),
        detailedSummary: result.trim(),
        keyPoints: points,
      );
    } catch (_) {
      return fallback.summarizeText(text);
    }
  }

  @override
  Future<List<AiFlashcardDraft>> generateFlashcards(String text,
      {int count = 5}) {
    // ML Kit GenAI has no flashcard API, so this always uses the fallback.
    return fallback.generateFlashcards(text, count: count);
  }

  @override
  Future<String> proofreadText(String text) async {
    try {
      final result =
          await _channel.invokeMethod<String>('proofread', {'text': text});
      return (result == null || result.trim().isEmpty)
          ? fallback.proofreadText(text)
          : result;
    } catch (_) {
      return fallback.proofreadText(text);
    }
  }

  @override
  Future<String> rewriteText(String text, RewriteTone tone) async {
    try {
      final result = await _channel.invokeMethod<String>(
          'rewrite', {'text': text, 'tone': tone.name});
      return (result == null || result.trim().isEmpty)
          ? fallback.rewriteText(text, tone)
          : result;
    } catch (_) {
      return fallback.rewriteText(text, tone);
    }
  }

  @override
  Future<List<AiQuizQuestion>> generateQuiz(String text, {int count = 5}) =>
      fallback.generateQuiz(text, count: count);

  // Idea Lab has no on-device model API, so these use the fallback directly.

  @override
  Future<AiIdea> generateIdea(IdeaBrief brief) => fallback.generateIdea(brief);

  @override
  Future<AiIdea> improveIdea(AiIdea current, {String guidance = ''}) =>
      fallback.improveIdea(current, guidance: guidance);

  @override
  Future<String> projectPlanFor(AiIdea idea) => fallback.projectPlanFor(idea);

  @override
  Future<String> cvPitchFor(AiIdea idea) => fallback.cvPitchFor(idea);

  AiAvailability _mapAvailability(String? status) {
    switch (status) {
      case 'available':
        return AiAvailability.available;
      case 'downloading':
      case 'downloadable':
        return AiAvailability.downloading;
      case 'unsupported':
        return AiAvailability.unsupported;
      default:
        return AiAvailability.mock;
    }
  }
}
