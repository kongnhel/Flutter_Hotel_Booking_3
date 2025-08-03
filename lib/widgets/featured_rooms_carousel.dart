import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/order_page.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/widgets/feature_item.dart';

class FeaturedRoomsCarousel extends StatelessWidget {
  final List<Room> featuredRooms;
  final Map<String, String> roomTypeNames;
  final String? selectedLocation;
  final bool isLoading;
  final Function(Room updatedRoom) onFavoriteToggle;

  const FeaturedRoomsCarousel({
    super.key,
    required this.featuredRooms,
    required this.roomTypeNames,
    required this.selectedLocation,
    required this.isLoading,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: AppColor.cyan),
        ),
      );
    }

    final filteredRooms = selectedLocation == null
        ? featuredRooms
        : featuredRooms.where((r) => r.location == selectedLocation).toList();

    if (filteredRooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("មិនមានបន្ទប់រកឃើញនៅទីតាំងនេះទេ។",
              style: TextStyle(color: AppColor.labelColor, fontSize: 16)),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: filteredRooms.length,
      options: CarouselOptions(
        height: 420,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
      ),
      itemBuilder: (context, index, realIndex) {
        final room = filteredRooms[index];
        return Stack(
          children: [
            FeatureItem(
              data: room,
              roomTypeName: roomTypeNames[room.roomTypeId] ?? 'មិនស្គាល់ប្រភេទ',
              width: MediaQuery.of(context).size.width * 0.8,
              onTapFavorite: () {
                onFavoriteToggle(
                  room.copyWith(isFavorited: !room.isFavorited),
                );
              },
              onTap: room.isBooked
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderViewPage(
                            roomData: room.toJson(),
                            roomTypeName:
                                roomTypeNames[room.roomTypeId] ?? 'មិនស្គាល់ប្រភេទ',
                          ),
                        ),
                      );
                    },
            ),
            if (room.isBooked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Text(
                      "បន្ទប់ត្រូវបានកក់ហើយ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
