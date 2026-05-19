import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medquiz_hci/features/quiz/domain/entities/question_option.dart';
import 'package:medquiz_hci/features/quiz/presentation/widgets/likert_scale.dart';

void main() {
  const List<QuestionOption> options = <QuestionOption>[
    QuestionOption(id: '0', label: 'Not at all', score: 0),
    QuestionOption(id: '1', label: 'Several days', score: 1),
    QuestionOption(id: '2', label: 'More than half the days', score: 2),
    QuestionOption(id: '3', label: 'Nearly every day', score: 3),
  ];

  testWidgets('renders one row per option and reports the tapped id', (
    WidgetTester tester,
  ) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LikertScaleField(
            options: options,
            selectedId: null,
            onChanged: (String id) => tapped = id,
          ),
        ),
      ),
    );

    for (final QuestionOption opt in options) {
      expect(find.text(opt.label), findsOneWidget);
    }

    await tester.tap(find.text('Several days'));
    expect(tapped, '1');
  });

  testWidgets('selected option shows the filled radio icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LikertScaleField(
            options: options,
            selectedId: '2',
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });
}
