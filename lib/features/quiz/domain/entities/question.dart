import 'package:equatable/equatable.dart';

import 'question_option.dart';
import 'question_type.dart';

class Question extends Equatable {
  const Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const <QuestionOption>[],
    this.required = true,
    this.helpText,
    this.minValue,
    this.maxValue,
    this.weight = 1.0,
  });

  final String id;
  final String text;
  final QuestionType type;

  /// Used by single/multi/likert. Empty otherwise.
  final List<QuestionOption> options;

  final bool required;
  final String? helpText;

  // Numeric constraints (numeric questions only)
  final num? minValue;
  final num? maxValue;

  /// Multiplier applied to this question's chosen-option score before summing.
  /// Most clinical instruments use 1.0; included for custom quizzes where
  /// some items count more than others.
  final double weight;

  bool get contributesToScore =>
      type == QuestionType.singleChoice ||
      type == QuestionType.multiSelect ||
      type == QuestionType.likert5 ||
      type == QuestionType.yesNo;

  @override
  List<Object?> get props => <Object?>[
        id,
        text,
        type,
        options,
        required,
        helpText,
        minValue,
        maxValue,
        weight,
      ];
}
