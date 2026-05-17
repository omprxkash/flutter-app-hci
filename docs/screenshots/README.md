# Screenshots

Drop screenshots here and they'll render in the main README.

Suggested set (one per major flow):

| Filename | What to capture |
|---|---|
| `patient-home.png` | Patient home with at least one pending and one completed assignment |
| `take-quiz.png` | A question mid-quiz (PHQ-9 Likert is the most visually telling) |
| `quiz-result.png` | Result screen with score band + doctor note placeholder |
| `doctor-dashboard.png` | Dashboard with stats row + pending review cards |
| `review-response.png` | Doctor reviewing a response, with the override-score field visible |
| `quiz-builder.png` | Custom quiz builder with at least 2 question types added |

## Capturing

```bash
flutter run -d chrome
# Set window to 390x844 (iPhone 14 size) for mobile-style shots
# Use the browser's screenshot tool or DevTools device toolbar
```

Once images are here, reference them in the main README like:

```markdown
![Patient home](docs/screenshots/patient-home.png)
```
