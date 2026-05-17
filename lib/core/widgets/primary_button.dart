import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Primary action button. Full-width by default, large tap target, shows
/// a spinner when `isLoading` is true. Wraps `FilledButton` so theming
/// flows through `filledButtonTheme`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              );

    final FilledButton button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size(
          expand ? double.infinity : AppConstants.minTapTargetDp,
          AppConstants.minTapTargetDp,
        ),
      ),
      child: child,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: button,
    );
  }
}
