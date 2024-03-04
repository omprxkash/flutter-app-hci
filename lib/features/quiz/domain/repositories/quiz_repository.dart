import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/assignment.dart';
import '../entities/quiz.dart';

abstract class QuizRepository {
  /// All quizzes visible to the given doctor — their custom quizzes plus all presets.
  Future<Result<List<Quiz>, Failure>> listQuizzesForDoctor(String doctorId);

  /// Just the preset library (PHQ-9, GAD-7, MMSE, ...).
  Future<Result<List<Quiz>, Failure>> listPresetQuizzes();

  Future<Result<Quiz, Failure>> getQuiz(String quizId);

  Future<Result<Quiz, Failure>> saveQuiz(Quiz quiz);

  Future<Result<void, Failure>> deleteQuiz(String quizId);

  // -------- Assignments --------------------------------------------------
  Stream<List<Assignment>> watchAssignmentsForPatient(String patientId);

  Stream<List<Assignment>> watchAssignmentsForDoctor(String doctorId);

  Future<Result<Assignment, Failure>> getAssignment(
    String patientId,
    String assignmentId,
  );

  Future<Result<Assignment, Failure>> createAssignment(Assignment assignment);

  Future<Result<Assignment, Failure>> updateAssignment(Assignment assignment);
}
