import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking/models/roomType_model.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/widgets/city_filter_chips.dart';
import 'package:hotel_booking/widgets/featured_rooms_carousel.dart';
import 'package:hotel_booking/widgets/section_title.dart';

const String kBaseUrl = 'https://flutter-hotel-booking-api-2.onrender.com/api';

class HomePage extends StatefulWidget {
  static const String id = '/HomePage';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedLocation;
  Map<String, String> roomTypeNames = {};
  List<Room> featuredRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchRoomTypes();
    await fetchFeaturedRooms();
  }

  Future<void> fetchFeaturedRooms() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          featuredRooms = data.map((e) => Room.fromJson(e)).toList();
        });
      } else {
        _showSnackBar('បរាជ័យក្នុងការទាញយកបន្ទប់។', isError: true);
      }
    } catch (e) {
      _showSnackBar('មានកំហុសបណ្តាញ។', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRoomTypes() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final types = data.map((e) => RoomType.fromJson(e)).toList();
        setState(() {
          roomTypeNames = {for (var type in types) type.id: type.name};
        });
      } else {
        _showSnackBar('បរាជ័យក្នុងការទាញយកប្រភេទបន្ទប់។', isError: true);
      }
    } catch (e) {
      _showSnackBar('មានកំហុសបណ្តាញពេលទាញយកប្រភេទបន្ទប់។', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        title: const Text("ស្វែងរកកន្លែងស្នាក់នៅ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.cyan,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: "ស្វែងរក និងកក់"),
                CityFilterChips(
                  featuredRooms: featuredRooms,
                  selectedLocation: selectedLocation,
                  onLocationSelected: (loc) =>
                      setState(() => selectedLocation = loc),
                ),
                const SectionTitle(title: "បន្ទប់ទាំងអស់"),
                FeaturedRoomsCarousel(
                  featuredRooms: featuredRooms,
                  roomTypeNames: roomTypeNames,
                  selectedLocation: selectedLocation,
                  isLoading: isLoading,
                  onFavoriteToggle: (updatedRoom) {
                    setState(() {
                      final i = featuredRooms
                          .indexWhere((room) => room.id == updatedRoom.id);
                      if (i != -1) featuredRooms[i] = updatedRoom;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
