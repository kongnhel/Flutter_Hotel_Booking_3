import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value; // This value will be the roomType ID
  final String hintText;
  final Map<String, String> roomTypesMap; // Map of ID to Name
  final ValueChanged<String?> onChanged; // Callback receives the selected ID

  const CategoryDropdown({
    Key? key,
    required this.value,
    required this.hintText,
    required this.roomTypesMap,
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
          items: roomTypesMap.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key, // Value is the roomType ID
              child: Text(entry.value), // Display is the roomType Name
            );
          }).toList(),
        ),
      ),
    );
  }
}
