import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/constants/demo_patients.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/app_user.dart';
import '../domain/entities/user_role.dart';
import '../domain/repositories/auth_repository.dart';

/// In-memory implementation used when Firebase is unavailable (e.g. the
/// firebase_options.dart stub is still in place). Lets the rest of the app
/// run end-to-end without a backend so screens can be developed and demoed.
///
/// Seeded with one demo doctor (`doctor@demo.local` / `password123`) and
/// accepts any 6-digit OTP for phone numbers.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository() {
    _seedDemoUsers();
  }

  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();
  final Map<String, AppUser> _usersById = <String, AppUser>{};
  final Map<String, String> _doctorPasswords = <String, String>{};
  final Map<String, String> _pendingPhones = <String, String>{}; // verificationId -> phone
  final Uuid _uuid = const Uuid();
  AppUser? _current;

  void _seedDemoUsers() {
    final AppUser demoDoctor = AppUser(
      id: 'doctor-demo',
      role: UserRole.doctor,
      displayName: 'Dr. Demo',
      email: 'doctor@demo.local',
      specialty: 'General Medicine',
      licenseNumber: 'DEMO-001',
      createdAt: DateTime.utc(2025, 3, 1),
    );
    _usersById[demoDoctor.id] = demoDoctor;
    _doctorPasswords[demoDoctor.email!] = 'password123';

    for (final AppUser p in kDemoPatients) {
      _usersById[p.id] = p;
    }
  }

  @override
  Stream<AppUser?> currentUserChanges() async* {
    yield _current;
    yield* _userController.stream;
  }

  @override
  Future<AppUser?> currentUser() async => _current;

  @override
  Future<Result<String, Failure>> sendPhoneOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String id = _uuid.v4();
    _pendingPhones[id] = phone;
    return Success<String, Failure>(id);
  }

  @override
  Future<Result<AppUser, Failure>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    PatientRegistration? registration,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      return const Err<AppUser, Failure>(AuthFailure('OTP must be 6 digits.'));
    }
    final String? phone = _pendingPhones.remove(verificationId);
    if (phone == null) {
      return const Err<AppUser, Failure>(AuthFailure('Verification session expired.'));
    }

    AppUser? existing = _usersById.values
        .where((AppUser u) => u.isPatient && u.phone == phone)
        .firstOrNull;

    if (existing == null) {
      if (registration == null) {
        return const Err<AppUser, Failure>(
          NotFoundFailure('No account found. Please register first.'),
        );
      }
      existing = AppUser(
        id: _uuid.v4(),
        role: UserRole.patient,
        displayName: registration.displayName,
        phone: phone,
        age: registration.age,
        gender: registration.gender,
        doctorId: registration.doctorId ?? 'doctor-demo',
        preferredLocale: registration.preferredLocale,
        createdAt: DateTime.now(),
      );
      _usersById[existing.id] = existing;
    }
    _setCurrent(existing);
    return Success<AppUser, Failure>(existing);
  }

  @override
  Future<Result<AppUser, Failure>> signInDoctorWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String? expected = _doctorPasswords[email];
    if (expected == null) {
      return const Err<AppUser, Failure>(NotFoundFailure('No account with that email.'));
    }
    if (expected != password) {
      return const Err<AppUser, Failure>(AuthFailure('Incorrect password.'));
    }
    final AppUser doctor = _usersById.values
        .firstWhere((AppUser u) => u.isDoctor && u.email == email);
    _setCurrent(doctor);
    return Success<AppUser, Failure>(doctor);
  }

  @override
  Future<Result<AppUser, Failure>> registerDoctorWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String specialty,
    required String licenseNumber,
  }) async {
    if (_doctorPasswords.containsKey(email)) {
      return const Err<AppUser, Failure>(AuthFailure('An account with that email already exists.'));
    }
    final AppUser doctor = AppUser(
      id: _uuid.v4(),
      role: UserRole.doctor,
      displayName: displayName,
      email: email,
      specialty: specialty,
      licenseNumber: licenseNumber,
      createdAt: DateTime.now(),
    );
    _usersById[doctor.id] = doctor;
    _doctorPasswords[email] = password;
    _setCurrent(doctor);
    return Success<AppUser, Failure>(doctor);
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    _setCurrent(null);
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<AppUser, Failure>> updateProfile(AppUser user) async {
    _usersById[user.id] = user;
    if (_current?.id == user.id) _setCurrent(user);
    return Success<AppUser, Failure>(user);
  }

  @override
  Future<Result<AppUser, Failure>> signInAsPatient(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final AppUser? user = _usersById[userId];
    if (user == null || !user.isPatient) {
      return const Err<AppUser, Failure>(NotFoundFailure('Demo patient not found.'));
    }
    _setCurrent(user);
    return Success<AppUser, Failure>(user);
  }

  void _setCurrent(AppUser? user) {
    _current = user;
    _userController.add(user);
  }

  void dispose() => _userController.close();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
