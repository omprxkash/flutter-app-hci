import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(
            expand ? double.infinity : AppConstants.minTapTargetDp,
            AppConstants.minTapTargetDp,
          ),
        ),
        child: child,
      ),
    );
  }
}
