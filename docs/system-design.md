# MedQuiz — System Design

## Overview

MedQuiz is a cross-platform psychiatric screening app built with Flutter. It supports two roles — **Doctor** and **Patient** — and three built-in clinical instruments (PHQ-9, GAD-7, MMSE). Patients can take quizzes self-service or via doctor assignment; doctors review responses and track patient progress.

---

## 1. Application Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          Presentation Layer                          │
│                                                                      │
│  auth/screens        patient/screens         doctor/screens          │
│  ─────────────       ───────────────         ─────────────           │
│  SplashScreen        PatientHomeScreen       DoctorDashboard         │
│  RoleSelection       SelfServiceQuizScreen   QuizLibraryScreen       │
│  PatientLogin        TakeQuizScreen          QuizBuilderScreen       │
│  PatientRegister     QuizResultScreen        AssignQuizScreen        │
│  OtpVerification     PatientHistory          PatientDetailScreen     │
│  DoctorLogin         PatientProfile          ReviewResponseScreen    │
│                                              DoctorProfileScreen     │
│                                                                      │
│  State management: Flutter Riverpod (StreamProvider / FutureProvider │
│  / Notifier). Widgets watch providers and rebuild reactively.        │
│                                                                      │
│  Navigation: GoRouter with StatefulShellRoute (indexed-stack tabs)   │
│  Patient shell: Home · History · Profile                             │
│  Doctor shell:  Dashboard · Library · Profile                        │
└────────────────────────────┬─────────────────────────────────────────┘
                             │ providers (ref.watch / ref.read)
┌────────────────────────────▼─────────────────────────────────────────┐
│                           Domain Layer                               │
│                                                                      │
│  Entities: AppUser · Quiz · Question · Answer · Assignment           │
│            QuizResponse · Review · SeverityBand                      │
│                                                                      │
│  Repositories (abstract interfaces):                                 │
│    AuthRepository        QuizRepository      ResponseRepository      │
│                                                                      │
│  Use cases:                                                          │
│    ScoreResponse  — pure function, no I/O, fully unit-testable       │
└────────────────────────────┬─────────────────────────────────────────┘
                             │ implements
┌────────────────────────────▼─────────────────────────────────────────┐
│                            Data Layer                                │
│                                                                      │
│  InMemory (offline/demo)         Firebase (production)               │
│  ────────────────────            ─────────────────────               │
│  InMemoryAuthRepository          FirebaseAuthRepository              │
│  InMemoryQuizRepository          (FirestoreQuizRepository — planned) │
│  InMemoryResponseRepository      (FirestoreResponseRepository — TBD) │
│                                                                      │
│  Switch controlled by: firebaseAvailableProvider (bool)              │
│  If Firebase initialises → Firebase repos; otherwise → InMemory.     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Patient Flow

```
App launch
    │
    ▼
SplashScreen  ──── auth state? ────►  (signed in as patient)
    │                                        │
    ▼ not signed in                          ▼
RoleSelectionScreen               PatientHomeScreen (tab shell)
    │                                   │
    ▼ "I'm a patient"         user.doctorId == null?
PatientLoginScreen                      │
    │                          YES ──────┴────── NO
    ├─ existing user                    │               │
    │   └─ OtpVerification        Self-service     Assigned quizzes
    │                              empty state     from doctor
    └─ new user                         │
        └─ PatientRegistration    "Start a Self-Check"
                │                       │
                └─ OtpVerification  SelfServiceQuizScreen
                        │              (PHQ-9 · GAD-7 · MMSE)
                        ▼                       │
                 PatientHomeScreen ◄────────────┘
                        │
                        ▼
                  TakeQuizScreen
                  ─────────────
                  • Progress bar + "Q X of Y"
                  • Back / Next navigation
                  • Submit → confirmation dialog
                        │
                        ▼
                  QuizResultScreen
                  ─────────────────
                  • Auto-score + severity band
                  • Doctor's review (when available)
```

---

## 3. Doctor Flow

```
DoctorLoginScreen (email + password)
    │
    ▼
DoctorDashboardScreen
    ├─ stats: pending reviews, total patients, this-week completions
    ├─ assignments awaiting review
    │
    ├─ QuizLibraryScreen
    │   ├─ Preset quizzes (PHQ-9, GAD-7, MMSE) — view only
    │   └─ Custom quizzes ── QuizBuilderScreen (create / edit)
    │
    ├─ AssignQuizScreen
    │   └─ Pick patient + quiz + due date + optional note
    │
    └─ PatientDetailScreen
        ├─ Demographics
        ├─ Assignment history
        └─ ReviewResponseScreen
            └─ Auto-score · Severity band · Doctor's final score + notes
```

---

## 4. Data Model

