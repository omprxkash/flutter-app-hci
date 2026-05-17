# Running locally

## Prerequisites

- Flutter 3.22+ (Dart 3.4+ is bundled with it)
- Node.js 18+ only if you want to use the Firebase CLI

Check everything's installed:

```bash
flutter doctor
```

## Quick start (no Firebase needed)

```bash
flutter pub get
flutter create .        # generates android/ ios/ web/ scaffolds, non-destructive
flutter run -d chrome   # or -d windows, or just flutter run for a connected device
```

The app boots in offline mode using in-memory repositories seeded with demo data, so nothing else is needed for a first run.

Demo credentials:
- Doctor: `doctor@demo.local` / `password123`
- Patient: any phone number, any 6-digit OTP

## Wiring up Firebase

If you want a real backend:

```bash
npm install -g firebase-tools
firebase login
firebase use --add          # pick or create a project
flutterfire configure       # generates lib/firebase_options.dart
```

In the Firebase console: enable Phone and Email/Password under Authentication, and create a Firestore database (test mode is fine to start).

Deploy the included security rules and indexes:

```bash
firebase deploy --only firestore
```

## Firebase emulators (recommended for dev)

```bash
firebase emulators:start
```

Starts Auth, Firestore, Functions, and Hosting locally. You'll need to point the app at the emulators. See the [Firebase emulator docs](https://firebase.flutter.dev/docs/auth/usage#using-the-authentication-emulator) for the few lines needed in `main.dart`.

## Tests

```bash
flutter test                                   # everything
flutter test test/unit/quiz_scoring_test.dart  # just scoring
flutter test --coverage                        # generates coverage/lcov.info
```

## Building for release

```bash
flutter build apk --release       # Android APK
flutter build appbundle --release # Play Store .aab
flutter build web --release       # static site in build/web
firebase deploy --only hosting    # push web build to Firebase Hosting
```

## Localization

ARB files are in `lib/l10n/`. After editing any `.arb` file, regenerate with:

```bash
flutter gen-l10n
```

Tamil and Hindi are stubbed. Only a handful of strings are translated.

## Common issues

`firebase_options.dart throws on launch`. Expected if you haven't run `flutterfire configure`. The app falls back to offline mode automatically.

`flutter pub get fails`. Check your Flutter/Dart SDK version with `flutter --version`. Needs 3.22+.

`OTP code never arrives`. Make sure Phone sign-in is enabled in the Firebase console under Authentication → Sign-in methods.

`Doctor can't see patient responses`. Firestore rules check that `users/{patientId}.doctorId == doctor.uid`. If you created users outside the normal flow, the ID might not be set correctly.
