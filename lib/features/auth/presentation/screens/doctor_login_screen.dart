import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class DoctorLoginScreen extends ConsumerStatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  ConsumerState<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends ConsumerState<DoctorLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;
  String? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final Result<AppUser, Failure> r = await ref
        .read(authControllerProvider.notifier)
        .doctorSignIn(email: _email.text.trim(), password: _password.text);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (r) {
      case Success<AppUser, Failure>():
        context.goNamed(RouteNames.doctorDashboard);
      case Err<AppUser, Failure>(:final Failure failure):
        setState(() => _serverError = failure.message);
    }
  }

  InputDecoration _inputDecor({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.lightTextSecondary),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0A0A0A),
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEBFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: Color(0xFF6C56FC),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Welcome back,\nDoctor',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A0A0A),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to your clinician account.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const <String>[AutofillHints.email],
                            decoration: _inputDecor(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            decoration:
                                _inputDecor(
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.lightTextSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            validator: Validators.password,
                          ),
                          if (_serverError != null) ...<Widget>[
                            const SizedBox(height: 12),
                            Text(
                              _serverError!,
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          FilledButton(
                            onPressed: _isSubmitting ? null : _signIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF6C56FC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Demo: doctor@demo.local / password123',
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
