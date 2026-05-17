# MedQuiz

[![CI](https://github.com/omprxkash/flutter-app-hci/actions/workflows/ci.yml/badge.svg)](https://github.com/omprxkash/flutter-app-hci/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.37+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Flutter app for running psychiatric screening questionnaires between doctors and their patients — PHQ-9, GAD-7, MMSE, or custom ones the doctor builds.

---

## The idea

The flow is straightforward:

1. **Doctor logs in** → sees a dashboard with their patients and any responses waiting for review
2. **Doctor assigns a quiz** to a patient (PHQ-9 for depression screening, GAD-7 for anxiety, MMSE for cognitive screening, or a custom one they build)
3. **Patient opens the app** → sees the assigned quiz on their home screen, taps to fill it out
4. **Patient submits** → the app auto-scores against the published rubric and shows the result with a severity band
5. **Doctor reviews** → can see the patient's answers, adjust the score if their clinical judgment says so, and leave notes with a follow-up date

That's the whole loop. Nothing fancy — just getting paper forms off clipboards and onto phones.

---

## Screenshots

| Patient home | Quiz result | Doctor dashboard |
|---|---|---|
| *docs/screenshots/06-patient-home.png* | *docs/screenshots/08-quiz-result.png* | *docs/screenshots/03-doctor-dashboard.png* |

*(Screenshots coming — run the app and you'll see it)*

---

## Where the data lives

By default everything is **in-memory**. That means:

- No database setup needed to run it
- All data is gone when you restart the app
- Perfect for trying it out, useless for production

If you want real persistence, run `flutterfire configure` in the project root and replace `lib/firebase_options.dart` with the generated file. The app will automatically switch to Firestore. Full steps are in [`docs/setup.md`](docs/setup.md).

### What's seeded on startup

| Demo account | Details |
|---|---|
| Doctor | Dr. Demo · General Medicine · `doctor@demo.local` / `password123` |
| Patient 1 | Anjali Demo · 34 F · linked to Dr. Demo |
| Patient 2 | Rahul Patel · 52 M · linked to Dr. Demo |
| Patient 3 | Maria Lopez · 41 F · linked to Dr. Demo |

Quizzes available out of the box: PHQ-9, GAD-7, MMSE. The doctor can also build custom questionnaires from six question types.

---

## Logging in

**Doctor:** email + password. Use `doctor@demo.local` / `password123` for the demo account.

**Patient:** phone number + 6-digit OTP.

> **Important:** in the default in-memory mode, no SMS is ever sent. The OTP screen accepts any 6-digit number — just type `123456` and it'll work. This is intentional for demo use. Once you wire up Firebase and a real SMS provider, the verification becomes real.

---

## Run it

You need [Flutter 3.37+](https://docs.flutter.dev/get-started/install).

```bash
git clone https://github.com/omprxkash/flutter-app-hci.git
cd flutter-app-hci
flutter pub get
flutter run -d chrome        # or -d windows, -d android, etc.
```

Both roles have a bottom navigation bar. Patient gets Home / History / Profile. Doctor gets Dashboard / Library / Profile.

---

## Quiz scoring

| Quiz | Items | Range | Bands |
|---|---|---|---|
| PHQ-9 (depression) | 9 | 0–27 | Minimal / Mild / Moderate / Moderately severe / Severe |
| GAD-7 (anxiety) | 7 | 0–21 | Minimal / Mild / Moderate / Severe |
| MMSE (cognitive) | 30 tasks | 0–30 | Normal / Mild impairment / Moderate / Severe |

Scoring follows published rubrics. Covered by unit tests in `test/unit/`. The doctor can always override the auto-score — arithmetic doesn't beat clinical judgment.

---

## What I'm thinking of adding next

- **PHQ-9 Q9 alert** — auto-flag to the doctor dashboard any time Q9 (suicidal ideation) is answered above 0, regardless of total score
- **Reminder notifications** — nudge patients who have a pending quiz and haven't opened it in a day or two
- **Progress chart** — sparkline of the last 6 scores on the patient's doctor-detail screen, so trends are visible at a glance
- **Multi-doctor support** — right now each patient has one `doctorId`; changing that to a list would let a patient be shared across a care team
- **Real SMS/email verification** — straightforward once Firebase Auth is wired up; the OTP flow is already in place
- **Audit log for score overrides** — track when a doctor changes the auto-score and by how much, stored alongside the review

---

## Stack

- Flutter 3.37+ / Dart 3.10+
- Riverpod 3 (state management)
- go_router 17 (routing, `StatefulShellRoute` for persistent bottom nav)
- Firebase Auth + Firestore (optional; in-memory by default)
- flutter_form_builder, fl_chart, google_fonts, intl

Clean architecture: domain has zero Flutter imports, repos have in-memory and Firebase implementations side by side. More in [`docs/architecture.md`](docs/architecture.md).

---

## License

MIT. See [LICENSE](LICENSE).
