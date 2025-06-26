import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final void Function(DateTime?) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final FocusNode? focusNode;
  final String? Function(DateTime?)? validator;
  final String? hintText;
  final AutovalidateMode? autovalidateMode;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.focusNode,
    this.lastDate,
    this.enabled = true,
    this.validator,
    this.hintText,
    this.autovalidateMode,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text:
          _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : '',
    );

    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      _controller.text =
          _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    FormFieldState<DateTime?> state,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime first = widget.firstDate ?? DateTime(now.year - 100);
    final DateTime last = widget.lastDate ?? DateTime(now.year + 100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: first,
      lastDate: last,
      helpText: 'Select ${widget.label}',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      state.didChange(picked);
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      initialValue: _selectedDate,
      validator: widget.validator,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<DateTime?> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.enabled ? () => _selectDate(context, state) : null,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _controller,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[850],
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white38,
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
                    errorText: state.errorText,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
