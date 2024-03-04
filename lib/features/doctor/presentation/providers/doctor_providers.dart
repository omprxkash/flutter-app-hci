import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../data/in_memory_doctor_repository.dart';
import '../../domain/repositories/doctor_repository.dart';

final Provider<DoctorRepository> doctorRepositoryProvider =
    Provider<DoctorRepository>((_) => InMemoryDoctorRepository());

final patientsForDoctorProvider = FutureProvider.family<List<AppUser>, String>(
  (Ref ref, String doctorId) =>
      ref.watch(doctorRepositoryProvider).getPatientsForDoctor(doctorId),
);

final patientByIdProvider = FutureProvider.family<AppUser?, String>(
  (Ref ref, String patientId) =>
      ref.watch(doctorRepositoryProvider).getPatientById(patientId),
);

final doctorAssignmentsProvider =
    StreamProvider.family<List<Assignment>, String>(
      (Ref ref, String doctorId) =>
          ref.watch(quizRepositoryProvider).watchAssignmentsForDoctor(doctorId),
    );

final doctorPendingReviewsProvider =
    StreamProvider.family<List<QuizResponse>, String>(
      (Ref ref, String doctorId) => ref
          .watch(responseRepositoryProvider)
          .watchResponsesAwaitingReview(doctorId),
    );
