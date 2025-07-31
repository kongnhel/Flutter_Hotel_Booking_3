import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/order_page.dart';

class SearchResultsPage extends StatelessWidget {
  final Map<String, dynamic> searchParameters;
  final List<Room> searchResults;
  final Map<String, String> roomTypeNames; // Added to provide room type names

  const SearchResultsPage({
    super.key,
    required this.searchParameters,
    required this.searchResults,
    required this.roomTypeNames, // Required for displaying room type names
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'លទ្ធផលស្វែងរក', // Search Results
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'រកមិនឃើញបន្ទប់សម្រាប់ "${searchParameters['category'] ?? 'ប្រភេទនេះ'}"', // No rooms found for "this category"
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'សូមសាកល្បងប្រភេទ ឬលក្ខណៈវិនិច្ឆ័យផ្សេងទៀត។', // Try a different category or criteria.
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final room = searchResults[index];
                final String currentRoomTypeName =
                    roomTypeNames[room.roomTypeId] ??
                    'មិនស្គាល់ប្រភេទ'; // Get translated room type name

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderViewPage(
                          roomData: room.toJson(),
                          roomTypeName:
                              currentRoomTypeName, // Pass the correct room type name
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              room.image.isNotEmpty
                                  ? room.image
                                  : 'https://placehold.co/100x100/CCCCCC/000000?text=No+Image',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ប្រភេទ: $currentRoomTypeName', // Display translated room type name
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ទីតាំង: ${room.location}', // Location:
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${room.price}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(
                                room.isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: room.isFavorited
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                print('Favorite toggled for ${room.name}');
                                // TODO: Add favorite logic
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
