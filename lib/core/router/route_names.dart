/// Named route constants. Always reference these from screens via
/// `context.goNamed(RouteNames.patientHome)` — never hard-code strings at
/// call sites. Path templates live alongside in `app_router.dart`.
class RouteNames {
  const RouteNames._();

  // Onboarding ----------------------------------------------------------
  static const String splash = 'splash';
  static const String roleSelection = 'role_selection';

  // Patient auth -------------------------------------------------------
  static const String patientLogin = 'patient_login';
  static const String patientRegister = 'patient_register';
  static const String otpVerification = 'otp_verification';

  // Doctor auth --------------------------------------------------------
  static const String doctorLogin = 'doctor_login';

  // Patient -----------------------------------------------------------
  static const String patientHome = 'patient_home';
  static const String patientHistory = 'patient_history';
  static const String patientProfile = 'patient_profile';
  static const String takeQuiz = 'take_quiz';
  static const String quizResult = 'quiz_result';

  // Doctor ------------------------------------------------------------
  static const String doctorDashboard = 'doctor_dashboard';
  static const String doctorProfile = 'doctor_profile';
  static const String patientDetail = 'patient_detail';
  static const String reviewResponse = 'review_response';
  static const String quizBuilder = 'quiz_builder';
  static const String quizLibrary = 'quiz_library';
  static const String assignQuiz = 'assign_quiz';
}

class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  static const String roleSelection = '/role';

  static const String patientLogin = '/patient/login';
  static const String patientRegister = '/patient/register';
  static const String otpVerification = '/patient/otp';

  static const String doctorLogin = '/doctor/login';

  static const String patientHome = '/patient/home';
  static const String patientHistory = '/patient/history';
  static const String patientProfile = '/patient/profile';
  static const String takeQuiz = '/patient/quiz/:assignmentId';
  static const String quizResult = '/patient/result/:responseId';

  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorProfile = '/doctor/profile';
  static const String patientDetail = '/doctor/patient/:patientId';
  static const String reviewResponse = '/doctor/review/:responseId';
  static const String quizBuilder = '/doctor/quizzes/builder';
  static const String quizLibrary = '/doctor/quizzes';
  static const String assignQuiz = '/doctor/assign';
}
