import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';

class CustomToggleField extends StatefulWidget {
  final String label;
  final bool required;
  final bool initialValue;
  final void Function(bool value)? onChanged;

  const CustomToggleField({
    super.key,
    required this.label,
    this.required = false,
    this.initialValue = true,
    this.onChanged,
  });

  @override
  State<CustomToggleField> createState() => _CustomToggleFieldState();
}

class _CustomToggleFieldState extends State<CustomToggleField> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label with optional *
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (widget.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
              ],
            ),
          ),

          // Toggle button
          Switch(
            value: _value,
            activeColor: Config.activeButtonColor,
            inactiveThumbColor: Colors.grey,
            onChanged: (newValue) {
              setState(() => _value = newValue);
              widget.onChanged?.call(newValue);
            },
          ),
        ],
      ),
    );
  }
}
