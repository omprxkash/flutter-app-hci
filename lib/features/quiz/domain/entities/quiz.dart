import 'package:equatable/equatable.dart';

import 'question.dart';
import 'severity_band.dart';

class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdBy,
    required this.createdAt,
    this.severityBands = const <SeverityBand>[],
    this.reference,
    this.isPreset = false,
    this.estimatedMinutes,
  });

  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final String createdBy;
  final DateTime createdAt;

  /// If non-empty, the auto-score will be classified into one of these bands.
  /// Custom quizzes may have an empty band list and rely on doctor judgement.
  final List<SeverityBand> severityBands;

  /// Bibliographic reference for preset instruments (e.g. PMID).
  final String? reference;

  /// True for the built-in PHQ-9 / GAD-7 / MMSE etc. These cannot be edited
  /// by doctors; only assigned.
  final bool isPreset;

  /// Self-reported estimate shown to the patient on the assignment card.
  final int? estimatedMinutes;

  int get maxPossibleScore {
    int total = 0;
    for (final Question q in questions) {
      if (!q.contributesToScore || q.options.isEmpty) continue;
      final int maxOption = q.options
          .map((opt) => opt.score)
          .reduce((int a, int b) => a > b ? a : b);
      total += (maxOption * q.weight).round();
    }
    return total;
  }

  SeverityBand? bandFor(int score) {
    for (final SeverityBand b in severityBands) {
      if (b.contains(score)) return b;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        questions,
        createdBy,
        createdAt,
        severityBands,
        reference,
        isPreset,
        estimatedMinutes,
      ];
}