```
users/{uid}
  id, role (patient|doctor), displayName, createdAt
  phone?, age?, gender?, doctorId?       ← patient fields
  email?, specialty?, licenseNumber?     ← doctor fields
  preferredLocale

quizzes/{quizId}
  title, description, questions[], severityBands[]
  createdBy ('system' for presets), estimatedMinutes, isPreset

assignments/{assignmentId}
  quizId, quizTitle, patientId, doctorId
  status (pending|inProgress|completed|reviewed|expired)
  assignedAt, dueAt?, completedAt?, responseId?, notes?

  Special doctorId values:
    'self'  — patient started the quiz without a doctor (self-service mode)

responses/{responseId}
  assignmentId, quizId, patientId, doctorId
  answers[], autoScore, maxPossibleScore, severityLabel
  submittedAt, durationSeconds?

reviews/{reviewId}
  responseId, doctorId, finalScore, notes, followUpDays?
  createdAt
```

---

## 5. Self-Service vs. Doctor-Managed Patient Modes

```
New patient registers (phone OTP)
         │
         ▼
  user.doctorId = null  ←────────────── self-service mode
         │
         ├─ Can take PHQ-9 / GAD-7 / MMSE any time
         │  (assignments created with doctorId = 'self')
         │
         └─ Profile → "Connect to a Doctor"
              Enter doctor's invite code
              authController.updateProfile(user.copyWith(doctorId: code))
                       │
                       ▼
               user.doctorId = <doctorId>  ←── doctor-managed mode
                       │
                       └─ Home shows assigned quizzes from doctor
                          Self-service quizzes remain in history
```

---

## 6. Riverpod Provider Graph (key providers)

```
firebaseAvailableProvider (bool)
    │
    ├──► authRepositoryProvider  ──► authStateChangesProvider (Stream<AppUser?>)
    │                           └──► authControllerProvider  (Notifier)
    │
    ├──► quizRepositoryProvider  ──► patientAssignmentsProvider(patientId)
    │                           ├──► quizByIdProvider(quizId)
    │                           └──► scoreResponseProvider
    │
    └──► responseRepositoryProvider ──► patientResponsesProvider(patientId)
                                   └──► responseByIdProvider(responseId)
```

---

## 7. Scoring

All scoring is handled by `ScoreResponse` — a pure function with no I/O:

```
ScoreResponse.call(quiz, answers) → ScoreResult
  ├─ sum option scores weighted by question.weight
  ├─ compute maxPossibleScore
  ├─ look up quiz.severityBands to find matching range
  └─ return (score, maxPossibleScore, severityLabel)
```

Severity bands are defined per quiz (e.g., PHQ-9: Minimal 0–4, Mild 5–9,
Moderate 10–14, Moderately Severe 15–19, Severe 20–27).

---

## 8. CI/CD Pipeline

```
Developer pushes to main (or opens PR)
         │
         ▼
  GitHub Actions: CI / CD workflow
         │
         ├─ [test] ───────────────────────────────────────────────────────►
         │    dart format check (lib/ + test/)
         │    flutter analyze --fatal-infos
         │    flutter test test/unit   → coverage/lcov.info
         │    flutter test test/widget
         │    upload coverage artifact
         │
         ├─ [build-web]  (needs: test) ───────────────────────────────────►
         │    flutter build web --release --web-renderer canvaskit
         │    upload build/web as artifact (7-day retention)
         │
         ├─ [build-android]  (needs: test) ──────────────────────────────►
         │    flutter build apk --debug
         │    upload app-debug.apk artifact (14-day retention)
         │
         └─ [deploy-web]  (STUBBED — needs: build-web, main branch only)
              download web-release artifact
              FirebaseExtended/action-hosting-deploy
              → Firebase Hosting (medquiz-hci.web.app)

  To enable deployment:
    1. Firebase Console → Project settings → Service accounts
       → Generate new private key (JSON)
    2. GitHub repo → Settings → Secrets → FIREBASE_SERVICE_ACCOUNT
       paste JSON value
    3. Uncomment the deploy-web job in .github/workflows/ci.yml
```

---

## 9. Localisation

The app ships with three locales built via `flutter gen-l10n`:

| Locale | Language | ARB source |
|--------|----------|------------|
| `en`   | English  | `lib/l10n/app_en.arb` |
| `hi`   | Hindi    | `lib/l10n/app_hi.arb` |
| `ta`   | Tamil    | `lib/l10n/app_ta.arb` |

Generated output (`lib/generated/l10n/`) is excluded from git and
regenerated at build time via `l10n.yaml`.

---

## 10. Firebase Security Rules Summary

```
/users/{uid}
  read:  uid == request.auth.uid OR user is doctor of this patient
  write: uid == request.auth.uid

/quizzes/{quizId}
  read:  authenticated users
  write: doctor role only (for custom quizzes)

/assignments/{id}
  read:  patient or doctor named in assignment
  write: doctor (create/update) or patient (update status only)

/responses/{id}
  read:  patient or doctor named in response
  write: patient (create once), doctor (add review)

/reviews/{id}
  read:  patient or doctor named in review
  write: doctor (write-once)
```
