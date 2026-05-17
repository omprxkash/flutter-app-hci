# Notes

Quick reference for picking this up after a break.

## Run it

On my Windows box flutter isn't on PATH globally, so:

```powershell
$env:PATH = "$env:PATH;D:\flutter\bin"
cd "D:\Work\Github Repo\flutter-app-hci"
flutter run -d chrome
```

Logins for the in-memory mode:

- doctor@demo.local / password123
- any phone number, any 6-digit OTP

## Stack

Flutter 3.27+, Riverpod 3, go_router 17. No Firebase by default. The stub in `lib/firebase_options.dart` deliberately throws so the app falls back to the in-memory repos. To wire a real backend, see `docs/setup.md`.

## Gotchas I keep forgetting

- Riverpod 3 dropped `StateNotifierProvider`. Use `Notifier` / `NotifierProvider`.
- `AsyncValue.valueOrNull` is gone, use `.value` (returns `T?`).
- `Color.value` is deprecated in Flutter 3.27+, use `.toARGB32()`. Same story with `.withOpacity()` -> `.withValues()`.
- `assets/images/` and `assets/icons/` are empty. Only the `.gitkeep` files exist.
- All preset scoring rubrics live in `lib/features/quiz/data/preset_quizzes.dart`. PHQ-9, GAD-7, MMSE.

## Next

- PHQ-9 Q9 alert (flag patient to doctor dashboard if score > 0)
- Patient progress trend chart on doctor's patient detail screen
- Custom launcher icon (still the default Flutter F)
