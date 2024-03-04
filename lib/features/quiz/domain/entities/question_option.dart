import 'package:equatable/equatable.dart';

/// A single selectable option in a `singleChoice`, `multiSelect`, or `likert5`
/// question. The `score` contributes to the quiz total when this option is
/// chosen.
class QuestionOption extends Equatable {
  const QuestionOption({
    required this.id,
    required this.label,
    required this.score,
  });

  final String id;
  final String label;

  /// Point value if this option is selected.
  final int score;

  @override
  List<Object?> get props => <Object?>[id, label, score];
}
