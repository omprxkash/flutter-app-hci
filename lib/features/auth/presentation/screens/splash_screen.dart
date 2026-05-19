import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

/// Decides where to send the user based on the current auth state:
///   - unauthenticated -> role selection
///   - authenticated patient -> patient home
///   - authenticated doctor -> doctor dashboard
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Object?>>(authStateChangesProvider, (
      Object? _,
      AsyncValue<Object?> next,
    ) {
      next.whenData((Object? user) {
        if (!context.mounted) return;
        if (user == null) {
          context.goNamed(RouteNames.roleSelection);
          return;
        }
        // Pattern-match by user's role via a duck-typed check.
        final dynamic dynUser = user;
        final bool isDoctor = (dynUser.isDoctor as bool?) ?? false;
        context.goNamed(
          isDoctor ? RouteNames.doctorDashboard : RouteNames.patientHome,
        );
      });
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.medical_services_rounded,
              size: 96,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'MedQuiz',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clinical assessments, made accessible.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
