import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericAnswerField extends StatefulWidget {
  const NumericAnswerField({
    required this.value,
    required this.onChanged,
    this.minValue,
    this.maxValue,
    this.allowDecimal = false,
    super.key,
  });

  final num? value;
  final ValueChanged<num?> onChanged;
  final num? minValue;
  final num? maxValue;
  final bool allowDecimal;

  @override
  State<NumericAnswerField> createState() => _NumericAnswerFieldState();
}

class _NumericAnswerFieldState extends State<NumericAnswerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant NumericAnswerField old) {
    super.didUpdateWidget(old);
    final String newText = widget.value?.toString() ?? '';
    if (newText != _controller.text) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final num? parsed =
        widget.allowDecimal ? num.tryParse(raw.trim()) : int.tryParse(raw.trim());
    if (parsed == null) return 'Enter a number.';
    if (widget.minValue != null && parsed < widget.minValue!) {
      return 'Must be ≥ ${widget.minValue}.';
    }
    if (widget.maxValue != null && parsed > widget.maxValue!) {
      return 'Must be ≤ ${widget.maxValue}.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.allowDecimal),
      inputFormatters: <TextInputFormatter>[
        if (!widget.allowDecimal) FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: widget.minValue != null && widget.maxValue != null
            ? '${widget.minValue} – ${widget.maxValue}'
            : 'Enter a number',
        prefixIcon: const Icon(Icons.calculate_outlined),
      ),
      style: Theme.of(context).textTheme.titleLarge,
      validator: _validate,
      onChanged: (String v) {
        if (v.trim().isEmpty) {
          widget.onChanged(null);
          return;
        }
        final num? parsed = widget.allowDecimal ? num.tryParse(v.trim()) : int.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
