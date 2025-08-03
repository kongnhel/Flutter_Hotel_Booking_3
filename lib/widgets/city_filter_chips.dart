import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/theme/color.dart';

class CityFilterChips extends StatelessWidget {
  final List<Room> featuredRooms;
  final String? selectedLocation;
  final Function(String?) onLocationSelected;

  const CityFilterChips({
    super.key,
    required this.featuredRooms,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueLocations = featuredRooms.map((r) => r.location).toSet().toList();
    final allOptions = ['បន្ទប់ទាំងអស់', ...uniqueLocations];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 5, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(allOptions.length, (index) {
          final location = allOptions[index];
          final isSelected =
              (selectedLocation == null && location == 'បន្ទប់ទាំងអស់') ||
              (selectedLocation == location);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  onLocationSelected(location == 'បន្ទប់ទាំងអស់' ? null : location),
              child: Chip(
                label: Text(location),
                backgroundColor: isSelected ? AppColor.cyan : Colors.grey[300],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
