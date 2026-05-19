import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/doctor_providers.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> async = ref.watch(authStateChangesProvider);

    return AppScaffold(
      title: 'Profile',
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (Object e, _) => Center(child: Text(e.toString())),
        data: (AppUser? user) {
          if (user == null) {
            return const Center(child: Text('Not signed in.'));
          }
          final AsyncValue<List<AppUser>> patients = ref.watch(
            patientsForDoctorProvider(user.id),
          );
          final int patientCount = patients.value?.length ?? 0;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: <Widget>[
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Dr. ${user.displayName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (user.specialty != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      user.specialty!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email ?? '—',
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'License',
                value: user.licenseNumber ?? '—',
              ),
              _InfoTile(
                icon: Icons.people_outline_rounded,
                label: 'Patients',
                value: patientCount.toString(),
              ),
              _InfoTile(
                icon: Icons.language,
                label: 'Preferred language',
                value: user.preferredLocale,
              ),
              const SizedBox(height: 32),
              SecondaryButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted)
                    context.goNamed(RouteNames.roleSelection);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
