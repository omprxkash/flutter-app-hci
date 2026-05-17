import 'package:equatable/equatable.dart';

enum AssignmentStatus {
  pending, // assigned, patient hasn't started
  inProgress, // patient saved a draft
  completed, // response submitted
  reviewed, // doctor has reviewed
  expired;

  String get wireName => name;

  static AssignmentStatus fromWire(String? value) {
    return AssignmentStatus.values.firstWhere(
      (AssignmentStatus s) => s.wireName == value,
      orElse: () => AssignmentStatus.pending,
    );
  }
}

class Assignment extends Equatable {
  const Assignment({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.assignedAt,
    this.dueAt,
    this.completedAt,
    this.responseId,
    this.notes,
  });

  final String id;
  final String quizId;

  /// Denormalized so the patient list doesn't need a join.
  final String quizTitle;

  final String patientId;
  final String doctorId;
  final AssignmentStatus status;
  final DateTime assignedAt;
  final DateTime? dueAt;
  final DateTime? completedAt;

  /// Set once the patient submits.
  final String? responseId;

  /// Optional doctor-provided context shown to the patient before they start.
  final String? notes;

  bool get isOverdue =>
      status != AssignmentStatus.completed &&
      status != AssignmentStatus.reviewed &&
      dueAt != null &&
      DateTime.now().isAfter(dueAt!);

  Assignment copyWith({
    AssignmentStatus? status,
    DateTime? completedAt,
    String? responseId,
  }) {
    return Assignment(
      id: id,
      quizId: quizId,
      quizTitle: quizTitle,
      patientId: patientId,
      doctorId: doctorId,
      status: status ?? this.status,
      assignedAt: assignedAt,
      dueAt: dueAt,
      completedAt: completedAt ?? this.completedAt,
      responseId: responseId ?? this.responseId,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        quizId,
        quizTitle,
        patientId,
        doctorId,
        status,
        assignedAt,
        dueAt,
        completedAt,
        responseId,
        notes,
      ];
}
