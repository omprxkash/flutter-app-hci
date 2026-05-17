/// Two roles supported in v1. Stored on the user document under `role`.
enum UserRole {
  patient,
  doctor;

  String get wireName => name;

  static UserRole fromWire(String? value) {
    switch (value) {
      case 'patient':
        return UserRole.patient;
      case 'doctor':
        return UserRole.doctor;
      default:
        throw ArgumentError('Unknown user role: $value');
    }
  }
}
