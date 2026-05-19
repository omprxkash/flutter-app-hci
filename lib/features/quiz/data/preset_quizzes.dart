import '../../../core/theme/app_colors.dart';
import '../domain/entities/question.dart';
import '../domain/entities/question_option.dart';
import '../domain/entities/question_type.dart';
import '../domain/entities/quiz.dart';
import '../domain/entities/severity_band.dart';

/// Built-in clinical assessment library. Each entry is a faithful encoding of
/// the published instrument and its scoring rubric.
///
/// **Disclaimers:**
///   - These instruments are screening tools, not diagnostic tests.
///   - Scoring matches the published rubric but cannot substitute for
///     clinical judgement.
///   - Reproductions follow each instrument's public domain or fair-use
///     licensing (PHQ-9, GAD-7, MMSE/SMMSE are reprinted with attribution
///     in clinical settings; verify locally before commercial use).
class PresetQuizzes {
  const PresetQuizzes._();

  static const String _systemAuthor = 'system';

  /// All built-in quizzes.
  static List<Quiz> all() => <Quiz>[phq9(), gad7(), mmse()];

  // =====================================================================
  // PHQ-9 — Patient Health Questionnaire for depression
  // Reference: Kroenke K, Spitzer RL, Williams JB. J Gen Intern Med. 2001;
  //   16(9):606-13. PMID: 11556941.
  // =====================================================================
  static Quiz phq9() {
    // PHQ-9 Likert: 0=Not at all, 1=Several days, 2=More than half the days,
    // 3=Nearly every day.
    const List<QuestionOption> phqLikert = <QuestionOption>[
      QuestionOption(id: '0', label: 'Not at all', score: 0),
      QuestionOption(id: '1', label: 'Several days', score: 1),
      QuestionOption(id: '2', label: 'More than half the days', score: 2),
      QuestionOption(id: '3', label: 'Nearly every day', score: 3),
    ];

    const List<String> prompts = <String>[
      'Little interest or pleasure in doing things',
      'Feeling down, depressed, or hopeless',
      'Trouble falling or staying asleep, or sleeping too much',
      'Feeling tired or having little energy',
      'Poor appetite or overeating',
      'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
      'Trouble concentrating on things, such as reading the newspaper or watching television',
      'Moving or speaking so slowly that other people could have noticed. Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
      'Thoughts that you would be better off dead, or of hurting yourself in some way',
    ];

    return Quiz(
      id: 'preset_phq9',
      title: 'PHQ-9 — Patient Health Questionnaire',
      description:
          'A 9-item depression screening tool. Over the last 2 weeks, how often have you been bothered by any of the following problems?',
      isPreset: true,
      reference: 'Kroenke, Spitzer & Williams (2001), PMID 11556941',
      estimatedMinutes: 5,
      createdBy: _systemAuthor,
      createdAt: DateTime.utc(2024, 1, 1),
      questions: <Question>[
        for (int i = 0; i < prompts.length; i++)
          Question(
            id: 'phq9_q${i + 1}',
            text: prompts[i],
            type: QuestionType.likert5,
            options: phqLikert,
          ),
      ],
      severityBands: const <SeverityBand>[
        StandardSeverityBands.minimal,
        StandardSeverityBands.mild,
        StandardSeverityBands.moderate,
        StandardSeverityBands.moderatelySevere,
        StandardSeverityBands.severe,
      ],
    );
  }

  // =====================================================================
  // GAD-7 — Generalized Anxiety Disorder
  // Reference: Spitzer RL, Kroenke K, Williams JB, Löwe B. Arch Intern Med.
  //   2006;166(10):1092-7. PMID: 16717171.
  // =====================================================================
  static Quiz gad7() {
    const List<QuestionOption> gadLikert = <QuestionOption>[
      QuestionOption(id: '0', label: 'Not at all', score: 0),
      QuestionOption(id: '1', label: 'Several days', score: 1),
      QuestionOption(id: '2', label: 'More than half the days', score: 2),
      QuestionOption(id: '3', label: 'Nearly every day', score: 3),
    ];

    const List<String> prompts = <String>[
      'Feeling nervous, anxious, or on edge',
      'Not being able to stop or control worrying',
      'Worrying too much about different things',
      'Trouble relaxing',
      "Being so restless that it's hard to sit still",
      'Becoming easily annoyed or irritable',
      'Feeling afraid as if something awful might happen',
    ];

    return Quiz(
      id: 'preset_gad7',
      title: 'GAD-7 — Generalized Anxiety Disorder',
      description:
          'A 7-item anxiety screening tool. Over the last 2 weeks, how often have you been bothered by the following problems?',
      isPreset: true,
      reference: 'Spitzer, Kroenke, Williams & Löwe (2006), PMID 16717171',
      estimatedMinutes: 3,
      createdBy: _systemAuthor,
      createdAt: DateTime.utc(2024, 1, 1),
      questions: <Question>[
        for (int i = 0; i < prompts.length; i++)
          Question(
            id: 'gad7_q${i + 1}',
            text: prompts[i],
            type: QuestionType.likert5,
            options: gadLikert,
          ),
      ],
      severityBands: const <SeverityBand>[
        SeverityBand(
          label: 'Minimal',
          minInclusive: 0,
          maxInclusive: 4,
          color: AppColors.severityMinimal,
          guidance: 'No or minimal anxiety symptoms.',
        ),
        SeverityBand(
          label: 'Mild',
          minInclusive: 5,
          maxInclusive: 9,
          color: AppColors.severityMild,
          guidance: 'Watchful waiting; repeat at follow-up.',
        ),
        SeverityBand(
          label: 'Moderate',
          minInclusive: 10,
          maxInclusive: 14,
          color: AppColors.severityModerate,
          guidance:
              'Possible clinically significant anxiety; further evaluation recommended.',
        ),
        SeverityBand(
          label: 'Severe',
          minInclusive: 15,
          maxInclusive: 21,
          color: AppColors.severitySevere,
          guidance:
              'Active treatment with pharmacotherapy and/or psychotherapy is likely needed.',
        ),
      ],
    );
  }

