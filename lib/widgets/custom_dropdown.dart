import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<Map<String, dynamic>> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isExpanded = true,
    this.autovalidateMode,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: FormField<String>(
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        builder: (FormFieldState<String> state) {
          final hasError = state.hasError;
          final borderColor =
              hasError
                  ? Theme.of(context).colorScheme.error
                  : _isFocused
                  ? Colors.blue
                  : Colors.transparent;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: widget.isExpanded,
                  hint: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.hint,
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ),
                  items:
                      widget.items.map((item) {
                        final id = item['id']?.toString();
                        final name = item['name'] ?? '';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                  value: widget.value,
                  onChanged: (newValue) {
                    state.didChange(newValue);
                    widget.onChanged(newValue);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 56,
                    padding: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: null,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 10),
                  child: Text(
                    state.errorText!,
                    style:
                        Theme.of(context).inputDecorationTheme.errorStyle ??
                        TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
