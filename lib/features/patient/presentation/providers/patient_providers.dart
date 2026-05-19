import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/domain/entities/response.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../data/in_memory_patient_repository.dart';
import '../../domain/repositories/patient_repository.dart';

final Provider<PatientRepository> patientRepositoryProvider =
    Provider<PatientRepository>((_) => InMemoryPatientRepository());

final patientAssignmentsProvider = StreamProvider.family<List<Assignment>, String>(
  (Ref ref, String patientId) =>
      ref.watch(quizRepositoryProvider).watchAssignmentsForPatient(patientId),
);

final patientResponsesProvider = StreamProvider.family<List<QuizResponse>, String>(
  (Ref ref, String patientId) =>
      ref.watch(responseRepositoryProvider).watchResponsesForPatient(patientId),
);
