import '../../../../core/constants/demo_patients.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../domain/repositories/patient_repository.dart';

class InMemoryPatientRepository implements PatientRepository {
  final List<AppUser> _patients = List<AppUser>.from(kDemoPatients);

  @override
  Future<AppUser?> getPatientById(String patientId) async {
    for (final AppUser u in _patients) {
      if (u.id == patientId) return u;
    }
    return null;
  }

  @override
  Future<void> updatePatient(AppUser patient) async {
    final int idx = _patients.indexWhere((AppUser u) => u.id == patient.id);
    if (idx != -1) _patients[idx] = patient;
  }
}
