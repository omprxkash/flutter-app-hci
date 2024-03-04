import '../../../auth/domain/entities/app_user.dart';

abstract class PatientRepository {
  Future<AppUser?> getPatientById(String patientId);
  Future<void> updatePatient(AppUser patient);
}
