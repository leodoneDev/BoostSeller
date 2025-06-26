import 'package:flutter/material.dart';

class BalancedRadioGroup extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final List<String> items;
  final String title;

  const BalancedRadioGroup({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
    this.title = "Select Option",
  });

  @override
  Widget build(BuildContext context) {
    int itemCount = items.length;

    // Decide columns count based on itemCount
    int columns;
    if (itemCount <= 2) {
      columns = itemCount;
    } else if (itemCount <= 4) {
      columns = 2;
    } else {
      columns = 3;
    }

    // Split items into rows
    List<List<String>> rows = [];
    for (var i = 0; i < itemCount; i += columns) {
      rows.add(
        items.sublist(i, (i + columns > itemCount) ? itemCount : i + columns),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...rows.map((rowItems) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  rowItems.map((item) {
                    return Expanded(
                      child: InkWell(
                        onTap: () => onChanged(item),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: item,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                if (value != null) onChanged(value);
                              },
                            ),
                            Flexible(
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
