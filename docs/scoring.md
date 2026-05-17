# Scoring

The preset questionnaires implement the published scoring rubrics exactly. Code is in `lib/features/quiz/data/preset_quizzes.dart`, unit tests in `test/unit/quiz_scoring_test.dart`.

## PHQ-9

9 items, each scored 0 (Not at all) → 1 (Several days) → 2 (More than half the days) → 3 (Nearly every day). Total: 0–27.

| Score | Severity | Suggested action |
|---|---|---|
| 0–4 | Minimal | No action |
| 5–9 | Mild | Watchful waiting; repeat at follow-up |
| 10–14 | Moderate | Counseling, follow-up, possible treatment |
| 15–19 | Moderately severe | Active treatment |
| 20–27 | Severe | Immediate clinical attention |

Source: Kroenke K, Spitzer RL, Williams JBW. The PHQ-9: validity of a brief depression severity measure. *J Gen Intern Med.* 2001;16(9):606-613. PMID 11556941.

## GAD-7

7 items, same 0–3 Likert as PHQ-9. Total: 0–21.

| Score | Severity |
|---|---|
| 0–4 | Minimal anxiety |
| 5–9 | Mild anxiety |
| 10–14 | Moderate anxiety |
| 15–21 | Severe anxiety |

Source: Spitzer RL et al. A brief measure for assessing generalized anxiety disorder: the GAD-7. *Arch Intern Med.* 2006;166(10):1092-1097. PMID 16717171.

## MMSE

30-point screen across 11 task groups: orientation to time (5), place (5), registration (3), attention/calculation (5), recall (3), language (8), construction (1). Total: 0–30.

| Score | Label |
|---|---|
| ≥24 | Normal cognition |
| 19–23 | Mild cognitive impairment |
| 10–18 | Moderate cognitive impairment |
| ≤9 | Severe cognitive impairment |

Note: some MMSE items (construction drawing, oral registration) really need a clinician in the room to administer properly. When those items aren't conducted in person, the doctor should override the auto-score on the review screen.

Source: Folstein MF, Folstein SE, McHugh PR. "Mini-mental state." *J Psychiatr Res.* 1975;12(3):189-198. PMID 1202204.

## Custom quizzes

Doctor-authored quizzes use a per-option `score: int` and per-question `weight: double`. The final score is:

```
sum(selected_option_score × question.weight) for each answered question
```

Multi-select: all chosen options' scores are summed. Numeric and free-text questions score zero automatically. The doctor reviews and scores those manually. Severity bands are optional. If omitted, the review screen just shows the raw score.
