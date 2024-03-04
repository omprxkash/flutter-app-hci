import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/doctor_login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/patient_login_screen.dart';
import '../../features/auth/presentation/screens/patient_registration_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/doctor/presentation/screens/assign_quiz_screen.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/doctor_profile_screen.dart';
import '../../features/doctor/presentation/screens/patient_detail_screen.dart';
import '../../features/doctor/presentation/screens/quiz_builder_screen.dart';
import '../../features/doctor/presentation/screens/quiz_library_screen.dart';
import '../../features/doctor/presentation/screens/review_response_screen.dart';
import '../../features/patient/presentation/screens/patient_history_screen.dart';
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/patient/presentation/screens/self_service_quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/take_quiz_screen.dart';
import '../widgets/main_shell.dart';
import 'route_names.dart';

/// Wraps a `GoRouter` so it can be exposed via a Riverpod provider without
/// leaking go_router types everywhere.
class GoRouterConfig {
  const GoRouterConfig(this.config);
  final GoRouter config;
}

const List<ShellTab> _patientTabs = <ShellTab>[
  ShellTab(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  ShellTab(
    icon: Icons.history_outlined,
    selectedIcon: Icons.history_rounded,
    label: 'History',
  ),
  ShellTab(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

const List<ShellTab> _doctorTabs = <ShellTab>[
  ShellTab(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  ShellTab(
    icon: Icons.library_books_outlined,
    selectedIcon: Icons.library_books_rounded,
    label: 'Library',
  ),
  ShellTab(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

final Provider<GoRouterConfig> appRouterProvider = Provider<GoRouterConfig>((
  Ref ref,
) {
  final ValueNotifier<int> refreshListener = ValueNotifier<int>(0);
  ref.listen(authStateChangesProvider, (Object? _, Object? __) {
    refreshListener.value++;
  });

  final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: refreshListener,
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.roleSelection,
        name: RouteNames.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),

      // Patient auth -----------------------------------------------------
      GoRoute(
        path: RoutePaths.patientLogin,
        name: RouteNames.patientLogin,
        builder: (_, __) => const PatientLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.patientRegister,
        name: RouteNames.patientRegister,
        builder: (_, __) => const PatientRegistrationScreen(),
      ),
      GoRoute(
        path: RoutePaths.otpVerification,
        name: RouteNames.otpVerification,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> extra =
              (state.extra as Map<String, dynamic>?) ??
              const <String, dynamic>{};
          return OtpVerificationScreen(
            phoneNumber: extra['phone'] as String? ?? '',
            verificationId: extra['verificationId'] as String? ?? '',
            isRegistration: extra['isRegistration'] as bool? ?? false,
          );
        },
      ),

      // Doctor auth ------------------------------------------------------
      GoRoute(
        path: RoutePaths.doctorLogin,
        name: RouteNames.doctorLogin,
        builder: (_, __) => const DoctorLoginScreen(),
      ),

      // Patient shell (Home / History / Profile) ------------------------
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MainShell(
                navigationShell: navigationShell,
                tabs: _patientTabs,
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.patientHome,
                name: RouteNames.patientHome,
                builder: (_, __) => const PatientHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.patientHistory,
                name: RouteNames.patientHistory,
                builder: (_, __) => const PatientHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.patientProfile,
                name: RouteNames.patientProfile,
                builder: (_, __) => const PatientProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Patient full-screen flows (no shell) ----------------------------
      GoRoute(
        path: RoutePaths.selfCheck,
        name: RouteNames.selfCheck,
        builder: (_, __) => const SelfServiceQuizScreen(),
      ),
      GoRoute(
        path: RoutePaths.takeQuiz,
        name: RouteNames.takeQuiz,
        builder: (BuildContext context, GoRouterState state) {
          final String assignmentId =
              state.pathParameters['assignmentId'] ?? '';
          return TakeQuizScreen(assignmentId: assignmentId);
        },
      ),
      GoRoute(
        path: RoutePaths.quizResult,
        name: RouteNames.quizResult,
        builder: (BuildContext context, GoRouterState state) {
          final String responseId = state.pathParameters['responseId'] ?? '';
          return QuizResultScreen(responseId: responseId);
        },
      ),

      // Doctor shell (Dashboard / Library / Profile) --------------------
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MainShell(
                navigationShell: navigationShell,
                tabs: _doctorTabs,
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.doctorDashboard,
                name: RouteNames.doctorDashboard,
                builder: (_, __) => const DoctorDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.quizLibrary,
                name: RouteNames.quizLibrary,
                builder: (_, __) => const QuizLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.doctorProfile,
                name: RouteNames.doctorProfile,
                builder: (_, __) => const DoctorProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Doctor full-screen flows (no shell) -----------------------------
      GoRoute(
        path: RoutePaths.patientDetail,
        name: RouteNames.patientDetail,
        builder: (BuildContext context, GoRouterState state) {
          final String patientId = state.pathParameters['patientId'] ?? '';
          return PatientDetailScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: RoutePaths.reviewResponse,
        name: RouteNames.reviewResponse,
        builder: (BuildContext context, GoRouterState state) {
          final String responseId = state.pathParameters['responseId'] ?? '';
          return ReviewResponseScreen(responseId: responseId);
        },
      ),
      GoRoute(
        path: RoutePaths.quizBuilder,
        name: RouteNames.quizBuilder,
        builder: (BuildContext context, GoRouterState state) {
          final String? quizId = state.uri.queryParameters['quizId'];
          return QuizBuilderScreen(existingQuizId: quizId);
        },
      ),
      GoRoute(
        path: RoutePaths.assignQuiz,
        name: RouteNames.assignQuiz,
        builder: (_, __) => const AssignQuizScreen(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(
          child: Text(
            'No route for ${state.uri}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    },
  );

  ref.onDispose(() {
    refreshListener.dispose();
    router.dispose();
  });

  return GoRouterConfig(router);
});
