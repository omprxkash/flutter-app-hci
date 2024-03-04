import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale. Body sizes are deliberately larger than the Material
/// default to reduce reading effort for elderly or visually impaired
/// patients. Headings use Poppins SemiBold/Bold.
class AppTypography {
  const AppTypography._();

  // Resolved once; google_fonts registers the family under this key.
  static final String fontFamily = GoogleFonts.poppins().fontFamily!;

  static TextTheme lightTextTheme() => _buildTextTheme(
    primary: AppColors.lightTextPrimary,
    secondary: AppColors.lightTextSecondary,
  );

  static TextTheme darkTextTheme() => _buildTextTheme(
    primary: AppColors.darkTextPrimary,
    secondary: AppColors.darkTextSecondary,
  );

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: secondary,
      ),
    );
  }
}
