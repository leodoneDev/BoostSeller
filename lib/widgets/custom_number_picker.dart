import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CustomNumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final void Function(int) onChanged;
  final String label;

  const CustomNumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: NumberPicker(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              onChanged: onChanged,
              textStyle: const TextStyle(color: Colors.white38),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white30),
                  bottom: BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
