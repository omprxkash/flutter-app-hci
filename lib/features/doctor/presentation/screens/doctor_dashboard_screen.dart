import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/stats_card.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic doctor = ref.watch(authStateChangesProvider).value;
    final String? doctorId = doctor?.id as String?;
    if (doctorId == null) {
      return const AppScaffold(body: LoadingIndicator());
    }

    final String doctorName = (doctor?.displayName as String?) ?? 'Doctor';
    final String specialty = (doctor?.specialty as String?) ?? 'Clinician';

    return AppScaffold(
      title: 'Dashboard',
      maxContentWidth: 1024,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.assignQuiz),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Assign quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: <Widget>[
          // Doctor identity header
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Dr. $doctorName',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(specialty, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          _StatsRow(doctorId: doctorId),
          const SizedBox(height: 32),

          // Pending reviews section
          Row(
            children: <Widget>[
              const Icon(Icons.rate_review_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text('Awaiting your review',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          _PendingReviews(doctorId: doctorId),
          const SizedBox(height: 32),

          // Patient list section
          Row(
            children: <Widget>[
              const Icon(Icons.people_outline_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text('Your patients', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          _PatientList(doctorId: doctorId),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Assignment>> assignments =
        ref.watch(doctorAssignmentsProvider(doctorId));
    final AsyncValue<List<QuizResponse>> pending =
        ref.watch(doctorPendingReviewsProvider(doctorId));
    final AsyncValue<List<AppUser>> patients =
        ref.watch(patientsForDoctorProvider(doctorId));

    final int activeCount = assignments.maybeWhen(
      data: (List<Assignment> a) => a
          .where((Assignment x) =>
              x.status == AssignmentStatus.pending ||
              x.status == AssignmentStatus.inProgress)
          .length,
      orElse: () => 0,
    );
    final int pendingReviews =
        pending.maybeWhen(data: (List<QuizResponse> p) => p.length, orElse: () => 0);
    final int patientCount =
        patients.maybeWhen(data: (List<AppUser> p) => p.length, orElse: () => 0);

    return Row(
      children: <Widget>[
        Expanded(
          child: StatsCard(
            label: 'Pending reviews',
            value: pendingReviews.toString(),
            icon: Icons.rate_review_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            label: 'Active assignments',
            value: activeCount.toString(),
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            label: 'Patients',
            value: patientCount.toString(),
            icon: Icons.people_outline_rounded,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _PendingReviews extends ConsumerWidget {
  const _PendingReviews({required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<QuizResponse>> async =
        ref.watch(doctorPendingReviewsProvider(doctorId));
    return async.when(
      loading: () => const LoadingIndicator(),
      error: (Object e, _) => Text(e.toString()),
      data: (List<QuizResponse> responses) {
        if (responses.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Text('No pending reviews — all caught up!',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          );
        }
        // Horizontal scrolling cards
        return SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: responses.take(10).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int i) {
              final QuizResponse r = responses[i];
              return _PendingReviewCard(response: r);
            },
          ),
        );
      },
    );
  }
}

class _PendingReviewCard extends ConsumerWidget {
  const _PendingReviewCard({required this.response, super.key});

  final QuizResponse response;

  String _timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> patientAsync =
        ref.watch(patientByIdProvider(response.patientId));
    final String patientName =
        patientAsync.value?.displayName ?? 'Patient';
    final String firstName = patientName.split(' ').first;

    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.warning.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      firstName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${response.autoScore}${response.maxPossibleScore != null ? "/${response.maxPossibleScore}" : ""}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (response.severityLabel != null)
                Text(
                  response.severityLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              Text(
                _timeAgo(response.submittedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.pushNamed(
                    RouteNames.reviewResponse,
                    pathParameters: <String, String>{'responseId': response.id},
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Review Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientList extends ConsumerWidget {
  const _PatientList({required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AppUser>> patientsAsync =
        ref.watch(patientsForDoctorProvider(doctorId));
    final AsyncValue<List<Assignment>> assignmentsAsync =
        ref.watch(doctorAssignmentsProvider(doctorId));

    return patientsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (Object e, _) => Text(e.toString()),
      data: (List<AppUser> patients) {
        final List<Assignment> assignments = assignmentsAsync.value ?? <Assignment>[];

        return Column(
          children: <Widget>[
            for (final AppUser p in patients) ...<Widget>[
              _PatientRow(
                patient: p,
                assignments: assignments
                    .where((Assignment a) => a.patientId == p.id)
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.patient, required this.assignments});

  final AppUser patient;
  final List<Assignment> assignments;

  @override
  Widget build(BuildContext context) {
    // Most recent assignment
    final Assignment? latest = assignments.isNotEmpty
        ? (assignments..sort((Assignment a, Assignment b) =>
              b.assignedAt.compareTo(a.assignedAt)))
            .first
        : null;

    final bool pendingReview = latest?.status == AssignmentStatus.completed;
    final bool reviewed = latest?.status == AssignmentStatus.reviewed;
    final Color chipColor = pendingReview
        ? AppColors.warning
        : reviewed
            ? AppColors.success
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    final String chipLabel = pendingReview
        ? 'Needs review'
        : reviewed
            ? 'Reviewed'
            : latest == null
                ? 'No assessment'
                : 'Pending';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          RouteNames.patientDetail,
          pathParameters: <String, String>{'patientId': patient.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  patient.displayName.isNotEmpty
                      ? patient.displayName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                      color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(patient.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    if (latest != null)
                      Text(
                        'Last: ${latest.quizTitle} · ${DateFormat('MMM d').format(latest.assignedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chipLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: chipColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
