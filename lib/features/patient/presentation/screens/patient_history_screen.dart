import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../../quiz/presentation/widgets/score_badge.dart';

class PatientHistoryScreen extends ConsumerWidget {
  const PatientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic user = ref.watch(authStateChangesProvider).value;
    final String? patientId = user?.id as String?;
    if (patientId == null) {
      return const AppScaffold(body: LoadingIndicator());
    }

    return AppScaffold(
      title: 'My history',
      body: Consumer(builder: (BuildContext context, WidgetRef ref, _) {
        final AsyncValue<List<QuizResponse>> async =
            ref.watch(patientResponsesProvider(patientId));
        return async.when(
          loading: () => const LoadingIndicator(),
          error: (Object e, _) => Center(child: Text(e.toString())),
          data: (List<QuizResponse> responses) {
            if (responses.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No history yet',
                subtitle: 'Submitted assessments will appear here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: responses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int i) {
                final QuizResponse r = responses[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      'Submitted ${DateFormatters.relative(r.submittedAt)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ScoreBadge(
                        score: r.autoScore,
                        maxScore: r.maxPossibleScore,
                        label: r.severityLabel ?? 'Auto-score',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.pushNamed(
                      RouteNames.quizResult,
                      pathParameters: <String, String>{'responseId': r.id},
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}