  // =====================================================================
  // MMSE — Mini-Mental State Examination (simplified version)
  // Reference: Folstein, Folstein & McHugh (1975). PMID: 1202204.
  //
  // The MMSE is 30 items grouped into orientation / registration / attention
  // / recall / language / construction. For an app-administered version,
  // construction and some recall items are best done with a clinician
  // present; we encode the parts that are self-administrable in a screen.
  // Doctor must override the score if any in-clinic items were skipped.
  // =====================================================================
  static Quiz mmse() {
    const List<QuestionOption> oneZero = <QuestionOption>[
      QuestionOption(id: 'correct', label: 'Correct', score: 1),
      QuestionOption(id: 'incorrect', label: 'Incorrect', score: 0),
    ];

    return Quiz(
      id: 'preset_mmse',
      title: 'MMSE — Mini-Mental State Examination',
      description:
          'A 30-point screening test for cognitive impairment. Best administered with a clinician; the doctor may override the final score after in-clinic items.',
      isPreset: true,
      reference: 'Folstein, Folstein & McHugh (1975), PMID 1202204',
      estimatedMinutes: 10,
      createdBy: _systemAuthor,
      createdAt: DateTime.utc(2024, 1, 1),
      questions: <Question>[
        // Orientation to time (5 points)
        const Question(
          id: 'mmse_year',
          text: 'What year is it?',
          type: QuestionType.singleChoice,
          helpText: 'Orientation to time.',
          options: oneZero,
        ),
        const Question(
          id: 'mmse_season',
          text: 'What season is it?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_month',
          text: 'What month is it?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_date',
          text: "What's today's date?",
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_day',
          text: 'What day of the week is it?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        // Orientation to place (5 points)
        const Question(
          id: 'mmse_country',
          text: 'What country are we in?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_state',
          text: 'What state/province are we in?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_city',
          text: 'What city are we in?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_building',
          text: 'What building are we in?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        const Question(
          id: 'mmse_floor',
          text: 'What floor are we on?',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
        // Registration (3 points) — read three words, ask patient to repeat
        const Question(
          id: 'mmse_register',
          text: 'Repeat these three words: APPLE — PENNY — TABLE.',
          type: QuestionType.numeric,
          helpText: 'Score 1 point for each word correctly repeated (0-3).',
          minValue: 0,
          maxValue: 3,
        ),
        // Attention and calculation (5 points) — serial 7s
        const Question(
          id: 'mmse_serial7',
          text:
              'Subtract 7 from 100, and keep subtracting 7. (e.g. 93, 86, 79, 72, 65)',
          type: QuestionType.numeric,
          helpText: 'Score 1 point per correct subtraction up to 5.',
          minValue: 0,
          maxValue: 5,
        ),
        // Recall (3 points) — recall the three words
        const Question(
          id: 'mmse_recall',
          text: 'Recall the three words from earlier.',
          type: QuestionType.numeric,
          helpText: '1 point per word recalled (0-3).',
          minValue: 0,
          maxValue: 3,
        ),
        // Language (8 points) — naming (2), repetition (1), 3-stage command (3),
        // reading (1), writing (1)
        const Question(
          id: 'mmse_language',
          text:
              'Language tasks: naming objects, repeating a phrase, following a 3-stage command, reading a sentence, writing a sentence.',
          type: QuestionType.numeric,
          helpText: 'Sum of language sub-scores (0-8).',
          minValue: 0,
          maxValue: 8,
        ),
        // Construction (1 point) — copy intersecting pentagons
        const Question(
          id: 'mmse_pentagon',
          text: 'Copy the design of two intersecting pentagons.',
          type: QuestionType.singleChoice,
          options: oneZero,
        ),
      ],
      severityBands: const <SeverityBand>[
        SeverityBand(
          label: 'Severe impairment',
          minInclusive: 0,
          maxInclusive: 9,
          color: AppColors.severitySevere,
          guidance:
              'Severe cognitive impairment likely. Specialist referral indicated.',
        ),
        SeverityBand(
          label: 'Moderate impairment',
          minInclusive: 10,
          maxInclusive: 18,
          color: AppColors.severityModerate,
          guidance: 'Moderate impairment. Further workup recommended.',
        ),
        SeverityBand(
          label: 'Mild impairment',
          minInclusive: 19,
          maxInclusive: 23,
          color: AppColors.severityMild,
          guidance:
              'Possible mild cognitive impairment; consider repeat testing in 6-12 months.',
        ),
        SeverityBand(
          label: 'Normal',
          minInclusive: 24,
          maxInclusive: 30,
          color: AppColors.severityMinimal,
          guidance: 'No evidence of cognitive impairment from screening.',
        ),
      ],
    );
  }
}
