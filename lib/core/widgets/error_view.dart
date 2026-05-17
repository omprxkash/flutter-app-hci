import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

/// Uniform error presentation. Pass a `Failure` for typed messaging or a raw
/// `message` for ad-hoc errors. Includes a "Try again" affordance.
class ErrorView extends StatelessWidget {
  const ErrorView({
    this.failure,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    super.key,
  }) : assert(failure != null || message != null, 'Provide a failure or a message');

  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final String text = message ?? failure?.message ?? 'Something went wrong.';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Try again',
                onPressed: onRetry,
                expand: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
