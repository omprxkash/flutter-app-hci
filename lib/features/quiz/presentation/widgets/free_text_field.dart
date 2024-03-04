import 'package:flutter/material.dart';

class FreeTextAnswerField extends StatefulWidget {
  const FreeTextAnswerField({
    required this.value,
    required this.onChanged,
    this.hint,
    this.maxLength = 500,
    super.key,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLength;

  @override
  State<FreeTextAnswerField> createState() => _FreeTextAnswerFieldState();
}

class _FreeTextAnswerFieldState extends State<FreeTextAnswerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant FreeTextAnswerField old) {
    super.didUpdateWidget(old);
    if ((widget.value ?? '') != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLength: widget.maxLength,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Type your answer...',
        alignLabelWithHint: true,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      onChanged: widget.onChanged,
    );
  }
}
