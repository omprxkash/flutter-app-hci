import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../data/in_memory_quiz_repository.dart';
import '../../data/in_memory_response_repository.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/response.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/repositories/response_repository.dart';
import '../../domain/usecases/score_response.dart';

// ---------------------------------------------------------------------------
// Repository providers
//
// For v1 we always use the in-memory implementations so the app boots and
// runs end-to-end without Firebase. When a real `firebase_options.dart` is
// generated and the app boots with Firebase available, swap the bodies of
// these providers to construct the Firebase-backed implementations from
// `firebase_quiz_repository.dart` and `firebase_response_repository.dart`.
// ---------------------------------------------------------------------------

final Provider<QuizRepository> quizRepositoryProvider = Provider<QuizRepository>((Ref ref) {
  final InMemoryQuizRepository repo = InMemoryQuizRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final Provider<ResponseRepository> responseRepositoryProvider = Provider<ResponseRepository>((Ref ref) {
  final InMemoryResponseRepository repo = InMemoryResponseRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final Provider<ScoreResponse> scoreResponseProvider = Provider<ScoreResponse>(
  (Ref _) => const ScoreResponse(),
);

// ---------------------------------------------------------------------------
// Watchers
// ---------------------------------------------------------------------------

final patientAssignmentsProvider = StreamProvider.family<List<Assignment>, String>(
  (Ref ref, String patientId) =>
      ref.watch(quizRepositoryProvider).watchAssignmentsForPatient(patientId),
);

final doctorAssignmentsProvider = StreamProvider.family<List<Assignment>, String>(
  (Ref ref, String doctorId) =>
      ref.watch(quizRepositoryProvider).watchAssignmentsForDoctor(doctorId),
);

final patientResponsesProvider = StreamProvider.family<List<QuizResponse>, String>(
  (Ref ref, String patientId) =>
      ref.watch(responseRepositoryProvider).watchResponsesForPatient(patientId),
);

final doctorPendingReviewsProvider = StreamProvider.family<List<QuizResponse>, String>(
  (Ref ref, String doctorId) =>
      ref.watch(responseRepositoryProvider).watchResponsesAwaitingReview(doctorId),
);

final quizByIdProvider = FutureProvider.family<Quiz, String>(
  (Ref ref, String quizId) async {
    final Result<Quiz, Failure> r = await ref.watch(quizRepositoryProvider).getQuiz(quizId);
    return switch (r) {
      Success<Quiz, Failure>(:final Quiz data) => data,
      Err<Quiz, Failure>(:final Failure failure) => throw failure,
    };
  },
);

final responseByIdProvider = FutureProvider.family<QuizResponse, String>(
  (Ref ref, String responseId) async {
    final Result<QuizResponse, Failure> r =
        await ref.watch(responseRepositoryProvider).getResponse(responseId);
    return switch (r) {
      Success<QuizResponse, Failure>(:final QuizResponse data) => data,
      Err<QuizResponse, Failure>(:final Failure failure) => throw failure,
    };
  },
);

final reviewForResponseProvider = FutureProvider.family<Review?, String>(
  (Ref ref, String responseId) async {
    final Result<Review?, Failure> r =
        await ref.watch(responseRepositoryProvider).getReviewForResponse(responseId);
    return switch (r) {
      Success<Review?, Failure>(:final Review? data) => data,
      Err<Review?, Failure>(:final Failure failure) => throw failure,
    };
  },
);

final FutureProvider<List<Quiz>> presetQuizzesProvider = FutureProvider<List<Quiz>>((Ref ref) async {
  final Result<List<Quiz>, Failure> r = await ref.watch(quizRepositoryProvider).listPresetQuizzes();
  return switch (r) {
    Success<List<Quiz>, Failure>(:final List<Quiz> data) => data,
    Err<List<Quiz>, Failure>(:final Failure failure) => throw failure,
  };
});

final quizzesForDoctorProvider = FutureProvider.family<List<Quiz>, String>(
  (Ref ref, String doctorId) async {
    final Result<List<Quiz>, Failure> r =
        await ref.watch(quizRepositoryProvider).listQuizzesForDoctor(doctorId);
    return switch (r) {
      Success<List<Quiz>, Failure>(:final List<Quiz> data) => data,
      Err<List<Quiz>, Failure>(:final Failure failure) => throw failure,
    };
  },
);
