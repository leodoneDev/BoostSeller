import 'package:flutter/material.dart';

import 'package:boostseller/widgets/custom_input_text.dart'; // where CustomLabel is defined

class CustomMultilineTextField extends StatefulWidget {
  final String label;
  final bool required;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? hintText;
  final AutovalidateMode? autovalidateMode;
  final int minLines;
  final int maxLines;

  const CustomMultilineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.focusNode,
    this.validator,
    this.hintText,
    this.autovalidateMode,
    this.minLines = 3,
    this.maxLines = 8,
  });

  @override
  State<CustomMultilineTextField> createState() =>
      _CustomMultilineTextFieldState();
}

class _CustomMultilineTextFieldState extends State<CustomMultilineTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    // Use provided FocusNode or create a new one
    _focusNode = widget.focusNode ?? FocusNode();

    // Listen to focus changes and rebuild
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(label: widget.label, required: widget.required),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          autovalidateMode: widget.autovalidateMode,
          keyboardType: TextInputType.multiline,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          style: const TextStyle(color: Colors.white),
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            errorStyle: const TextStyle(height: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  _isFocused
                      ? const BorderSide(color: Colors.blue, width: 2)
                      : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
