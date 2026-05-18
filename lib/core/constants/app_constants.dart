class AppConstants {
  const AppConstants._();

  static const String appName = 'MedQuiz';
  static const String supportEmail = 'support@medquiz.example';

  /// Minimum tap target size — WCAG 2.1 AA / Material spec.
  static const double minTapTargetDp = 48.0;

  /// Default body text size, chosen for readability on small devices and for
  /// patients who do not enable system font scaling.
  static const double defaultBodyFontSize = 18.0;

  /// Auto-save debounce window for quiz drafts.
  static const Duration draftSaveDebounce = Duration(milliseconds: 800);

  /// How long a Firebase phone OTP code is valid.
  static const Duration otpTimeout = Duration(seconds: 60);

  /// Max length of a doctor's clinical note on a single review.
  static const int maxReviewNoteLength = 2000;

  /// Soft cap on the number of questions allowed in a custom quiz.
  /// (Prevents runaway forms; clinical instruments rarely exceed 30 items.)
  static const int maxQuestionsPerQuiz = 50;

  /// Sentinel doctorId for quizzes a patient starts without a linked doctor.
  static const String selfServiceDoctorId = 'self';
}
