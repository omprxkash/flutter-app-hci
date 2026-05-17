import 'package:equatable/equatable.dart';

import 'answer.dart';

class QuizResponse extends Equatable {
  const QuizResponse({
    required this.id,
    required this.assignmentId,
    required this.quizId,
    required this.patientId,
    required this.doctorId,
    required this.answers,
    required this.submittedAt,
    required this.autoScore,
    this.maxPossibleScore,
    this.severityLabel,
    this.durationSeconds,
  });

  final String id;
  final String assignmentId;
  final String quizId;
  final String patientId;
  final String doctorId;
  final List<Answer> answers;
  final DateTime submittedAt;

  /// Score computed automatically from option weights at submission time.
  final int autoScore;

  final int? maxPossibleScore;
  final String? severityLabel;

  /// How long the patient spent on the quiz (for HCI analytics).
  final int? durationSeconds;

  Answer? answerFor(String questionId) {
    for (final Answer a in answers) {
      if (a.questionId == questionId) return a;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        assignmentId,
        quizId,
        patientId,
        doctorId,
        answers,
        submittedAt,
        autoScore,
        maxPossibleScore,
        severityLabel,
        durationSeconds,
      ];
}
