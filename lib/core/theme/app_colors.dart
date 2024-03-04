import 'package:flutter/material.dart';

/// Color tokens. Picked for AA contrast against background in both light and
/// dark modes — verified at https://webaim.org/resources/contrastchecker/.
class AppColors {
  const AppColors._();

  // Brand --------------------------------------------------------------
  static const Color primary = Color(0xFF2E5BFF);
  static const Color primaryDark = Color(0xFF1A3FBC);
  static const Color primaryLight = Color(0xFFE6EDFF);

  static const Color secondary = Color(0xFF00B8A9);
  static const Color secondaryDark = Color(0xFF00897B);

  // Semantic ----------------------------------------------------------
  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFD93B3B);
  static const Color info = Color(0xFF3FA9F5);

  // Severity bands (clinical scoring) ---------------------------------
  static const Color severityMinimal = Color(0xFF22A06B);
  static const Color severityMild = Color(0xFFC9DB36);
  static const Color severityModerate = Color(0xFFE8A33D);
  static const Color severityModeratelySevere = Color(0xFFE8602E);
  static const Color severitySevere = Color(0xFFD93B3B);

  // Light surface ----------------------------------------------------
  static const Color lightBackground = Color(0xFFF7F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1F36);
  static const Color lightTextSecondary = Color(0xFF52596B);
  static const Color lightDivider = Color(0xFFE3E6EE);

  // Dark surface -----------------------------------------------------
  static const Color darkBackground = Color(0xFF0F1320);
  static const Color darkSurface = Color(0xFF1A1F36);
  static const Color darkTextPrimary = Color(0xFFF1F3F8);
  static const Color darkTextSecondary = Color(0xFFA9AEC0);
  static const Color darkDivider = Color(0xFF2A2F44);
}
