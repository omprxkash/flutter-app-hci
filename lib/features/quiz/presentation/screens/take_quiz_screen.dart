import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/response.dart';
import '../providers/quiz_providers.dart';
import '../widgets/question_card.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  const TakeQuizScreen({required this.assignmentId, super.key});
  final String assignmentId;

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  final Map<String, Answer> _answers = <String, Answer>{};
  int _currentIndex = 0;
  bool _isSubmitting = false;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  Future<void> _confirmAndSubmit(
    Quiz quiz,
    Assignment assignment,
    String patientId,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Submit assessment?'),
        content: Text(
          'You\'re about to submit the ${quiz.title}. '
          'Your answers cannot be changed once submitted.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Review answers'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true) _submit(quiz, assignment, patientId);
  }

  Future<void> _submit(
    Quiz quiz,
    Assignment assignment,
    String patientId,
  ) async {
    setState(() => _isSubmitting = true);
    final score = ref
        .read(scoreResponseProvider)
        .call(quiz, _answers.values.toList());
    final response = QuizResponse(
      id: '',
      assignmentId: assignment.id,
      quizId: quiz.id,
      patientId: patientId,
      doctorId: assignment.doctorId,
      answers: _answers.values.toList(),
      submittedAt: DateTime.now(),
      autoScore: score.score,
      maxPossibleScore: score.maxPossibleScore,
      severityLabel: score.severityLabel,
      durationSeconds: _startedAt == null
          ? null
          : DateTime.now().difference(_startedAt!).inSeconds,
    );

    final Result<QuizResponse, Failure> r = await ref
        .read(responseRepositoryProvider)
        .submitResponse(response);

    if (!mounted) return;
    switch (r) {
      case Success<QuizResponse, Failure>(:final QuizResponse data):
        await ref
            .read(quizRepositoryProvider)
            .updateAssignment(
              assignment.copyWith(
                status: AssignmentStatus.completed,
                completedAt: DateTime.now(),
                responseId: data.id,
              ),
            );
        if (!mounted) return;
        context.goNamed(
          RouteNames.quizResult,
          pathParameters: <String, String>{'responseId': data.id},
        );
      case Err<QuizResponse, Failure>(:final Failure failure):
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic auth = ref.watch(authStateChangesProvider).value;
    final String? patientId = auth?.id as String?;
    if (patientId == null) {
      return const Scaffold(body: LoadingIndicator(label: 'Loading...'));
    }

    return FutureBuilder<Assignment?>(
      future: _loadAssignment(patientId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: LoadingIndicator(label: 'Loading assignment...'),
          );
        }
        final Assignment? assignment = snap.data;
        if (assignment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const ErrorView(message: 'Assignment not found.'),
          );
        }
        return Consumer(
          builder: (context, ref, _) {
            final quizAsync = ref.watch(quizByIdProvider(assignment.quizId));
            return quizAsync.when(
              loading: () => const Scaffold(
                body: LoadingIndicator(label: 'Loading quiz...'),
              ),
              error: (e, _) => Scaffold(
                appBar: AppBar(title: const Text('Quiz')),
                body: ErrorView(message: e.toString()),
              ),
              data: (quiz) => _buildQuiz(quiz, assignment, patientId),
            );
          },
        );
      },
    );
  }

  Future<Assignment?> _loadAssignment(String patientId) async {
    final r = await ref
        .read(quizRepositoryProvider)
        .getAssignment(patientId, widget.assignmentId);
    return r.dataOrNull;
  }

  Widget _buildQuiz(Quiz quiz, Assignment assignment, String patientId) {
    final questions = quiz.questions;
    final Question current = questions[_currentIndex];
    final Answer? currentAnswer = _answers[current.id];
    final bool isLast = _currentIndex == questions.length - 1;
    final bool canProceed =
        !current.required || (currentAnswer != null && !currentAnswer.isEmpty);
    final double progress = (_currentIndex + 1) / questions.length;

    const Color accentColor = Color(0xFF6C56FC);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Top bar ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF0A0A0A),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_currentIndex + 1} of ${questions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),

            // ── Question area ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QuestionCard(
                    question: current,
                    answer: currentAnswer,
                    onChanged: (Answer a) {
                      setState(() => _answers[current.id] = a);
                    },
                  ),
                ),
              ),
            ),

            // ── Bottom navigation ─────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: <Widget>[
                  if (_currentIndex > 0) ...<Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _currentIndex--),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text(
                          'Back',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0A0A0A),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: canProceed && !_isSubmitting
                          ? () {
                              if (isLast) {
                                _confirmAndSubmit(quiz, assignment, patientId);
                              } else {
                                setState(() => _currentIndex++);
                              }
                            }
                          : null,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                      label: Text(
                        isLast ? 'Submit' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: canProceed
                            ? accentColor
                            : const Color(0xFFCBD5E0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
