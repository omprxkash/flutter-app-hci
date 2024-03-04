import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/assignment.dart';
import '../domain/entities/quiz.dart';
import '../domain/repositories/quiz_repository.dart';
import 'preset_quizzes.dart';

class InMemoryQuizRepository implements QuizRepository {
  InMemoryQuizRepository() {
    for (final Quiz q in PresetQuizzes.all()) {
      _quizzes[q.id] = q;
    }
  }

  final Map<String, Quiz> _quizzes = <String, Quiz>{};
  final Map<String, Assignment> _assignments = <String, Assignment>{};
  final Map<String, StreamController<List<Assignment>>> _patientStreams =
      <String, StreamController<List<Assignment>>>{};
  final Map<String, StreamController<List<Assignment>>> _doctorStreams =
      <String, StreamController<List<Assignment>>>{};
  final Uuid _uuid = const Uuid();

  @override
  Future<Result<List<Quiz>, Failure>> listQuizzesForDoctor(
    String doctorId,
  ) async {
    final List<Quiz> visible =
        _quizzes.values
            .where((Quiz q) => q.isPreset || q.createdBy == doctorId)
            .toList()
          ..sort((Quiz a, Quiz b) => a.title.compareTo(b.title));
    return Success<List<Quiz>, Failure>(visible);
  }

  @override
  Future<Result<List<Quiz>, Failure>> listPresetQuizzes() async {
    return Success<List<Quiz>, Failure>(
      _quizzes.values.where((Quiz q) => q.isPreset).toList(),
    );
  }

  @override
  Future<Result<Quiz, Failure>> getQuiz(String quizId) async {
    final Quiz? q = _quizzes[quizId];
    if (q == null)
      return const Err<Quiz, Failure>(NotFoundFailure('Quiz not found.'));
    return Success<Quiz, Failure>(q);
  }

  @override
  Future<Result<Quiz, Failure>> saveQuiz(Quiz quiz) async {
    if (quiz.isPreset) {
      return const Err<Quiz, Failure>(
        PermissionFailure('Preset quizzes cannot be edited.'),
      );
    }
    final Quiz toSave = quiz.id.isEmpty
        ? Quiz(
            id: _uuid.v4(),
            title: quiz.title,
            description: quiz.description,
            questions: quiz.questions,
            createdBy: quiz.createdBy,
            createdAt: DateTime.now(),
            severityBands: quiz.severityBands,
            estimatedMinutes: quiz.estimatedMinutes,
          )
        : quiz;
    _quizzes[toSave.id] = toSave;
    return Success<Quiz, Failure>(toSave);
  }

  @override
  Future<Result<void, Failure>> deleteQuiz(String quizId) async {
    final Quiz? q = _quizzes[quizId];
    if (q == null)
      return const Err<void, Failure>(NotFoundFailure('Quiz not found.'));
    if (q.isPreset) {
      return const Err<void, Failure>(
        PermissionFailure('Preset quizzes cannot be deleted.'),
      );
    }
    _quizzes.remove(quizId);
    return const Success<void, Failure>(null);
  }

  @override
  Stream<List<Assignment>> watchAssignmentsForPatient(String patientId) {
    final StreamController<List<Assignment>> controller = _patientStreams
        .putIfAbsent(
          patientId,
          () => StreamController<List<Assignment>>.broadcast(),
        );
    scheduleMicrotask(() => controller.add(_forPatient(patientId)));
    return controller.stream;
  }

  @override
  Stream<List<Assignment>> watchAssignmentsForDoctor(String doctorId) {
    final StreamController<List<Assignment>> controller = _doctorStreams
        .putIfAbsent(
          doctorId,
          () => StreamController<List<Assignment>>.broadcast(),
        );
    scheduleMicrotask(() => controller.add(_forDoctor(doctorId)));
    return controller.stream;
  }

  List<Assignment> _forPatient(String patientId) =>
      _assignments.values
          .where((Assignment a) => a.patientId == patientId)
          .toList()
        ..sort(
          (Assignment a, Assignment b) => b.assignedAt.compareTo(a.assignedAt),
        );

  List<Assignment> _forDoctor(String doctorId) =>
      _assignments.values
          .where((Assignment a) => a.doctorId == doctorId)
          .toList()
        ..sort(
          (Assignment a, Assignment b) => b.assignedAt.compareTo(a.assignedAt),
        );

  void _notify(String patientId, String doctorId) {
    _patientStreams[patientId]?.add(_forPatient(patientId));
    _doctorStreams[doctorId]?.add(_forDoctor(doctorId));
  }

  @override
  Future<Result<Assignment, Failure>> getAssignment(
    String patientId,
    String assignmentId,
  ) async {
    final Assignment? a = _assignments[assignmentId];
    if (a == null || a.patientId != patientId) {
      return const Err<Assignment, Failure>(
        NotFoundFailure('Assignment not found.'),
      );
    }
    return Success<Assignment, Failure>(a);
  }

  @override
  Future<Result<Assignment, Failure>> createAssignment(
    Assignment assignment,
  ) async {
    final Assignment fresh = assignment.id.isEmpty
        ? Assignment(
            id: _uuid.v4(),
            quizId: assignment.quizId,
            quizTitle: assignment.quizTitle,
            patientId: assignment.patientId,
            doctorId: assignment.doctorId,
            status: assignment.status,
            assignedAt: DateTime.now(),
            dueAt: assignment.dueAt,
            notes: assignment.notes,
          )
        : assignment;
    _assignments[fresh.id] = fresh;
    _notify(fresh.patientId, fresh.doctorId);
    return Success<Assignment, Failure>(fresh);
  }

  @override
  Future<Result<Assignment, Failure>> updateAssignment(
    Assignment assignment,
  ) async {
    if (!_assignments.containsKey(assignment.id)) {
      return const Err<Assignment, Failure>(
        NotFoundFailure('Assignment not found.'),
      );
    }
    _assignments[assignment.id] = assignment;
    _notify(assignment.patientId, assignment.doctorId);
    return Success<Assignment, Failure>(assignment);
  }

  void dispose() {
    for (final StreamController<List<Assignment>> c in _patientStreams.values) {
      c.close();
    }
    for (final StreamController<List<Assignment>> c in _doctorStreams.values) {
      c.close();
    }
  }
}
