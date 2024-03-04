import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/question_option.dart';

class YesNoField extends StatelessWidget {
  const YesNoField({
    required this.options,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final List<QuestionOption> options;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final QuestionOption opt in options)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _YesNoButton(
                option: opt,
                selected: selectedId == opt.id,
                onTap: () => onChanged(opt.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _YesNoButton extends StatelessWidget {
  const _YesNoButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final QuestionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 88,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        constraints: const BoxConstraints(
          minHeight: AppConstants.minTapTargetDp + 24,
        ),
        child: Text(
          option.label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: selected ? AppColors.primary : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
