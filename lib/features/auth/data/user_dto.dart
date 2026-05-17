import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/app_user.dart';
import '../domain/entities/user_role.dart';

/// Mapping between the `AppUser` domain entity and the Firestore wire format.
/// All Firestore-specific quirks (Timestamp <-> DateTime, default fields)
/// stay inside this file.
class UserDto {
  const UserDto._();

  static Map<String, dynamic> toMap(AppUser u) => <String, dynamic>{
        'role': u.role.wireName,
        'displayName': u.displayName,
        'phone': u.phone,
        'email': u.email,
        'age': u.age,
        'gender': u.gender,
        'doctorId': u.doctorId,
        'specialty': u.specialty,
        'licenseNumber': u.licenseNumber,
        'preferredLocale': u.preferredLocale,
        'createdAt': Timestamp.fromDate(u.createdAt),
      };

  static AppUser fromMap(String id, Map<String, dynamic> m) {
    return AppUser(
      id: id,
      role: UserRole.fromWire(m['role'] as String?),
      displayName: (m['displayName'] as String?) ?? '',
      phone: m['phone'] as String?,
      email: m['email'] as String?,
      age: (m['age'] as num?)?.toInt(),
      gender: m['gender'] as String?,
      doctorId: m['doctorId'] as String?,
      specialty: m['specialty'] as String?,
      licenseNumber: m['licenseNumber'] as String?,
      preferredLocale: (m['preferredLocale'] as String?) ?? 'en',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static AppUser fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final Map<String, dynamic>? data = snap.data();
    if (data == null) {
      throw StateError('User document ${snap.id} has no data');
    }
    return fromMap(snap.id, data);
  }
}
