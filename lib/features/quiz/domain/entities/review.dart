import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.responseId,
    required this.doctorId,
    required this.finalScore,
    required this.reviewedAt,
    this.notes,
    this.recommendedFollowUpInDays,
  });

  final String id;
  final String responseId;
  final String doctorId;

  /// May equal `autoScore` or be overridden by the doctor.
  final int finalScore;

  final DateTime reviewedAt;
  final String? notes;
  final int? recommendedFollowUpInDays;

  @override
  List<Object?> get props => <Object?>[
    id,
    responseId,
    doctorId,
    finalScore,
    reviewedAt,
    notes,
    recommendedFollowUpInDays,
  ];
}
