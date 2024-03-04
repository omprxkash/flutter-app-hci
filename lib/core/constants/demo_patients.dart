import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/domain/entities/user_role.dart';

/// Seeded demo patients shared by the auth repo and doctor providers.
/// Fixed [DateTime.utc] values keep [AppUser] equality stable across calls.
final List<AppUser> kDemoPatients = <AppUser>[
  AppUser(
    id: 'patient-demo',
    role: UserRole.patient,
    displayName: 'Anjali Demo',
    phone: '+910000000000',
    age: 34,
    gender: 'female',
    doctorId: 'doctor-demo',
    createdAt: DateTime.utc(2025, 4, 2),
  ),
  AppUser(
    id: 'patient-demo-2',
    role: UserRole.patient,
    displayName: 'Rahul Patel',
    phone: '+910000000001',
    age: 52,
    gender: 'male',
    doctorId: 'doctor-demo',
    createdAt: DateTime.utc(2025, 3, 17),
  ),
  AppUser(
    id: 'patient-demo-3',
    role: UserRole.patient,
    displayName: 'Maria Lopez',
    phone: '+910000000002',
    age: 41,
    gender: 'female',
    doctorId: 'doctor-demo',
    createdAt: DateTime.utc(2025, 5, 13),
  ),
];
