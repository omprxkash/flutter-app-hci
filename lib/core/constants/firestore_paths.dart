/// Centralized Firestore collection + document path builders.
///
/// Every read/write in the data layer goes through this class so renaming a
/// collection is a single-file change and so paths are testable in isolation.
class FirestorePaths {
  const FirestorePaths._();

  static const String _users = 'users';
  static const String _quizzes = 'quizzes';
  static const String _assignments = 'assignments';
  static const String _responses = 'responses';
  static const String _reviews = 'reviews';

  // Users -------------------------------------------------------------------
  static String users() => _users;
  static String user(String uid) => '$_users/$uid';

  // Quizzes -----------------------------------------------------------------
  static String quizzes() => _quizzes;
  static String quiz(String quizId) => '$_quizzes/$quizId';

  // Assignments -------------------------------------------------------------
  /// Per-patient sub-collection for fast list queries on the patient home.
  static String assignmentsForPatient(String patientId) =>
      '$_users/$patientId/$_assignments';

  static String assignment(String patientId, String assignmentId) =>
      '${assignmentsForPatient(patientId)}/$assignmentId';

  /// Top-level mirror of assignments used by the doctor dashboard.
  /// (Denormalized writes happen via Cloud Function trigger in production.)
  static String allAssignments() => _assignments;

  // Responses ---------------------------------------------------------------
  static String responses() => _responses;
  static String response(String responseId) => '$_responses/$responseId';

  // Reviews -----------------------------------------------------------------
  /// Reviews are a sub-collection of the response they belong to so one
  /// security rule covers both.
  static String reviewsForResponse(String responseId) =>
      '${response(responseId)}/$_reviews';

  static String review(String responseId, String reviewId) =>
      '${reviewsForResponse(responseId)}/$reviewId';
}
