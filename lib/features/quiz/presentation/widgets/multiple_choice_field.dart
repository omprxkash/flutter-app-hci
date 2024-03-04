import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/question_option.dart';

class MultipleChoiceField extends StatelessWidget {
  const MultipleChoiceField({
    required this.options,
    required this.selectedIds,
    required this.onChanged,
    this.allowMultiple = false,
    super.key,
  });

  final List<QuestionOption> options;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final bool allowMultiple;

  void _toggle(String id) {
    if (allowMultiple) {
      final List<String> next = List<String>.from(selectedIds);
      if (next.contains(id)) {
        next.remove(id);
      } else {
        next.add(id);
      }
      onChanged(next);
    } else {
      onChanged(<String>[id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final QuestionOption opt in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceTile(
              option: opt,
              selected: selectedIds.contains(opt.id),
              allowMultiple: allowMultiple,
              onTap: () => _toggle(opt.id),
            ),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.option,
    required this.selected,
    required this.allowMultiple,
    required this.onTap,
  });

  final QuestionOption option;
  final bool selected;
  final bool allowMultiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = selected
        ? AppColors.primary
        : Theme.of(context).dividerColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppConstants.minTapTargetDp,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              allowMultiple
                  ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
                  : (selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked),
              color: selected
                  ? AppColors.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
