import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../entities/user_role.dart';

/// Auth repository contract. The data layer provides a Firebase-backed and
/// an in-memory implementation; the domain and presentation layers depend
/// only on this interface.
abstract class AuthRepository {
  /// Currently signed-in user, or `null` if signed out.
  Stream<AppUser?> currentUserChanges();

  /// Resolve the user once, synchronously if cached.
  Future<AppUser?> currentUser();

  // -------- Patient (phone OTP) ----------------------------------------
  /// Send an OTP to `phone`. Returns the verificationId used to complete
  /// sign-in on the next step.
  Future<Result<String, Failure>> sendPhoneOtp(String phone);

  /// Verify the SMS code. If `registration` is non-null, a new patient
  /// document is created on the first successful verification.
  Future<Result<AppUser, Failure>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    PatientRegistration? registration,
  });

  /// Demo-mode only. Signs in a pre-seeded patient instantly with no phone/OTP.
  /// Returns [AuthFailure] in production.
  Future<Result<AppUser, Failure>> signInAsPatient(String userId);

  // -------- Doctor (email/password) ------------------------------------
  Future<Result<AppUser, Failure>> signInDoctorWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser, Failure>> registerDoctorWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String specialty,
    required String licenseNumber,
  });

  // -------- Common ------------------------------------------------------
  Future<Result<void, Failure>> signOut();

  /// Update the cached `AppUser` profile. The data layer persists it.
  Future<Result<AppUser, Failure>> updateProfile(AppUser user);
}

/// Payload used when an OTP verification is the first time we've seen a
/// patient — we need their basic demographics to create the user document.
class PatientRegistration {
  const PatientRegistration({
    required this.displayName,
    required this.age,
    required this.gender,
    this.doctorId,
    this.preferredLocale = 'en',
  });

  final String displayName;
  final int age;
  final String gender;
  final String? doctorId;
  final String preferredLocale;
}

extension UserRoleX on AppUser {
  bool hasRole(UserRole r) => role == r;
}
