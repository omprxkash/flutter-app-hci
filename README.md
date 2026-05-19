# MedQuiz

[![CI](https://github.com/omprxkash/flutter-app-hci/actions/workflows/ci.yml/badge.svg)](https://github.com/omprxkash/flutter-app-hci/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Flutter app that lets doctors assign psychiatric screening questionnaires to their patients — think PHQ-9, GAD-7, MMSE — and review the results without digging through paper forms. Built as an HCI project, but designed to feel like something you'd actually want to use.

---

## What it does

The whole thing is a simple loop:

A doctor opens the app, sees their patients, and assigns a quiz. The patient gets it on their home screen, fills it in, and submits. The app scores it automatically and shows them where they land on the severity scale. The doctor then reviews it, can adjust the score if their gut says the numbers don't tell the full story, and adds follow-up notes.

That's it. No complex setup, no backend required to try it — everything runs in-memory by default.

---

## Running it locally

You'll need Flutter 3.44+. Then:

```bash
git clone https://github.com/omprxkash/flutter-app-hci.git
cd flutter-app-hci
flutter pub get
flutter run -d chrome
```

For web at a specific port:
```bash
flutter run -d web-server --web-port 8765
```

---

## Demo credentials

**Doctor login**
- Email: `doctor@demo.local`
- Password: `password123`

**Patient login**
Tap any name on the list — Anjali, Rahul, or Maria. No password needed in demo mode.

> The OTP screen in patient registration accepts any 6-digit code (`123456` works). No real SMS is sent unless you plug in Firebase Auth.

---

## Quizzes included

| Quiz | What it screens for | Score range |
|---|---|---|
| PHQ-9 | Depression | 0–27 |
| GAD-7 | Anxiety | 0–21 |
| MMSE | Cognitive impairment | 0–30 |

Scoring follows the published rubrics. Doctors can also build their own questionnaires from six question types (text, single choice, multi-select, scale, number, yes/no).

One thing worth mentioning: if a PHQ-9 response has Q9 > 0 (the suicidal ideation question), the doctor dashboard shows a red alert banner at the top. That one felt important to get right.

---

## Where data lives

Everything is in-memory by default — no database, no Firebase project needed to run it. Data resets on restart, which is fine for trying things out.

If you want real persistence, run `flutterfire configure` and replace `lib/core/config/firebase_options.dart` with the generated file. The app picks it up automatically.

---

## Stack

- **Flutter 3.44 / Dart 3.10**
- **Riverpod 3** — state management, one provider file per feature
- **go_router 17** — navigation with `StatefulShellRoute` for persistent bottom nav
- **google_fonts** — Poppins throughout
- **Firebase Auth + Firestore** — optional; swappable with the in-memory layer

The architecture is feature-first: `auth`, `doctor`, `patient`, and `quiz` each have their own `domain/`, `data/`, and `presentation/` folders. Domain layer has zero Flutter imports. The in-memory and Firebase data implementations live side by side in `data/` so swapping them is a one-line change in the provider.

---

## Design

Clean and light — `#F7FAFC` background, Poppins, colorful stat tiles, left-bordered list cards that signal status at a glance. The patient home has a deep indigo-to-purple header with pending/completed stat pills. The quiz result screen uses a full-color hero card tinted by the severity band — so a severe score looks visually different from a minimal one without needing to read the label.

Tablet/desktop gets a 2-column patient grid on the doctor dashboard at ≥720px.

---

## What's next

- Reminder notifications for patients who haven't started an assigned quiz in a day or two
- A score trend sparkline on the patient detail screen (last 6 results)
- Audit log when a doctor overrides the auto-score
- Real SMS verification once Firebase Auth is wired up

---

## License

MIT. See [LICENSE](LICENSE).
