import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/question_option.dart';

/// 5-point Likert rendered as a column of full-width buttons. Chose this over
/// a slider because sliders are imprecise on touch and hard for low-vision
/// or motor-impaired users to land on a specific value.
class LikertScaleField extends StatelessWidget {
  const LikertScaleField({
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
    return Column(
      children: <Widget>[
        for (final QuestionOption opt in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LikertButton(
              option: opt,
              selected: selectedId == opt.id,
              onTap: () => onChanged(opt.id),
            ),
          ),
      ],
    );
  }
}

class _LikertButton extends StatelessWidget {
  const _LikertButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final QuestionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? AppColors.primary
        : Theme.of(context).dividerColor;
    final Color fillColor = selected
        ? AppColors.primary.withValues(alpha: 0.13)
        : Theme.of(context).colorScheme.surface;
    final Color textColor = selected
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(
            minHeight: AppConstants.minTapTargetDp + 8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: selected ? 2.5 : 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  key: ValueKey<bool>(selected),
                  color: selected
                      ? AppColors.primary
                      : Theme.of(context).disabledColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
