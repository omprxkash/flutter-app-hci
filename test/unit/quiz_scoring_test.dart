import 'package:flutter_test/flutter_test.dart';
import 'package:medquiz_hci/features/quiz/data/preset_quizzes.dart';
import 'package:medquiz_hci/features/quiz/domain/entities/answer.dart';
import 'package:medquiz_hci/features/quiz/domain/entities/quiz.dart';
import 'package:medquiz_hci/features/quiz/domain/usecases/score_response.dart';

void main() {
  const ScoreResponse score = ScoreResponse();

  group('PHQ-9 scoring', () {
    final Quiz phq9 = PresetQuizzes.phq9();

    test('all "Not at all" -> 0 (minimal)', () {
      final List<Answer> answers = phq9.questions
          .map((q) => Answer(questionId: q.id, selectedOptionIds: <String>['0']))
          .toList();
      final ScoreResult r = score(phq9, answers);
      expect(r.score, 0);
      expect(r.severityLabel, 'Minimal');
      expect(r.maxPossibleScore, 27);
    });

    test('all "Nearly every day" -> 27 (severe)', () {
      final List<Answer> answers = phq9.questions
          .map((q) => Answer(questionId: q.id, selectedOptionIds: <String>['3']))
          .toList();
      final ScoreResult r = score(phq9, answers);
      expect(r.score, 27);
      expect(r.severityLabel, 'Severe');
    });

    test('mid-range score -> moderate band', () {
      // Choose options to sum exactly 12 (moderate band: 10-14).
      final List<Answer> answers = <Answer>[
        for (int i = 0; i < 9; i++)
          Answer(
            questionId: phq9.questions[i].id,
            selectedOptionIds: <String>[i < 4 ? '2' : '1'], // 2*4 + 1*5 = 13
          ),
      ];
      final ScoreResult r = score(phq9, answers);
      expect(r.score, 13);
      expect(r.severityLabel, 'Moderate');
    });

    test('blank answers count as zero', () {
      final ScoreResult r = score(phq9, <Answer>[]);
      expect(r.score, 0);
      expect(r.severityLabel, 'Minimal');
    });
  });

  group('GAD-7 scoring', () {
    final Quiz gad7 = PresetQuizzes.gad7();

    test('all "Not at all" -> 0 (minimal)', () {
      final List<Answer> answers = gad7.questions
          .map((q) => Answer(questionId: q.id, selectedOptionIds: <String>['0']))
          .toList();
      final ScoreResult r = score(gad7, answers);
      expect(r.score, 0);
      expect(r.severityLabel, 'Minimal');
      expect(r.maxPossibleScore, 21);
    });

    test('all "Nearly every day" -> 21 (severe)', () {
      final List<Answer> answers = gad7.questions
          .map((q) => Answer(questionId: q.id, selectedOptionIds: <String>['3']))
          .toList();
      final ScoreResult r = score(gad7, answers);
      expect(r.score, 21);
      expect(r.severityLabel, 'Severe');
    });

    test('score 7 -> mild band', () {
      // 7 = 3 + 2 + 2 + 0 + 0 + 0 + 0
      final List<Answer> answers = <Answer>[
        Answer(questionId: gad7.questions[0].id, selectedOptionIds: const <String>['3']),
        Answer(questionId: gad7.questions[1].id, selectedOptionIds: const <String>['2']),
        Answer(questionId: gad7.questions[2].id, selectedOptionIds: const <String>['2']),
        Answer(questionId: gad7.questions[3].id, selectedOptionIds: const <String>['0']),
        Answer(questionId: gad7.questions[4].id, selectedOptionIds: const <String>['0']),
        Answer(questionId: gad7.questions[5].id, selectedOptionIds: const <String>['0']),
        Answer(questionId: gad7.questions[6].id, selectedOptionIds: const <String>['0']),
      ];
      final ScoreResult r = score(gad7, answers);
      expect(r.score, 7);
      expect(r.severityLabel, 'Mild');
    });
  });

  group('Preset library', () {
    test('contains PHQ-9, GAD-7, and MMSE', () {
      final List<Quiz> all = PresetQuizzes.all();
      expect(all.map((q) => q.id), containsAll(<String>['preset_phq9', 'preset_gad7', 'preset_mmse']));
    });

    test('all presets are flagged isPreset', () {
      expect(PresetQuizzes.all().every((q) => q.isPreset), isTrue);
    });

    test('all presets cite a reference', () {
      expect(PresetQuizzes.all().every((q) => q.reference != null && q.reference!.isNotEmpty), isTrue);
    });
  });
}
