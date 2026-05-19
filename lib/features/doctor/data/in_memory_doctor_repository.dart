import '../../../../core/constants/demo_patients.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../domain/repositories/doctor_repository.dart';

class InMemoryDoctorRepository implements DoctorRepository {
  @override
  Future<List<AppUser>> getPatientsForDoctor(String doctorId) async =>
      kDemoPatients.where((AppUser p) => p.doctorId == doctorId).toList();

  @override
  Future<AppUser?> getPatientById(String patientId) async {
    for (final AppUser u in kDemoPatients) {
      if (u.id == patientId) return u;
    }
    return null;
  }
}
