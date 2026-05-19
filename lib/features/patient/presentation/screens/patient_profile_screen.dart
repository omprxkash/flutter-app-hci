import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

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
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              _InfoTile(
                icon: Icons.phone,
                label: 'Phone',
                value: user.phone ?? '—',
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: user.age?.toString() ?? '—',
              ),
              _InfoTile(
                icon: Icons.wc,
                label: 'Gender',
                value: user.gender ?? '—',
              ),
              if (user.doctorId != null)
                _InfoTile(
                  icon: Icons.medical_services_outlined,
                  label: 'Doctor',
                  value: user.doctorId!,
                )
              else
                _ConnectDoctorTile(user: user),
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
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ConnectDoctorTile extends ConsumerWidget {
  const _ConnectDoctorTile({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showConnectSheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2E5BFF).withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF0F3FF),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.link_rounded, color: Color(0xFF2E5BFF)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Connect to a Doctor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E5BFF),
                      ),
                    ),
                    Text(
                      'Enter the invite code your doctor gave you',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF52596B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2E5BFF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConnectSheet(BuildContext context, WidgetRef ref) async {
    final TextEditingController codeCtrl = TextEditingController();
    bool loading = false;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Enter invite code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask your doctor for their 6-character invite code.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF52596B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: 'e.g. DEMO01 or doctor-demo',
                      errorText: error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                    ),
                    onChanged: (_) {
                      if (error != null) setState(() => error = null);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading
                          ? null
                          : () async {
                              final String code = codeCtrl.text.trim();
                              if (code.isEmpty) {
                                setState(
                                  () => error = 'Please enter the invite code.',
                                );
                                return;
                              }
                              setState(() {
                                loading = true;
                                error = null;
                              });

                              final result = await ref
                                  .read(authControllerProvider.notifier)
                                  .updateProfile(user.copyWith(doctorId: code));

                              if (!ctx.mounted) return;

                              if (result) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Connected to your doctor.'),
                                  ),
                                );
                              } else {
                                setState(() {
                                  loading = false;
                                  error =
                                      'Code not recognised. Check with your doctor.';
                                });
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    codeCtrl.dispose();
  }
}
