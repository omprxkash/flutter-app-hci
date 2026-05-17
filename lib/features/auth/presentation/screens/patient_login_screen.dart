import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/demo_patients.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class PatientLoginScreen extends ConsumerWidget {
  const PatientLoginScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
  );

  Future<void> _signIn(
      BuildContext context, WidgetRef ref, AppUser patient) async {
    final result =
        await ref.read(authControllerProvider.notifier).signInAsPatient(patient.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        context.goNamed(RouteNames.patientHome);
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select your profile',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap your name to sign in instantly.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Expanded(
                      child: ListView.separated(
                        itemCount: kDemoPatients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final patient = kDemoPatients[index];
                          final initials = patient.displayName
                              .split(' ')
                              .where((w) => w.isNotEmpty)
                              .take(2)
                              .map((w) => w[0].toUpperCase())
                              .join();
                          final gender = patient.gender != null
                              ? patient.gender![0].toUpperCase() +
                                  patient.gender!.substring(1)
                              : '';

                          return Material(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => _signIn(context, ref, patient),
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.25),
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            patient.displayName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Age ${patient.age ?? '—'} · $gender',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
