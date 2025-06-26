// Custom Check box Group : make by Leo on 2025/05/20

import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';

class CheckboxGroup extends StatefulWidget {
  final String label;
  final List<String> options;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const CheckboxGroup({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<CheckboxGroup> createState() => _CheckboxGroupState();
}

class _CheckboxGroupState extends State<CheckboxGroup> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();

    // Initialize selection state from controller (comma-separated string)
    final selectedItems =
        widget.controller.text.split(',').map((e) => e.trim()).toSet();

    _selected =
        widget.options.map((option) => selectedItems.contains(option)).toList();
  }

  List<String> _getSelectedValues() {
    return [
      for (int i = 0; i < widget.options.length; i++)
        if (_selected[i]) widget.options[i],
    ];
  }

  void _updateSelection(FormFieldState<String> state) {
    final selected = _getSelectedValues().join(',');
    widget.controller.text = selected;
    state.didChange(selected);
    state.validate();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        final hasError = state.hasError;
        final borderColor =
            hasError ? Theme.of(context).colorScheme.error : Colors.transparent;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[850],
                ),
                child: Column(
                  children: List.generate(widget.options.length, (index) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        widget.options[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _selected[index],
                      onChanged: (val) {
                        setState(() {
                          _selected[index] = val ?? false;
                          _updateSelection(state);
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Config.activeButtonColor,
                    );
                  }),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 6),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
