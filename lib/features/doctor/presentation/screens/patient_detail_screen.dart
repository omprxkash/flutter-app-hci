import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../patient/presentation/providers/patient_providers.dart';
import '../../../quiz/presentation/widgets/score_badge.dart';
import '../providers/doctor_providers.dart';

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({required this.patientId, super.key});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> patientAsync = ref.watch(
      patientByIdProvider(patientId),
    );
    return patientAsync.when(
      loading: () => const AppScaffold(body: LoadingIndicator()),
      error: (Object e, _) => AppScaffold(
        title: 'Patient',
        body: Center(child: Text(e.toString())),
      ),
      data: (AppUser? patient) {
        if (patient == null) {
          return const AppScaffold(
            title: 'Patient',
            body: EmptyState(title: 'Patient not found'),
          );
        }
        return _PatientDetail(patient: patient);
      },
    );
  }
}

class _PatientDetail extends ConsumerWidget {
  const _PatientDetail({required this.patient});

  final AppUser patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<QuizResponse>> async = ref.watch(
      patientResponsesProvider(patient.id),
    );

    return AppScaffold(
      title: patient.displayName,
      maxContentWidth: 800,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      patient.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          patient.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age ?? "—"} years • ${patient.gender ?? "—"} • ${patient.phone ?? "—"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Assessment timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          async.when(
            loading: () => const LoadingIndicator(),
            error: (Object e, _) => Text(e.toString()),
            data: (List<QuizResponse> responses) {
              if (responses.isEmpty) {
                return const EmptyState(
                  icon: Icons.timeline_rounded,
                  title: 'No assessments yet',
                  subtitle: 'Assign a quiz to start collecting responses.',
                );
              }
              return Column(
                children: <Widget>[
                  for (final QuizResponse r in responses)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(DateFormatters.full(r.submittedAt)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ScoreBadge(
                              score: r.autoScore,
                              maxScore: r.maxPossibleScore,
                              label: r.severityLabel ?? 'Auto-score',
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.pushNamed(
                            RouteNames.reviewResponse,
                            pathParameters: <String, String>{
                              'responseId': r.id,
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
