import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/assignment.dart';
import '../../../quiz/domain/entities/quiz.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../providers/doctor_providers.dart';

class AssignQuizScreen extends ConsumerStatefulWidget {
  const AssignQuizScreen({super.key});

  @override
  ConsumerState<AssignQuizScreen> createState() => _AssignQuizScreenState();
}

class _AssignQuizScreenState extends ConsumerState<AssignQuizScreen> {
  String? _selectedPatientId;
  String? _selectedQuizId;
  DateTime? _dueAt;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save({required List<AppUser> patients, required List<Quiz> quizzes}) async {
    if (_selectedPatientId == null || _selectedQuizId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a patient and a quiz.')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final dynamic doctor = ref.read(authStateChangesProvider).value;
    final String doctorId = (doctor?.id as String?) ?? '';
    final Quiz q = quizzes.firstWhere((Quiz x) => x.id == _selectedQuizId);

    final Assignment a = Assignment(
      id: '',
      quizId: q.id,
      quizTitle: q.title,
      patientId: _selectedPatientId!,
      doctorId: doctorId,
      status: AssignmentStatus.pending,
      assignedAt: DateTime.now(),
      dueAt: _dueAt,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final Result<Assignment, Failure> r =
        await ref.read(quizRepositoryProvider).createAssignment(a);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (r) {
      case Success<Assignment, Failure>():
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz assigned.')));
        if (context.canPop()) context.pop();
      case Err<Assignment, Failure>(:final Failure failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic doctor = ref.watch(authStateChangesProvider).value;
    final String? doctorId = doctor?.id as String?;
    if (doctorId == null) return const AppScaffold(body: LoadingIndicator());

    final AsyncValue<List<AppUser>> patientsAsync = ref.watch(patientsForDoctorProvider(doctorId));
    final AsyncValue<List<Quiz>> quizzesAsync = ref.watch(quizzesForDoctorProvider(doctorId));

    return AppScaffold(
      title: 'Assign quiz',
      maxContentWidth: 700,
      body: patientsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (Object e, _) => Center(child: Text(e.toString())),
        data: (List<AppUser> patients) => quizzesAsync.when(
          loading: () => const LoadingIndicator(),
          error: (Object e, _) => Center(child: Text(e.toString())),
          data: (List<Quiz> quizzes) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedPatientId,
                decoration: const InputDecoration(
                  labelText: 'Patient',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: patients
                    .map((AppUser p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text('${p.displayName} (${p.age ?? "â€”"})'),
                        ))
                    .toList(),
                onChanged: (String? v) => setState(() => _selectedPatientId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedQuizId,
                decoration: const InputDecoration(
                  labelText: 'Quiz',
                  prefixIcon: Icon(Icons.quiz_outlined),
                ),
                items: quizzes
                    .map((Quiz q) => DropdownMenuItem<String>(
                          value: q.id,
                          child: Text('${q.title}${q.isPreset ? " (preset)" : ""}'),
                        ))
                    .toList(),
                onChanged: (String? v) => setState(() => _selectedQuizId = v),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: _dueAt ?? DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) setState(() => _dueAt = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due date (optional)',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _dueAt == null ? 'No due date' : _dueAt!.toLocal().toString().split(' ').first,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes for patient (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Assign',
                icon: Icons.send_rounded,
                isLoading: _isSaving,
                onPressed: () => _save(patients: patients, quizzes: quizzes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

