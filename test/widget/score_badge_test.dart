import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medquiz_hci/features/quiz/domain/entities/severity_band.dart';
import 'package:medquiz_hci/features/quiz/presentation/widgets/score_badge.dart';

void main() {
  testWidgets('renders score with maxScore in "x / y" format', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScoreBadge(score: 12, maxScore: 27, band: StandardSeverityBands.moderate),
        ),
      ),
    );
    expect(find.text('12 / 27'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget);
  });

  testWidgets('renders just the score when no maxScore provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ScoreBadge(score: 5, label: 'Score')),
      ),
    );
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
  });
}
