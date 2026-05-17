import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/demo_patients.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Lists the patients assigned to a given doctor.
///
/// In v1 (in-memory mode) this returns a seeded list. In production this
/// would issue a Firestore query for `users where role == 'patient' and
/// doctorId == :doctorId`.
final patientsForDoctorProvider =
    FutureProvider.family<List<AppUser>, String>((Ref ref, String doctorId) async {
  return kDemoPatients.where((AppUser p) => p.doctorId == doctorId).toList();
});

/// Quick lookup by id for the patient detail / review screens.
final patientByIdProvider =
    FutureProvider.family<AppUser?, String>((Ref ref, String patientId) async {
  // Walk the seeded list. Replace with a Firestore doc read in production.
  final List<AppUser> all = await ref.watch(patientsForDoctorProvider('doctor-demo').future);
  for (final AppUser u in all) {
    if (u.id == patientId) return u;
  }
  return null;
});
