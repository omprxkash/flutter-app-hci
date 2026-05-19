import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.isRegistration,
    this.registration,
    super.key,
  });

  final String phoneNumber;
  final String verificationId;
  final bool isRegistration;
  final PatientRegistration? registration;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = 0;
  bool _isSubmitting = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _secondsRemaining = AppConstants.otpTimeout.inSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_secondsRemaining <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final String? validation = Validators.otp(_otpController.text);
    if (validation != null) {
      setState(() => _serverError = validation);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final Result<AppUser, Failure> r = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(
          verificationId: widget.verificationId,
          smsCode: _otpController.text.trim(),
          registration: widget.registration,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (r) {
      case Success<AppUser, Failure>(:final AppUser data):
        context.goNamed(
          data.isDoctor ? RouteNames.doctorDashboard : RouteNames.patientHome,
        );
      case Err<AppUser, Failure>(:final Failure failure):
        setState(() => _serverError = failure.message);
    }
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).sendOtp(widget.phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Verify code',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Enter the 6-digit code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                fontWeight: FontWeight.w600,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••••',
              ),
              onSubmitted: (_) => _verify(),
            ),
            if (_serverError != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _serverError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Verify',
              onPressed: _verify,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
            Center(
              child: _secondsRemaining > 0
                  ? Text('Resend code in ${_secondsRemaining}s')
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend code'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
