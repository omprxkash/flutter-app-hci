import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
  );

  String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic user = ref.watch(authStateChangesProvider).value;
    final String? patientId = user?.id as String?;
    final String displayName = (user?.displayName as String?) ?? 'there';
    final String firstName = displayName.split(' ').first;

    if (patientId == null) return const Scaffold(body: LoadingIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: Consumer(
        builder: (context, ref, _) {
          final assignmentsAsync = ref.watch(patientAssignmentsProvider(patientId));
          return assignmentsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (List<Assignment> all) {
              final pending = all
                  .where((a) =>
                      a.status == AssignmentStatus.pending ||
                      a.status == AssignmentStatus.inProgress)
                  .toList();
              final done = all
                  .where((a) =>
                      a.status == AssignmentStatus.completed ||
                      a.status == AssignmentStatus.reviewed)
                  .toList();

              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF1565C0),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(gradient: _gradient),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '${_greeting()},',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  firstName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pending.isEmpty
                                      ? 'No pending assessments — you\'re all caught up!'
                                      : '${pending.length} assessment${pending.length == 1 ? '' : 's'} waiting for you.',
                                  style: GoogleFonts.poppins(
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        if (pending.isEmpty && done.isEmpty)
                          _EmptyState()
                        else ...[
                          if (pending.isNotEmpty) ...[
                            _SectionLabel(
                              label: 'PENDING (${pending.length})',
                              color: AppColors.warning,
                              icon: Icons.pending_actions_rounded,
                            ),
                            const SizedBox(height: 12),
                            ...pending.map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _PendingCard(assignment: a),
                                )),
                          ],
                          if (done.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _SectionLabel(
                              label: 'COMPLETED (${done.length})',
                              color: AppColors.success,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                            const SizedBox(height: 12),
                            ...done.take(5).map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _CompletedCard(assignment: a),
                                )),
                          ],
                        ],
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: <Widget>[
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1565C0).withOpacity(0.08),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 44,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No assessments yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your doctor hasn\'t assigned any assessments yet.\nCheck back soon.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF52596B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.assignment});
  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final bool overdue = assignment.isOverdue;
    final Color accent = overdue ? AppColors.danger : const Color(0xFF1565C0);

    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: accent.withOpacity(0.15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.assignment_outlined, color: accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        assignment.quizTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        overdue
                            ? 'Overdue — was due ${DateFormatters.relative(assignment.dueAt!)}'
                            : assignment.dueAt == null
                                ? 'Assigned ${DateFormatters.relative(assignment.assignedAt)}'
                                : 'Due ${DateFormatters.short(assignment.dueAt!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: overdue ? AppColors.danger : const Color(0xFF52596B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (assignment.notes != null && assignment.notes!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  assignment.notes!,
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF52596B)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                RouteNames.takeQuiz,
                pathParameters: <String, String>{'assignmentId': assignment.id},
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'Start Assessment',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  const _CompletedCard({required this.assignment});
  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final bool reviewed = assignment.status == AssignmentStatus.reviewed;
    final Color accent = reviewed ? AppColors.success : AppColors.secondary;

    return Material(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: InkWell(
        onTap: assignment.responseId == null
            ? null
            : () => context.pushNamed(
                  RouteNames.quizResult,
                  pathParameters: <String, String>{'responseId': assignment.responseId!},
                ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE3E6EE)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                reviewed ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                color: accent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      assignment.quizTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Completed ${DateFormatters.relative(assignment.completedAt ?? assignment.assignedAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF52596B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reviewed ? 'Reviewed' : 'Awaiting review',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              if (assignment.responseId != null) ...<Widget>[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: Colors.grey.shade400),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
