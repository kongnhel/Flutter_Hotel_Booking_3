import 'package:flutter/material.dart';

class SearchInputDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;

  const SearchInputDropdown({
    Key? key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hintText),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['name'],
              child: Text(item['name'] ?? ''),
            );
          }).toList(),
        ),
      ),
    );
  }
}
