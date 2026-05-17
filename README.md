# MedQuiz

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue)]()

A small Flutter app I've been building to play with the idea of moving psychiatric screening questionnaires (PHQ-9, GAD-7, MMSE) off paper and onto a phone. The patient fills out the form on their device, it auto-scores against the published rubric, and the doctor reviews the result on a web dashboard and can adjust the score and add notes.

Not meant for real clinical use. It's a side project that started life as coursework.

## What it does

Patient side: phone number + OTP to sign in (one less password to forget), see assigned questionnaires, fill them out one question per screen with big tap targets, look at past results and any notes the doctor left.

Doctor side: email + password, dashboard with pending reviews and a patient list, ability to assign one of the built-in questionnaires or build a custom one, review responses question by question, override the auto-score, leave a note.

## Built-in questionnaires

- PHQ-9, depression severity. 9 items, 0 to 27, five bands from Minimal to Severe.
- GAD-7, generalized anxiety. 7 items, 0 to 21.
- MMSE, cognitive screening. 30 points across 11 task groups.

Scoring follows the published rubrics with citations in the code. Covered by unit tests.

You can also build custom questionnaires from six question types: single choice, multi-select, Likert (5-point), yes/no, numeric range, free text.

## Stack

- Flutter 3.27+, Dart 3.4+
- Riverpod 3 for state
- go_router 17 for routing
- Firebase Auth + Firestore + Storage (optional, see below)
- flutter_form_builder for forms
- fl_chart for the doctor's progress charts
- flutter_localizations (English is the only one fully translated, Tamil and Hindi are stubbed)

## Running it

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.27 or newer. Then:

```bash
git clone https://github.com/omprxkash/flutter-app-hci.git
cd flutter-app-hci
flutter pub get
flutter create .          # regenerates android/ ios/ web/ if missing
flutter run -d chrome     # or -d windows, -d android, etc.
```

The app boots in offline mode by default. No Firebase setup needed. There's a seeded demo doctor and patient:

| Role    | Login                                       |
|---------|---------------------------------------------|
| Doctor  | `doctor@demo.local` / `password123`         |
| Patient | any phone number + any 6-digit OTP          |

To wire up a real Firebase backend instead, run `flutterfire configure` and replace `lib/firebase_options.dart` with the generated one. The full walk-through is in [`docs/setup.md`](docs/setup.md).

### Getting around

Both flows have a bottom nav bar:

- Patient: Home (assigned quizzes), History (past results), Profile.
- Doctor: Dashboard (stats, pending reviews, patients), Library (quizzes), Profile.

## Screenshots

Coming soon. See [docs/screenshots/](docs/screenshots/) for what I want to capture.

## Project layout

```
lib/
├── core/           theme, router, shared widgets, utils
└── features/
    ├── auth/       patient OTP + doctor email login
    ├── patient/    home, quiz flow, history, profile
    ├── quiz/       domain entities, preset quizzes, scoring
    └── doctor/     dashboard, patient detail, review, quiz builder
```

Clean architecture, sort of. Domain has zero Flutter imports. Repos have both in-memory and Firebase implementations. Errors come back as `Result<T, Failure>` instead of thrown exceptions so the type system forces you to handle them. More in [`docs/architecture.md`](docs/architecture.md).

## Design notes

A few decisions worth writing down somewhere, because they're easy to forget the reasoning behind:

One question per screen. Reduces cognitive load and matches what patients already know from paper forms.

Minimum 48dp tap targets and 18sp body text. The target users include elderly patients and people who don't have their reading glasses on.

Phone OTP instead of email/password. A lot of patients in the demographic I'm targeting (low-literacy, elderly) don't manage their own email reliably.

Likert as five large buttons, not a slider. Sliders are imprecise on touchscreens and genuinely confusing for people with motor impairments.

The doctor can always override the auto-score. Arithmetic doesn't beat clinical judgement.

## Status

- [x] Architecture + feature scaffolding
- [x] Auth (patient OTP, doctor email)
- [x] Quiz domain + preset library (PHQ-9, GAD-7, MMSE)
- [x] Patient screens (home, take quiz, result, history)
- [x] Doctor screens (dashboard, review, quiz builder, assign)
- [x] Firestore rules + indexes
- [x] Unit tests for scoring
- [ ] CI
- [ ] End-to-end tests
- [ ] Production Firebase + deployed web build

## License

MIT. See [LICENSE](LICENSE).
