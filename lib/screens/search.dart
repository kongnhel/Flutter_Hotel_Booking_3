import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/roomType_model.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/search_result_page.dart';

// Import the new widgets
import 'package:hotel_booking/widgets/search_input_dropdown.dart';
import 'package:hotel_booking/widgets/category_dropdown.dart';
import 'package:hotel_booking/widgets/date_input_field.dart';
import 'package:hotel_booking/widgets/counter_input.dart';
import 'package:hotel_booking/widgets/search_header.dart';

const String kBaseUrl =
    'https://flutter-hotel-booking-api-2.onrender.com/api'; // Update to your backend URL

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Room> allRooms = [];

  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  String? _selectedCity; // Holds the city name
  String? _selectedCategory; // Holds the roomType ID
  int _guests = 1;
  int _rooms = 1;

  final List<Map<String, String>> cities = [
    {'name': 'ភ្នំពេញ'},
    {'name': 'សៀមរាប'},
    {'name': 'ព្រះសីហនុ'},
    {'name': 'បាត់ដំបង'},
    {'name': 'បន្ទាយមានជ័យ'},
  ];

  Map<String, String> roomTypeNames =
      {}; // key: roomTypeId, value: roomTypeName

  @override
  void initState() {
    super.initState();
    fetchRooms();
    fetchRoomTypes();
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  Future<void> fetchRoomTypes() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        List<RoomType> types = data.map((e) => RoomType.fromJson(e)).toList();
        setState(() {
          roomTypeNames = {for (var type in types) type.id: type.name};
          // Set a default selected category if none is selected and types are available
          if (_selectedCategory == null && roomTypeNames.isNotEmpty) {
            _selectedCategory = roomTypeNames.keys.first;
          }
        });
      } else {
        debugPrint(
          "បរាជ័យក្នុងការផ្ទុកប្រភេទបន្ទប់, ស្ថានភាព: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint('កំហុសក្នុងការទាញយកប្រភេទបន្ទប់: $e');
    }
  }

  Future<void> fetchRooms() async {
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (res.statusCode == 200) {
        final List jsonData = jsonDecode(res.body);
        setState(() {
          allRooms = jsonData.map((e) => Room.fromJson(e)).toList();
        });
      } else {
        debugPrint("បរាជ័យក្នុងការផ្ទុកបន្ទប់: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("កំហុសក្នុងការទាញយកបន្ទប់: $e");
    }
  }

  void _handleSearch() {
    final cityQuery = _selectedCity ?? '';
    final categoryIdQuery = _selectedCategory ?? ''; // This is the ID

    final results = allRooms.where((room) {
      final matchLocation = room.location.toLowerCase().contains(
        cityQuery.toLowerCase(),
      );
      // Match by roomTypeId (the ID from the dropdown)
      final matchCategory = room.roomTypeId.toLowerCase().contains(
        categoryIdQuery.toLowerCase(),
      );

      return matchLocation && matchCategory;
    }).toList();

    // Get the display name for the category
    final String categoryDisplayName =
        roomTypeNames[categoryIdQuery] ?? 'ប្រភេទណាមួយ';

    final searchParams = {
      'location': cityQuery.isNotEmpty ? cityQuery : 'គ្រប់ទីកន្លែង',
      'checkIn': _checkInController.text.isNotEmpty
          ? _checkInController.text
          : 'ថ្ងៃណាមួយ',
      'checkOut': _checkOutController.text.isNotEmpty
          ? _checkOutController.text
          : 'ថ្ងៃណាមួយ',
      'guests': _guests,
      'rooms': _rooms,
      'category': categoryDisplayName, // Pass the display name
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          searchParameters: searchParams,
          searchResults: results,
          roomTypeNames: roomTypeNames, // Pass the map for results page to use
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://placehold.co/600x400/ADD8E6/000000?text=Hotel+Background',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Text(
                    'បរាជ័យក្នុងការផ្ទុករូបភាព',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SearchHeader(), // Use the new SearchHeader widget
                    const SizedBox(height: 8),
                    const Text(
                      'ស្វែងរកកន្លែងស្នាក់នៅដ៏ល្អឥតខ្ចោះជាមួយ WanderStay',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),

                    // City Dropdown
                    const Text(
                      'នៅឯណា?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SearchInputDropdown(
                      value: _selectedCity,
                      hintText: "ជ្រើសរើសទីក្រុង",
                      items: cities,
                      onChanged: (val) => setState(() => _selectedCity = val),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: DateInputField(
                            label: 'ថ្ងៃចូល',
                            controller: _checkInController,
                            context: context, // Pass context here
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DateInputField(
                            label: 'ថ្ងៃចេញ',
                            controller: _checkOutController,
                            context: context, // Pass context here
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CounterInput(
                            label: 'ភ្ញៀវ',
                            value: _guests,
                            onChanged: (val) => setState(() => _guests = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CounterInput(
                            label: 'បន្ទប់',
                            value: _rooms,
                            onChanged: (val) => setState(() => _rooms = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Room Category
                    const Text(
                      'ប្រភេទបន្ទប់',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryDropdown(
                      value: _selectedCategory,
                      hintText: "ជ្រើសរើសប្រភេទបន្ទប់",
                      roomTypesMap: roomTypeNames,
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'ស្វែងរក',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
