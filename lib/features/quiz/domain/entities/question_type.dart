/// Supported question types. Adding a new type requires:
///   1. Adding a case here
///   2. Updating `QuestionWidget` to render it
///   3. Updating `ScoreResponse` if it contributes to the score
enum QuestionType {
  /// Single-choice radio buttons.
  singleChoice,

  /// Multiple-select checkboxes.
  multiSelect,

  /// 5-point Likert scale rendered as labelled buttons.
  likert5,

  /// Numeric text input (integer or decimal).
  numeric,

  /// Free-form short text.
  freeText,

  /// Yes / No.
  yesNo;

  String get wireName => name;

  static QuestionType fromWire(String? value) {
    return QuestionType.values.firstWhere(
      (QuestionType t) => t.wireName == value,
      orElse: () => QuestionType.singleChoice,
    );
  }
}
