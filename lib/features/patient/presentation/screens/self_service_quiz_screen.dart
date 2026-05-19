import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/data/preset_quizzes.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/domain/entities/quiz.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';

class SelfServiceQuizScreen extends ConsumerWidget {
  const SelfServiceQuizScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E5BFF), Color(0xFF5B8BFF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic user = ref.watch(authStateChangesProvider).value;
    final String? patientId = user?.id as String?;
    final quizzes = PresetQuizzes.all();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF2E5BFF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: _gradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Self-Check',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Clinically validated assessments — no referral needed.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Text(
                  'Choose an assessment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF52596B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                ...quizzes.map(
                  (Quiz quiz) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _QuizCard(
                      quiz: quiz,
                      onStart: patientId == null
                          ? null
                          : () => _startQuiz(context, ref, quiz, patientId),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _DisclaimerBanner(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz(
    BuildContext context,
    WidgetRef ref,
    Quiz quiz,
    String patientId,
  ) async {
    final assignment = Assignment(
      id: '',
      quizId: quiz.id,
      quizTitle: quiz.title,
      patientId: patientId,
      doctorId: AppConstants.selfServiceDoctorId,
      status: AssignmentStatus.pending,
      assignedAt: DateTime.now(),
    );

    final result =
        await ref.read(quizRepositoryProvider).createAssignment(assignment);

    if (!context.mounted) return;

    switch (result) {
      case Success<Assignment, Failure>(:final Assignment data):
        context.pushNamed(
          RouteNames.takeQuiz,
          pathParameters: <String, String>{'assignmentId': data.id},
        );
      case Err<Assignment, Failure>(:final Failure failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz, required this.onStart});
  final Quiz quiz;
  final VoidCallback? onStart;

  static const Map<String, _QuizMeta> _meta = <String, _QuizMeta>{
    'preset_phq9': _QuizMeta(
      icon: Icons.mood_bad_rounded,
      color: Color(0xFFE53935),
      tag: 'Depression',
      description:
          'Screens for the severity of depressive symptoms over the past two weeks.',
    ),
    'preset_gad7': _QuizMeta(
      icon: Icons.psychology_rounded,
      color: Color(0xFFFF6F00),
      tag: 'Anxiety',
      description:
          'Measures generalised anxiety disorder symptoms over the past two weeks.',
    ),
    'preset_mmse': _QuizMeta(
      icon: Icons.memory_rounded,
      color: Color(0xFF00897B),
      tag: 'Cognition',
      description:
          'A brief cognitive screening covering orientation, recall, and language.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _meta[quiz.id] ??
        const _QuizMeta(
          icon: Icons.assignment_outlined,
          color: Color(0xFF2E5BFF),
          tag: 'Assessment',
          description: '',
        );

    final int qCount = quiz.questions.length;
    final int? mins = quiz.estimatedMinutes;

    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E6EE)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: meta.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: meta.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          meta.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: meta.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meta.description,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF52596B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _Chip(
                  icon: Icons.help_outline_rounded,
                  label: '$qCount questions',
                  color: meta.color,
                ),
                if (mins != null) ...<Widget>[
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.timer_outlined,
                    label: '~$mins min',
                    color: meta.color,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  'Start Assessment',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: meta.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFFF9A825)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'These are screening tools, not diagnoses. Always discuss results with a qualified healthcare professional.',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF6D4C00),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizMeta {
  const _QuizMeta({
    required this.icon,
    required this.color,
    required this.tag,
    required this.description,
  });
  final IconData icon;
  final Color color;
  final String tag;
  final String description;
}
