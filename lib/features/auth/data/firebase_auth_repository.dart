import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/app_user.dart';
import '../domain/entities/user_role.dart';
import '../domain/repositories/auth_repository.dart';
import 'user_dto.dart';

/// Firebase-backed implementation of [AuthRepository].
///
/// Notes on the OTP flow:
///   - `sendPhoneOtp` triggers `verifyPhoneNumber` and surfaces the
///     `verificationId` to the caller via the returned String. On Android
///     auto-retrieval the code may complete sign-in before the UI even asks,
///     so the UI must also be ready to react to `currentUserChanges`.
///   - `verifyPhoneOtp` either signs an existing user in or creates a new
///     `users/{uid}` document when `registration` is provided.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required fb.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> currentUserChanges() {
    return _firebaseAuth.userChanges().asyncMap((fb.User? u) async {
      if (u == null) return null;
      return _loadUserDoc(u.uid);
    });
  }

  @override
  Future<AppUser?> currentUser() async {
    final fb.User? u = _firebaseAuth.currentUser;
    if (u == null) return null;
    return _loadUserDoc(u.uid);
  }

  Future<AppUser?> _loadUserDoc(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _firestore.doc(FirestorePaths.user(uid)).get();
    if (!snap.exists) return null;
    return UserDto.fromSnapshot(snap);
  }

  @override
  Future<Result<String, Failure>> sendPhoneOtp(String phone) async {
    final Completer<Result<String, Failure>> completer = Completer<Result<String, Failure>>();
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: AppConstants.otpTimeout,
        verificationCompleted: (fb.PhoneAuthCredential _) {
          // Auto-retrieval path. UI will react via currentUserChanges.
          if (!completer.isCompleted) {
            completer.complete(const Success<String, Failure>('auto-retrieved'));
          }
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete(Err<String, Failure>(_mapAuthError(e)));
          }
        },
        codeSent: (String verificationId, int? _) {
          if (!completer.isCompleted) {
            completer.complete(Success<String, Failure>(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String _) {},
      );
      return completer.future;
    } catch (e, st) {
      appLogger.e('sendPhoneOtp threw', error: e, stackTrace: st);
      return Err<String, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    PatientRegistration? registration,
  }) async {
    try {
      final fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final fb.UserCredential cred = await _firebaseAuth.signInWithCredential(credential);
      final fb.User? user = cred.user;
      if (user == null) {
        return const Err<AppUser, Failure>(AuthFailure('Sign-in succeeded but no user returned.'));
      }

      AppUser? existing = await _loadUserDoc(user.uid);
      if (existing == null) {
        if (registration == null) {
          // Unknown user trying to log in without registration payload.
          await _firebaseAuth.signOut();
          return const Err<AppUser, Failure>(
            NotFoundFailure('No account found. Please register first.'),
          );
        }
        final AppUser fresh = AppUser(
          id: user.uid,
          role: UserRole.patient,
          displayName: registration.displayName,
          phone: user.phoneNumber,
          age: registration.age,
          gender: registration.gender,
          doctorId: registration.doctorId,
          preferredLocale: registration.preferredLocale,
          createdAt: DateTime.now(),
        );
        await _firestore.doc(FirestorePaths.user(user.uid)).set(UserDto.toMap(fresh));
        existing = fresh;
      }
      return Success<AppUser, Failure>(existing);
    } on fb.FirebaseAuthException catch (e) {
      return Err<AppUser, Failure>(_mapAuthError(e));
    } catch (e, st) {
      appLogger.e('verifyPhoneOtp threw', error: e, stackTrace: st);
      return Err<AppUser, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> signInDoctorWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final fb.UserCredential cred =
          await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final fb.User? user = cred.user;
      if (user == null) {
        return const Err<AppUser, Failure>(AuthFailure('Sign-in succeeded but no user returned.'));
      }
      final AppUser? doc = await _loadUserDoc(user.uid);
      if (doc == null) {
        await _firebaseAuth.signOut();
        return const Err<AppUser, Failure>(NotFoundFailure('Doctor profile not found.'));
      }
      if (!doc.isDoctor) {
        await _firebaseAuth.signOut();
        return const Err<AppUser, Failure>(
          PermissionFailure('This account is not a doctor account.'),
        );
      }
      return Success<AppUser, Failure>(doc);
    } on fb.FirebaseAuthException catch (e) {
      return Err<AppUser, Failure>(_mapAuthError(e));
    } catch (e, st) {
      appLogger.e('signInDoctorWithEmail threw', error: e, stackTrace: st);
      return Err<AppUser, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> registerDoctorWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String specialty,
    required String licenseNumber,
  }) async {
    try {
      final fb.UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User? user = cred.user;
      if (user == null) {
        return const Err<AppUser, Failure>(AuthFailure('Register succeeded but no user returned.'));
      }
      final AppUser doctor = AppUser(
        id: user.uid,
        role: UserRole.doctor,
        displayName: displayName,
        email: email,
        specialty: specialty,
        licenseNumber: licenseNumber,
        createdAt: DateTime.now(),
      );
      await _firestore.doc(FirestorePaths.user(user.uid)).set(UserDto.toMap(doctor));
      return Success<AppUser, Failure>(doctor);
    } on fb.FirebaseAuthException catch (e) {
      return Err<AppUser, Failure>(_mapAuthError(e));
    } catch (e, st) {
      appLogger.e('registerDoctorWithEmail threw', error: e, stackTrace: st);
      return Err<AppUser, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> signInAsPatient(String userId) async {
    return const Err<AppUser, Failure>(
      AuthFailure('Direct patient sign-in is not available in production mode.'),
    );
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Success<void, Failure>(null);
    } catch (e) {
      return Err<void, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> updateProfile(AppUser user) async {
    try {
      await _firestore.doc(FirestorePaths.user(user.id)).update(UserDto.toMap(user));
      return Success<AppUser, Failure>(user);
    } catch (e) {
      return Err<AppUser, Failure>(UnknownFailure(e.toString(), cause: e));
    }
  }

  AuthFailure _mapAuthError(fb.FirebaseAuthException e) {
    final String message = switch (e.code) {
      'invalid-verification-code' => 'That code didn\'t match. Try again.',
      'invalid-phone-number' => 'That phone number is not valid.',
      'too-many-requests' => 'Too many attempts. Please wait a moment.',
      'user-not-found' => 'No account with that email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'An account with that email already exists.',
      'weak-password' => 'Password is too weak.',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => e.message ?? 'Authentication failed.',
    };
    return AuthFailure(message, cause: e, code: e.code);
  }
}
