import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A named score band — e.g. PHQ-9 maps 0-4 to "Minimal".
class SeverityBand extends Equatable {
  const SeverityBand({
    required this.label,
    required this.minInclusive,
    required this.maxInclusive,
    required this.color,
    this.guidance,
  });

  final String label;
  final int minInclusive;
  final int maxInclusive;
  final Color color;

  /// Optional clinician-facing guidance shown alongside the band on the
  /// result screen.
  final String? guidance;

  bool contains(int score) => score >= minInclusive && score <= maxInclusive;

  @override
  List<Object?> get props => <Object?>[
    label,
    minInclusive,
    maxInclusive,
    color.toARGB32(),
    guidance,
  ];
}

/// Standard 5-band scale used by PHQ-9. Other instruments reuse subsets.
class StandardSeverityBands {
  const StandardSeverityBands._();

  static const SeverityBand minimal = SeverityBand(
    label: 'Minimal',
    minInclusive: 0,
    maxInclusive: 4,
    color: AppColors.severityMinimal,
    guidance: 'No or minimal symptoms.',
  );

  static const SeverityBand mild = SeverityBand(
    label: 'Mild',
    minInclusive: 5,
    maxInclusive: 9,
    color: AppColors.severityMild,
    guidance: 'Watchful waiting; repeat assessment at follow-up.',
  );

  static const SeverityBand moderate = SeverityBand(
    label: 'Moderate',
    minInclusive: 10,
    maxInclusive: 14,
    color: AppColors.severityModerate,
    guidance: 'Consider treatment plan and counseling.',
  );

  static const SeverityBand moderatelySevere = SeverityBand(
    label: 'Moderately severe',
    minInclusive: 15,
    maxInclusive: 19,
    color: AppColors.severityModeratelySevere,
    guidance: 'Active treatment recommended.',
  );

  static const SeverityBand severe = SeverityBand(
    label: 'Severe',
    minInclusive: 20,
    maxInclusive: 27,
    color: AppColors.severitySevere,
    guidance: 'Immediate clinical attention recommended.',
  );
}
