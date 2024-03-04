import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/quiz.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';

class QuizLibraryScreen extends ConsumerWidget {
  const QuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic doctor = ref.watch(authStateChangesProvider).value;
    final String? doctorId = doctor?.id as String?;
    if (doctorId == null) {
      return const AppScaffold(body: LoadingIndicator());
    }

    return AppScaffold(
      title: 'Quiz library',
      maxContentWidth: 800,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.quizBuilder),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New quiz'),
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final AsyncValue<List<Quiz>> async = ref.watch(
            quizzesForDoctorProvider(doctorId),
          );
          return async.when(
            loading: () => const LoadingIndicator(),
            error: (Object e, _) => Center(child: Text(e.toString())),
            data: (List<Quiz> quizzes) {
              if (quizzes.isEmpty) {
                return const EmptyState(
                  icon: Icons.library_books_outlined,
                  title: 'No quizzes',
                  subtitle:
                      'Create a custom quiz or assign one from the preset library.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: quizzes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int i) {
                  final Quiz q = quizzes[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: q.isPreset
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                        child: Icon(
                          q.isPreset
                              ? Icons.verified_outlined
                              : Icons.edit_outlined,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(q.title),
                      subtitle: Text(
                        '${q.questions.length} items â€¢ ${q.isPreset ? "Preset" : "Custom"}'
                        '${q.estimatedMinutes == null ? "" : " â€¢ ~${q.estimatedMinutes} min"}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.pushNamed(
                        RouteNames.quizBuilder,
                        queryParameters: <String, String>{'quizId': q.id},
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
