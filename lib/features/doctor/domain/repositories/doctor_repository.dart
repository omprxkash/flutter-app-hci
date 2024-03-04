import '../../../auth/domain/entities/app_user.dart';

abstract class DoctorRepository {
  Future<List<AppUser>> getPatientsForDoctor(String doctorId);
  Future<AppUser?> getPatientById(String patientId);
}
