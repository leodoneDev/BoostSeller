import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class CustomCurrencyInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? hintText;
  final AutovalidateMode? autovalidateMode;

  const CustomCurrencyInput({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.validator,
    this.hintText,
    this.autovalidateMode,
  });

  @override
  State<CustomCurrencyInput> createState() => _CustomCurrencyInputState();
}

class _CustomCurrencyInputState extends State<CustomCurrencyInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    // Use provided FocusNode or create a new one
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // Only dispose if we created the FocusNode
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      validator: widget.validator,
      focusNode: _focusNode,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2),
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
      inputFormatters: [
        CurrencyInputFormatter(
          leadingSymbol: '\$',
          useSymbolPadding: true,
          mantissaLength: 2,
          thousandSeparator: ThousandSeparator.Comma,
        ),
      ],
    );
  }
}
