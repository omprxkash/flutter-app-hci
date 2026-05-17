import 'package:flutter/material.dart';

import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/question_type.dart';
import 'free_text_field.dart';
import 'likert_scale.dart';
import 'multiple_choice_field.dart';
import 'numeric_field.dart';
import 'yes_no_field.dart';

/// Renders a single question + the correct input widget for its type.
/// Owns no state — receives the current `Answer` and a callback for updates.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.answer,
    required this.onChanged,
    super.key,
  });

  final Question question;
  final Answer? answer;
  final ValueChanged<Answer> onChanged;

  Answer _ensureAnswer() => answer ?? Answer(questionId: question.id);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          question.text,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (question.helpText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            question.helpText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 28),
        _buildInput(context),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    final Answer current = _ensureAnswer();
    switch (question.type) {
      case QuestionType.likert5:
        return LikertScaleField(
          options: question.options,
          selectedId: current.selectedOptionIds.isEmpty ? null : current.selectedOptionIds.first,
          onChanged: (String id) => onChanged(current.copyWith(selectedOptionIds: <String>[id])),
        );

      case QuestionType.singleChoice:
        return MultipleChoiceField(
          options: question.options,
          selectedIds: current.selectedOptionIds,
          onChanged: (List<String> ids) => onChanged(current.copyWith(selectedOptionIds: ids)),
        );

      case QuestionType.multiSelect:
        return MultipleChoiceField(
          options: question.options,
          selectedIds: current.selectedOptionIds,
          allowMultiple: true,
          onChanged: (List<String> ids) => onChanged(current.copyWith(selectedOptionIds: ids)),
        );

      case QuestionType.yesNo:
        return YesNoField(
          options: question.options,
          selectedId: current.selectedOptionIds.isEmpty ? null : current.selectedOptionIds.first,
          onChanged: (String id) => onChanged(current.copyWith(selectedOptionIds: <String>[id])),
        );

      case QuestionType.numeric:
        return NumericAnswerField(
          value: current.numericValue,
          minValue: question.minValue,
          maxValue: question.maxValue,
          onChanged: (num? v) => onChanged(current.copyWith(numericValue: v)),
        );

      case QuestionType.freeText:
        return FreeTextAnswerField(
          value: current.textValue,
          onChanged: (String v) => onChanged(current.copyWith(textValue: v)),
        );
    }
  }
}

