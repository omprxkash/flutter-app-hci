import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../providers/patient_providers.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0A3C), Color(0xFF6C56FC)],
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
                    expandedHeight: 210,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF1A0A3C),
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
                                  '${_greeting()},',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  firstName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: <Widget>[
                                    _StatPill(
                                      value: '${pending.length}',
                                      label: 'Pending',
                                      color: pending.isEmpty
                                          ? Colors.white.withOpacity(0.15)
                                          : const Color(0xFFFFBF47).withOpacity(0.25),
                                      textColor: pending.isEmpty
                                          ? Colors.white.withOpacity(0.65)
                                          : const Color(0xFFFFD76E),
                                    ),
                                    const SizedBox(width: 10),
                                    _StatPill(
                                      value: '${done.length}',
                                      label: 'Completed',
                                      color: Colors.white.withOpacity(0.15),
                                      textColor: Colors.white.withOpacity(0.8),
                                    ),
                                  ],
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
                          _EmptyState(user: user as AppUser?)
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
  const _EmptyState({this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final bool hasDoctor = user?.doctorId != null;
    return hasDoctor ? _doctorManaged(context) : _selfService(context);
  }

  Widget _doctorManaged(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 64),
      child: Column(
        children: <Widget>[
          _CircleIcon(
            outer: Color(0xFFEEF3FF),
            inner: Color(0xFFE0EAFF),
            icon: Icons.assignment_turned_in_outlined,
            iconColor: Color(0xFF2E5BFF),
          ),
          SizedBox(height: 28),
          Text(
            'All caught up',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nothing to fill out right now.\nYour doctor will let you know.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF52596B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selfService(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: <Widget>[
          const _CircleIcon(
            outer: Color(0xFFE8F5E9),
            inner: Color(0xFFC8E6C9),
            icon: Icons.self_improvement_rounded,
            iconColor: Color(0xFF2E7D32),
          ),
          const SizedBox(height: 28),
          const Text(
            'Check in with yourself',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a clinically validated assessment\n— no referral needed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF52596B),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.selfCheck),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start a Self-Check',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Have a doctor\'s invite code? Go to Profile → Connect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9EA5B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.outer,
    required this.inner,
    required this.icon,
    required this.iconColor,
  });
  final Color outer;
  final Color inner;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(shape: BoxShape.circle, color: outer),
        ),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(shape: BoxShape.circle, color: inner),
          child: Icon(icon, size: 44, color: iconColor),
        ),
      ],
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
                style: TextStyle(
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

// Left-accent card for pending quizzes. The 4px colored left bar communicates
// urgency (red = overdue, primary blue = due soon) at a glance.
class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.assignment});
  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final bool overdue = assignment.isOverdue;
    final Color accent = overdue ? AppColors.danger : const Color(0xFF2E5BFF);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E6EE)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
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
                                style: const TextStyle(
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
                                style: TextStyle(
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
                          style: const TextStyle(fontSize: 13, color: Color(0xFF52596B)),
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
                      label: const Text(
                        'Start Assessment',
                        style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}

// Left-accent card for completed quizzes. Green = reviewed, teal = awaiting review.
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: assignment.responseId == null
            ? null
            : () => context.pushNamed(
                  RouteNames.quizResult,
                  pathParameters: <String, String>{'responseId': assignment.responseId!},
                ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE3E6EE)),
              right: BorderSide(color: Color(0xFFE3E6EE)),
              bottom: BorderSide(color: Color(0xFFE3E6EE)),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Completed ${DateFormatters.relative(assignment.completedAt ?? assignment.assignedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF52596B),
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
                            style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
