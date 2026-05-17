import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Domain user. Lives independently of Firebase types — the data layer maps
/// `firebase_auth.User` + the Firestore `users/{uid}` doc into this.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.role,
    required this.displayName,
    required this.createdAt,
    this.phone,
    this.email,
    this.age,
    this.gender,
    this.doctorId,
    this.specialty,
    this.licenseNumber,
    this.preferredLocale = 'en',
  });

  final String id;
  final UserRole role;
  final String displayName;
  final DateTime createdAt;

  // Patient-only fields
  final String? phone;
  final int? age;
  final String? gender;

  /// `doctorId` is the uid of the doctor this patient is assigned to.
  /// Optional — patients may exist without an assigned doctor.
  final String? doctorId;

  // Doctor-only fields
  final String? email;
  final String? specialty;
  final String? licenseNumber;

  final String preferredLocale;

  bool get isPatient => role == UserRole.patient;
  bool get isDoctor => role == UserRole.doctor;

  AppUser copyWith({
    String? displayName,
    int? age,
    String? gender,
    String? doctorId,
    String? specialty,
    String? licenseNumber,
    String? preferredLocale,
  }) {
    return AppUser(
      id: id,
      role: role,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      phone: phone,
      email: email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      doctorId: doctorId ?? this.doctorId,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      preferredLocale: preferredLocale ?? this.preferredLocale,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        role,
        displayName,
        createdAt,
        phone,
        email,
        age,
        gender,
        doctorId,
        specialty,
        licenseNumber,
        preferredLocale,
      ];
}
