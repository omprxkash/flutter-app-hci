import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/answer.dart';
import '../../../quiz/domain/entities/question.dart';
import '../../../quiz/domain/entities/question_type.dart';
import '../../../quiz/domain/entities/quiz.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../quiz/domain/entities/review.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../../quiz/presentation/widgets/score_badge.dart';

/// Doctor-side review of a single submitted response.
class ReviewResponseScreen extends ConsumerStatefulWidget {
  const ReviewResponseScreen({required this.responseId, super.key});

  final String responseId;

  @override
  ConsumerState<ReviewResponseScreen> createState() => _ReviewResponseScreenState();
}

class _ReviewResponseScreenState extends ConsumerState<ReviewResponseScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  int? _followUpDays;
  bool _isSaving = false;
  bool _initialized = false;

  static const List<_FollowUpOption> _followUpOptions = <_FollowUpOption>[
    _FollowUpOption(label: 'None', days: null),
    _FollowUpOption(label: '1 week', days: 7),
    _FollowUpOption(label: '2 weeks', days: 14),
    _FollowUpOption(label: '1 month', days: 30),
    _FollowUpOption(label: '3 months', days: 90),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _save({required QuizResponse response, required Quiz quiz}) async {
    setState(() => _isSaving = true);

    final int? finalScore = int.tryParse(_scoreController.text.trim());
    final dynamic doctor = ref.read(authStateChangesProvider).value;
    final String doctorId = (doctor?.id as String?) ?? '';

    final Review review = Review(
      id: '',
      responseId: response.id,
      doctorId: doctorId,
      finalScore: finalScore ?? response.autoScore,
      reviewedAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      recommendedFollowUpInDays: _followUpDays,
    );

    final Result<Review, Failure> r =
        await ref.read(responseRepositoryProvider).saveReview(review);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (r) {
      case Success<Review, Failure>():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review saved.')),
        );
        if (context.canPop()) context.pop();
      case Err<Review, Failure>(:final Failure failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<QuizResponse> responseAsync =
        ref.watch(responseByIdProvider(widget.responseId));
    return responseAsync.when(
      loading: () => const AppScaffold(body: LoadingIndicator()),
      error: (Object e, _) =>
          AppScaffold(title: 'Review', body: ErrorView(message: e.toString())),
      data: (QuizResponse response) {
        final AsyncValue<Quiz> quizAsync = ref.watch(quizByIdProvider(response.quizId));
        return quizAsync.when(
          loading: () => const AppScaffold(body: LoadingIndicator()),
          error: (Object e, _) =>
              AppScaffold(title: 'Review', body: ErrorView(message: e.toString())),
          data: (Quiz quiz) {
            if (!_initialized) {
              _scoreController.text = response.autoScore.toString();
              _initialized = true;
            }
            return _buildReview(response, quiz);
          },
        );
      },
    );
  }

  Widget _buildReview(QuizResponse response, Quiz quiz) {
    return AppScaffold(
      title: 'Review response',
      maxContentWidth: 1024,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth > 720;
          final Widget answersPanel = _AnswersPanel(response: response, quiz: quiz);
          final Widget reviewForm = _ReviewForm(
            response: response,
            quiz: quiz,
            notesController: _notesController,
            scoreController: _scoreController,
            followUpDays: _followUpDays,
            followUpOptions: _followUpOptions,
            isSaving: _isSaving,
            onFollowUpChanged: (int? d) => setState(() => _followUpDays = d),
            onSave: () => _save(response: response, quiz: quiz),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: answersPanel,
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 360,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: reviewForm,
                  ),
                ),
              ],
            );
          }

          // Narrow layout: stacked
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                answersPanel,
                const SizedBox(height: 24),
                reviewForm,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnswersPanel extends StatelessWidget {
  const _AnswersPanel({required this.response, required this.quiz});

  final QuizResponse response;
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(quiz.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Submitted ${DateFormatters.full(response.submittedAt)}'
                  '${response.durationSeconds == null ? "" : " · ${response.durationSeconds! ~/ 60}m ${response.durationSeconds! % 60}s"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ScoreBadge(
                  score: response.autoScore,
                  maxScore: response.maxPossibleScore,
                  band: quiz.bandFor(response.autoScore),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Patient answers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...quiz.questions.map((Question q) {
          final Answer? a = response.answerFor(q.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerSummary(question: q, answer: a),
          );
        }),
      ],
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.response,
    required this.quiz,
    required this.notesController,
    required this.scoreController,
    required this.followUpDays,
    required this.followUpOptions,
    required this.isSaving,
    required this.onFollowUpChanged,
    required this.onSave,
  });

  final QuizResponse response;
  final Quiz quiz;
  final TextEditingController notesController;
  final TextEditingController scoreController;
  final int? followUpDays;
  final List<_FollowUpOption> followUpOptions;
  final bool isSaving;
  final ValueChanged<int?> onFollowUpChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Your Assessment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Score override
              Text('Final score (override)',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.score_outlined),
                  hintText: 'Auto: ${response.autoScore}',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),

              // Follow-up chips
              Text('Recommend follow-up',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: followUpOptions.map((_FollowUpOption opt) {
                  final bool selected = followUpDays == opt.days;
                  return GestureDetector(
                    onTap: () => onFollowUpChanged(opt.days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        opt.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Clinical notes
              Text('Clinical notes', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 5,
                maxLength: AppConstants.maxReviewNoteLength,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  hintText: 'Visible to you and the patient on their result screen.',
                ),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                label: 'Save Review',
                icon: Icons.check_rounded,
                isLoading: isSaving,
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerSummary extends StatelessWidget {
  const _AnswerSummary({required this.question, required this.answer});

  final Question question;
  final Answer? answer;

  String _renderAnswer() {
    final Answer? a = answer;
    if (a == null || a.isEmpty) return '— No answer —';
    switch (question.type) {
      case QuestionType.numeric:
        return a.numericValue?.toString() ?? '—';
      case QuestionType.freeText:
        return a.textValue ?? '—';
      default:
        final List<String> labels = a.selectedOptionIds
            .map((String id) => question.options
                .where((opt) => opt.id == id)
                .map((opt) => opt.label)
                .firstOrNull ?? id)
            .toList();
        return labels.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool answered = answer != null && !answer!.isEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: answered
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(question.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          )),
          const SizedBox(height: 6),
          Text(
            _renderAnswer(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: answered
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: answered ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpOption {
  const _FollowUpOption({required this.label, required this.days});

  final String label;
  final int? days;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
