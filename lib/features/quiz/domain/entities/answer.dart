import 'package:equatable/equatable.dart';

/// A patient's answer to a single question. The shape depends on the
/// question's `QuestionType`:
///   - singleChoice / likert5 / yesNo -> `selectedOptionIds` has one entry
///   - multiSelect                    -> `selectedOptionIds` has 0..n entries
///   - numeric                        -> `numericValue` is set
///   - freeText                       -> `textValue` is set
class Answer extends Equatable {
  const Answer({
    required this.questionId,
    this.selectedOptionIds = const <String>[],
    this.numericValue,
    this.textValue,
  });

  final String questionId;
  final List<String> selectedOptionIds;
  final num? numericValue;
  final String? textValue;

  bool get isEmpty =>
      selectedOptionIds.isEmpty &&
      numericValue == null &&
      (textValue == null || textValue!.trim().isEmpty);

  Answer copyWith({
    List<String>? selectedOptionIds,
    num? numericValue,
    String? textValue,
  }) {
    return Answer(
      questionId: questionId,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      numericValue: numericValue ?? this.numericValue,
      textValue: textValue ?? this.textValue,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    questionId,
    selectedOptionIds,
    numericValue,
    textValue,
  ];
}
