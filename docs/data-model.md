# Data model

Firestore collections and document shapes. Path builders live in [`lib/core/constants/firestore_paths.dart`](../lib/core/constants/firestore_paths.dart).

## Collections at a glance

```
users/{uid}
users/{uid}/assignments/{assignmentId}    sub-collection — fast patient list
quizzes/{quizId}                          presets + custom
responses/{responseId}                    one document per submitted quiz
responses/{responseId}/reviews/{reviewId} doctor reviews (typically 0 or 1)
```

## users/{uid}

| Field | Type | Notes |
|---|---|---|
| `role` | string | `"patient"` or `"doctor"` |
| `displayName` | string | full name shown in UI |
| `phone` | string | patient only — E.164 format |
| `email` | string | doctor only |
| `age` | int | patient only |
| `gender` | string | patient only |
| `doctorId` | string | patient only — uid of their primary doctor |
| `specialty` | string | doctor only |
| `licenseNumber` | string | doctor only |
| `preferredLocale` | string | `"en"`, `"ta"`, `"hi"` |
| `createdAt` | timestamp | server-set on create |

**Indexes:** none required beyond default.

## users/{uid}/assignments/{assignmentId}

Lives under the patient so the patient home screen can issue a single sub-collection query.

| Field | Type | Notes |
|---|---|---|
| `quizId` | string | reference to `quizzes/{id}` |
| `quizTitle` | string | denormalized for list rendering |
| `patientId` | string | equals parent `uid` (kept for collection-group queries) |
| `doctorId` | string | doctor who assigned |
| `status` | string | `pending`, `inProgress`, `completed`, `reviewed`, `expired` |
| `assignedAt` | timestamp | |
| `dueAt` | timestamp | optional |
| `completedAt` | timestamp | set on submit |
| `responseId` | string | set on submit |
| `notes` | string | doctor's optional context |

**Indexes:** composite on (`doctorId`, `status`, `assignedAt desc`) — collection-group query for the doctor dashboard.

## quizzes/{quizId}

| Field | Type | Notes |
|---|---|---|
| `title` | string | |
| `description` | string | |
| `questions` | array<map> | each question is a sub-object (see below) |
| `createdBy` | string | uid, or `"system"` for presets |
| `createdAt` | timestamp | |
| `severityBands` | array<map> | optional, see below |
| `reference` | string | bibliographic citation for presets |
| `isPreset` | boolean | true for PHQ-9, GAD-7, MMSE |
| `estimatedMinutes` | int | optional |

### question (embedded)

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable id within the quiz |
| `text` | string | |
| `type` | string | one of: `singleChoice`, `multiSelect`, `likert5`, `yesNo`, `numeric`, `freeText` |
| `options` | array<map> | for choice types |
| `required` | boolean | |
| `helpText` | string | optional |
| `minValue`, `maxValue` | number | numeric only |
| `weight` | number | multiplier on this question's score (default 1.0) |

### severityBand (embedded)

| Field | Type | Notes |
|---|---|---|
| `label` | string | e.g. `"Moderate"` |
| `minInclusive` | int | |
| `maxInclusive` | int | |
| `colorHex` | int | RGB value of `Color`; not used in scoring |
| `guidance` | string | clinician-facing one-liner |

## responses/{responseId}

| Field | Type | Notes |
|---|---|---|
| `assignmentId` | string | |
| `quizId` | string | |
| `patientId` | string | |
| `doctorId` | string | denormalized for doctor queries |
| `answers` | array<map> | one per answered question |
| `submittedAt` | timestamp | |
| `autoScore` | int | computed client-side at submit |
| `maxPossibleScore` | int | derived from quiz; stored for stable history |
| `severityLabel` | string | matching band's label at submit time |
| `durationSeconds` | int | total time spent, for the doctor's reference |

**Indexes:**
- (`patientId`, `submittedAt desc`) — patient history
- (`doctorId`, `submittedAt desc`) — doctor "awaiting review" list

### answer (embedded)

| Field | Type | Notes |
|---|---|---|
| `questionId` | string | |
| `selectedOptionIds` | array<string> | for choice types |
| `numericValue` | number | numeric only |
| `textValue` | string | freeText only |

## responses/{responseId}/reviews/{reviewId}

A response has at most one review per doctor, but the design allows multiple for a future "second opinion" feature.

| Field | Type | Notes |
|---|---|---|
| `doctorId` | string | |
| `finalScore` | int | may differ from `autoScore` |
| `reviewedAt` | timestamp | |
| `notes` | string | clinical notes, visible to patient |
| `recommendedFollowUpInDays` | int | optional |

## Denormalization choices

We denormalize **quizTitle** onto `assignments` and **doctorId** onto `responses` to avoid joins for the two most common list views:

- Patient home: `users/{uid}/assignments` — no join to `quizzes` to render the list.
- Doctor dashboard: `responses where doctorId == :uid and not reviewed` — no join to `assignments`.

The trade-off: renaming a quiz won't retroactively change assignment titles. This is acceptable for clinical questionnaires, which are versioned by name (PHQ-9 is forever PHQ-9).
