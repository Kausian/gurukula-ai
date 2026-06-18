import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/enums.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import 'quiz_providers.dart';

/// Takes a quiz one question at a time, then shows the score and a review.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<String> _answers = const [];
  bool _initialized = false;
  int _index = 0;
  bool _submitted = false;
  QuizResult? _result;

  void _reset(Quiz quiz) {
    setState(() {
      _answers = List<String>.filled(quiz.questions.length, '');
      _index = 0;
      _submitted = false;
      _result = null;
    });
  }

  Future<void> _submit(Quiz quiz) async {
    final result =
        await ref.read(quizControllerProvider).gradeAndSave(quiz, _answers);
    if (mounted) {
      setState(() {
        _result = result;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizByIdProvider(widget.quizId));

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This quiz could not be found.')),
      );
    }

    if (!_initialized) {
      _answers = List<String>.filled(quiz.questions.length, '');
      _initialized = true;
    }

    if (_submitted && _result != null) {
      return _ResultView(
        quiz: quiz,
        result: _result!,
        onRetake: () => _reset(quiz),
        onDone: () => context.pop(),
      );
    }

    final question = quiz.questions[_index];
    final isLast = _index == quiz.questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('Question ${_index + 1} of ${quiz.questions.length}')),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / quiz.questions.length,
              minHeight: 4,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  Text(question.prompt,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  _AnswerInput(
                    question: question,
                    value: _answers[_index],
                    onChanged: (v) => setState(() => _answers[_index] = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _index--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    // Override the theme's full-width minimumSize so the button
                    // can sit inline in this Row without forcing infinite width.
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 52),
                    ),
                    onPressed: isLast
                        ? () => _submit(quiz)
                        : () => setState(() => _index++),
                    child: Text(isLast ? 'Submit' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the right input for a question type.
class _AnswerInput extends StatelessWidget {
  const _AnswerInput({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final QuizQuestion question;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (question.type == QuestionType.shortAnswer) {
      return TextFormField(
        key: ValueKey(question.id),
        initialValue: value,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Type your answer'),
        onChanged: onChanged,
      );
    }
    return Column(
      children: [
        for (final option in question.options) ...[
          _OptionTile(
            label: option,
            selected: value == option,
            onTap: () => onChanged(option),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.10)
          : null,
      borderColor: selected ? theme.colorScheme.primary : null,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// The score and per-question review.
class _ResultView extends ConsumerWidget {
  const _ResultView({
    required this.quiz,
    required this.result,
    required this.onRetake,
    required this.onDone,
  });

  final Quiz quiz;
  final QuizResult result;
  final VoidCallback onRetake;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(quizControllerProvider);
    final pct = result.total == 0 ? 0 : (result.score / result.total * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Your score')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            AppCard(
              color: theme.colorScheme.primary,
              showBorder: false,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('${result.score} / ${result.total}',
                      style: theme.textTheme.displayLarge
                          ?.copyWith(color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 4),
                  Text('$pct% correct',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < quiz.questions.length; i++) ...[
              _ReviewTile(
                question: quiz.questions[i],
                answer: i < result.answers.length ? result.answers[i] : '',
                correct: controller.isCorrect(
                    quiz.questions[i],
                    i < result.answers.length ? result.answers[i] : ''),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetake,
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onDone,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.question,
    required this.answer,
    required this.correct,
  });

  final QuizQuestion question;
  final String answer;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 20,
                color: correct ? AppColors.success : theme.colorScheme.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(question.prompt,
                      style: theme.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Your answer: ${answer.trim().isEmpty ? '—' : answer}',
              style: theme.textTheme.bodyMedium),
          if (!correct) ...[
            const SizedBox(height: 4),
            Text('Correct: ${question.correctAnswer}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.success)),
          ],
          if (question.type == QuestionType.shortAnswer)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Short answers are checked approximately.',
                  style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
