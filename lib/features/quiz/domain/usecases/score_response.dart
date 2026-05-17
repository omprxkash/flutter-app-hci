import '../entities/answer.dart';
import '../entities/question.dart';
import '../entities/question_type.dart';
import '../entities/quiz.dart';

/// Pure scoring function. Takes a quiz definition and a list of answers,
/// returns the integer auto-score by summing each chosen option's `score`
/// value times the question's `weight`. Unselected or non-scoring question
/// types contribute zero.
///
/// Lifted to its own use case so it can be unit-tested in isolation and
/// reused by both the patient submission flow and the doctor review screen.
class ScoreResponse {
  const ScoreResponse();

  ScoreResult call(Quiz quiz, List<Answer> answers) {
    int total = 0;
    final Map<String, Answer> byQuestion = <String, Answer>{
      for (final Answer a in answers) a.questionId: a,
    };

    for (final Question q in quiz.questions) {
      if (!q.contributesToScore) continue;
      final Answer? ans = byQuestion[q.id];
      if (ans == null || ans.selectedOptionIds.isEmpty) continue;

      int subtotal = 0;
      for (final String optionId in ans.selectedOptionIds) {
        final int score = q.options
                .where((opt) => opt.id == optionId)
                .map((opt) => opt.score)
                .firstOrNull() ??
            0;
        subtotal += score;
      }

      // For single-choice/likert/yesNo only one option is allowed; for
      // multi-select all chosen options sum. Either way the weight applies
      // once to the subtotal.
      if (q.type == QuestionType.singleChoice ||
          q.type == QuestionType.likert5 ||
          q.type == QuestionType.yesNo) {
        // Defensive: clamp to a single option's worth even if multiple were
        // somehow set.
        final int singleScore =
            subtotal ~/ (ans.selectedOptionIds.isEmpty ? 1 : ans.selectedOptionIds.length);
        total += (singleScore * q.weight).round();
      } else {
        total += (subtotal * q.weight).round();
      }
    }

    final int max = quiz.maxPossibleScore;
    final String? label = quiz.bandFor(total)?.label;

    return ScoreResult(
      score: total,
      maxPossibleScore: max,
      severityLabel: label,
    );
  }
}

class ScoreResult {
  const ScoreResult({
    required this.score,
    required this.maxPossibleScore,
    this.severityLabel,
  });

  final int score;
  final int maxPossibleScore;
  final String? severityLabel;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? firstOrNull() => isEmpty ? null : first;
}
