import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quiz/domain/entities/question.dart';
import '../../../quiz/domain/entities/question_option.dart';
import '../../../quiz/domain/entities/question_type.dart';
import '../../../quiz/domain/entities/quiz.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';

/// Lets a doctor compose a custom quiz. Supports add/remove/reorder
/// questions and inline option editing for choice-type questions.
class QuizBuilderScreen extends ConsumerStatefulWidget {
  const QuizBuilderScreen({this.existingQuizId, super.key});

  final String? existingQuizId;

  @override
  ConsumerState<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends ConsumerState<QuizBuilderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _estMinutesController = TextEditingController();
  final List<_QuestionDraft> _questions = <_QuestionDraft>[];
  final Uuid _uuid = const Uuid();
  bool _isPreset = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _estMinutesController.dispose();
    super.dispose();
  }

  void _hydrate(Quiz q) {
    _titleController.text = q.title;
    _descController.text = q.description;
    _estMinutesController.text = q.estimatedMinutes?.toString() ?? '';
    _isPreset = q.isPreset;
    _questions
      ..clear()
      ..addAll(q.questions.map(_QuestionDraft.fromEntity));
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        _QuestionDraft(
          id: _uuid.v4(),
          text: '',
          type: QuestionType.singleChoice,
          options: <_OptionDraft>[
            _OptionDraft(id: _uuid.v4(), label: 'Option 1', score: 0),
            _OptionDraft(id: _uuid.v4(), label: 'Option 2', score: 1),
          ],
        ),
      );
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give the quiz a title.')),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dynamic doctor = ref.read(authStateChangesProvider).value;
    final String doctorId = (doctor?.id as String?) ?? '';

    final Quiz quiz = Quiz(
      id: widget.existingQuizId ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      questions: _questions.map((d) => d.toEntity()).toList(),
      createdBy: doctorId,
      createdAt: DateTime.now(),
      estimatedMinutes: int.tryParse(_estMinutesController.text.trim()),
    );

    final Result<Quiz, Failure> r = await ref
        .read(quizRepositoryProvider)
        .saveQuiz(quiz);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (r) {
      case Success<Quiz, Failure>():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quiz saved.')));
        if (context.canPop()) context.pop();
      case Err<Quiz, Failure>(:final Failure failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? id = widget.existingQuizId;
    if (id != null && !_initialized) {
      final AsyncValue<Quiz> async = ref.watch(quizByIdProvider(id));
      return async.when(
        loading: () => const AppScaffold(body: LoadingIndicator()),
        error: (Object e, _) => AppScaffold(
          title: 'Builder',
          body: Center(child: Text(e.toString())),
        ),
        data: (Quiz q) {
          _hydrate(q);
          _initialized = true;
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  Widget _buildForm() {
    final bool readOnly = _isPreset;
    return AppScaffold(
      title: readOnly
          ? 'Quiz (preset)'
          : (widget.existingQuizId == null ? 'New quiz' : 'Edit quiz'),
      maxContentWidth: 900,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: <Widget>[
          if (readOnly)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.lock_outline_rounded, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Preset quizzes are read-only. Assign them as-is.',
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            controller: _titleController,
            readOnly: readOnly,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            readOnly: readOnly,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _estMinutesController,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Estimated minutes'),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Text(
                'Questions (${_questions.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (!readOnly)
                SecondaryButton(
                  label: 'Add question',
                  icon: Icons.add_rounded,
                  expand: false,
                  onPressed: _addQuestion,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._questions.asMap().entries.map((MapEntry<int, _QuestionDraft> e) {
            final int idx = e.key;
            final _QuestionDraft q = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuestionEditor(
                index: idx,
                draft: q,
                readOnly: readOnly,
                onChanged: (_QuestionDraft updated) =>
                    setState(() => _questions[idx] = updated),
                onRemove: () => setState(() => _questions.removeAt(idx)),
                onMoveUp: idx > 0
                    ? () => setState(
                        () => _questions.insert(
                          idx - 1,
                          _questions.removeAt(idx),
                        ),
                      )
                    : null,
                onMoveDown: idx < _questions.length - 1
                    ? () => setState(
                        () => _questions.insert(
                          idx + 1,
                          _questions.removeAt(idx),
                        ),
                      )
                    : null,
                uuid: _uuid,
              ),
            );
          }),
          const SizedBox(height: 24),
          if (!readOnly)
            PrimaryButton(
              label: 'Save quiz',
              icon: Icons.save_outlined,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drafts â€” mutable working copies used by the builder UI.
// ---------------------------------------------------------------------------

class _QuestionDraft {
  _QuestionDraft({
    required this.id,
    required this.text,
    required this.type,
    this.options = const <_OptionDraft>[],
    this.required = true,
    this.helpText,
    this.minValue,
    this.maxValue,
  });

  factory _QuestionDraft.fromEntity(Question q) => _QuestionDraft(
    id: q.id,
    text: q.text,
    type: q.type,
    options: q.options
        .map(
          (opt) => _OptionDraft(id: opt.id, label: opt.label, score: opt.score),
        )
        .toList(),
    required: q.required,
    helpText: q.helpText,
    minValue: q.minValue,
    maxValue: q.maxValue,
  );

  String id;
  String text;
  QuestionType type;
  List<_OptionDraft> options;
  bool required;
  String? helpText;
  num? minValue;
  num? maxValue;

  Question toEntity() => Question(
    id: id,
    text: text,
    type: type,
    options: options
        .map(
          (opt) =>
              QuestionOption(id: opt.id, label: opt.label, score: opt.score),
        )
        .toList(),
    required: required,
    helpText: helpText,
    minValue: minValue,
    maxValue: maxValue,
  );
}

class _OptionDraft {
  _OptionDraft({required this.id, required this.label, required this.score});

  String id;
  String label;
  int score;
}

class _QuestionEditor extends StatelessWidget {
  const _QuestionEditor({
    required this.index,
    required this.draft,
    required this.readOnly,
    required this.onChanged,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.uuid,
  });

  final int index;
  final _QuestionDraft draft;
  final bool readOnly;
  final ValueChanged<_QuestionDraft> onChanged;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final Uuid uuid;

  static const Map<QuestionType, String> _typeLabels = <QuestionType, String>{
    QuestionType.singleChoice: 'Single choice',
    QuestionType.multiSelect: 'Multi-select',
    QuestionType.likert5: 'Likert (5-point)',
    QuestionType.yesNo: 'Yes / No',
    QuestionType.numeric: 'Numeric',
    QuestionType.freeText: 'Free text',
  };

  bool get _needsOptions =>
      draft.type == QuestionType.singleChoice ||
      draft.type == QuestionType.multiSelect ||
      draft.type == QuestionType.likert5 ||
      draft.type == QuestionType.yesNo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Question',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                if (!readOnly) ...<Widget>[
                  IconButton(
                    tooltip: 'Move up',
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: onMoveUp,
                  ),
                  IconButton(
                    tooltip: 'Move down',
                    icon: const Icon(Icons.arrow_downward_rounded),
                    onPressed: onMoveDown,
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onRemove,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: draft.text,
              readOnly: readOnly,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Question text'),
              onChanged: (String v) {
                draft.text = v;
                onChanged(draft);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QuestionType>(
              value: draft.type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: QuestionType.values
                  .map(
                    (QuestionType t) => DropdownMenuItem<QuestionType>(
                      value: t,
                      child: Text(_typeLabels[t] ?? t.name),
                    ),
                  )
                  .toList(),
              onChanged: readOnly
                  ? null
                  : (QuestionType? t) {
                      if (t == null) return;
                      draft.type = t;
                      if (draft.type == QuestionType.yesNo &&
                          draft.options.length != 2) {
                        draft.options = <_OptionDraft>[
                          _OptionDraft(id: uuid.v4(), label: 'Yes', score: 1),
                          _OptionDraft(id: uuid.v4(), label: 'No', score: 0),
                        ];
                      }
                      onChanged(draft);
                    },
            ),
            if (_needsOptions) ...<Widget>[
              const SizedBox(height: 16),
              Text('Options', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              for (int oi = 0; oi < draft.options.length; oi++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          initialValue: draft.options[oi].label,
                          readOnly: readOnly,
                          decoration: const InputDecoration(labelText: 'Label'),
                          onChanged: (String v) {
                            draft.options[oi].label = v;
                            onChanged(draft);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: draft.options[oi].score.toString(),
                          readOnly: readOnly,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Score'),
                          onChanged: (String v) {
                            draft.options[oi].score = int.tryParse(v) ?? 0;
                            onChanged(draft);
                          },
                        ),
                      ),
                      if (!readOnly)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: draft.options.length <= 2
                              ? null
                              : () {
                                  draft.options.removeAt(oi);
                                  onChanged(draft);
                                },
                        ),
                    ],
                  ),
                ),
              if (!readOnly)
                TextButton.icon(
                  onPressed: () {
                    draft.options.add(
                      _OptionDraft(
                        id: uuid.v4(),
                        label: '',
                        score: draft.options.length,
                      ),
                    );
                    onChanged(draft);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add option'),
                ),
            ],
            if (draft.type == QuestionType.numeric) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      initialValue: draft.minValue?.toString(),
                      readOnly: readOnly,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min'),
                      onChanged: (String v) {
                        draft.minValue = num.tryParse(v);
                        onChanged(draft);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: draft.maxValue?.toString(),
                      readOnly: readOnly,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max'),
                      onChanged: (String v) {
                        draft.maxValue = num.tryParse(v);
                        onChanged(draft);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Switch(
                  value: draft.required,
                  onChanged: readOnly
                      ? null
                      : (bool v) {
                          draft.required = v;
                          onChanged(draft);
                        },
                ),
                const SizedBox(width: 8),
                const Text('Required'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
