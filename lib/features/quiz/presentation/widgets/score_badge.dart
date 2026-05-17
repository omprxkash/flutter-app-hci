import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/severity_band.dart';

/// Compact pill-style badge for a score + severity label. Used in history
/// lists, the doctor patient detail screen, and the result screen.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    required this.score,
    this.maxScore,
    this.band,
    this.label,
    super.key,
  });

  final int score;
  final int? maxScore;
  final SeverityBand? band;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color color = band?.color ?? AppColors.info;
    final String text = label ?? band?.label ?? 'Score';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            maxScore == null ? '$score' : '$score / $maxScore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
