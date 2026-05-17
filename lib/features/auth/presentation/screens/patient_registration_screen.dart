import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  ConsumerState<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends ConsumerState<PatientRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _age = TextEditingController();
  String _gender = 'female';
  bool _isSubmitting = false;
  String? _serverError;

  static const List<String> _genders = <String>['female', 'male', 'other', 'prefer not to say'];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final Result<String, Failure> r =
        await ref.read(authControllerProvider.notifier).sendOtp(_phone.text.trim());

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (r) {
      case Success<String, Failure>(:final String data):
        context.pushNamed(
          RouteNames.otpVerification,
          extra: <String, dynamic>{
            'phone': _phone.text.trim(),
            'verificationId': data,
            'isRegistration': true,
            'displayName': _name.text.trim(),
            'age': int.parse(_age.text.trim()),
            'gender': _gender,
          },
        );
      case Err<String, Failure>(:final Failure failure):
        setState(() => _serverError = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create account',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor needs this to assign the right assessments.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (String? v) =>
                    Validators.required(v, label: 'Name') ?? Validators.minLength(v, 2, label: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: Validators.age,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.wc_rounded),
                      ),
                      items: _genders
                          .map((String g) => DropdownMenuItem<String>(
                                value: g,
                                child: Text(g[0].toUpperCase() + g.substring(1)),
                              ))
                          .toList(),
                      onChanged: (String? v) {
                        if (v != null) setState(() => _gender = v);
                      },
                    ),
                  ),
                ],
              ),
              if (_serverError != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  _serverError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Continue',
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
