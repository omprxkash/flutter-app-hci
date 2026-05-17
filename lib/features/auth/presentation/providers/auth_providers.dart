import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../main.dart' show firebaseAvailableProvider;
import '../../data/firebase_auth_repository.dart';
import '../../data/in_memory_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Selects the right `AuthRepository` implementation based on whether
/// Firebase initialized successfully at app start.
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final bool firebaseAvailable = ref.watch(firebaseAvailableProvider);
  if (firebaseAvailable) {
    return FirebaseAuthRepository(
      firebaseAuth: fb.FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  }
  final InMemoryAuthRepository repo = InMemoryAuthRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Streams the currently signed-in user (null if signed out).
final StreamProvider<AppUser?> authStateChangesProvider = StreamProvider<AppUser?>((Ref ref) {
  final AuthRepository repo = ref.watch(authRepositoryProvider);
  return repo.currentUserChanges();
});

/// Imperative auth actions. Screens read `authControllerProvider.notifier`
/// to invoke flows and watch `authControllerProvider` for loading/error.
class AuthController extends Notifier<AsyncValue<void>> {
  late final AuthRepository _repo;

  @override
  AsyncValue<void> build() {
    _repo = ref.watch(authRepositoryProvider);
    return const AsyncValue<void>.data(null);
  }

  Future<Result<String, Failure>> sendOtp(String phone) async {
    state = const AsyncValue<void>.loading();
    final Result<String, Failure> r = await _repo.sendPhoneOtp(phone);
    state = const AsyncValue<void>.data(null);
    return r;
  }

  Future<Result<AppUser, Failure>> verifyOtp({
    required String verificationId,
    required String smsCode,
    PatientRegistration? registration,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<AppUser, Failure> r = await _repo.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      registration: registration,
    );
    state = const AsyncValue<void>.data(null);
    return r;
  }

  Future<Result<AppUser, Failure>> doctorSignIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<AppUser, Failure> r =
        await _repo.signInDoctorWithEmail(email: email, password: password);
    state = const AsyncValue<void>.data(null);
    return r;
  }

  Future<Result<AppUser, Failure>> doctorRegister({
    required String email,
    required String password,
    required String displayName,
    required String specialty,
    required String licenseNumber,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<AppUser, Failure> r = await _repo.registerDoctorWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      specialty: specialty,
      licenseNumber: licenseNumber,
    );
    state = const AsyncValue<void>.data(null);
    return r;
  }

  Future<Result<AppUser, Failure>> signInAsPatient(String userId) async {
    state = const AsyncValue<void>.loading();
    final Result<AppUser, Failure> r = await _repo.signInAsPatient(userId);
    state = const AsyncValue<void>.data(null);
    return r;
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final NotifierProvider<AuthController, AsyncValue<void>> authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
