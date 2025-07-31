import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart'; // Ensure this path is correct
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// IMPORTANT: Update this URL for production deployments!
const String kBaseUrl =
    'https://flutter-hotel-booking-api-2.onrender.com/api'; // Or 'http://10.0.2.2:3000/api' for Android Emulator

class AddRoomScreen extends StatefulWidget {
  static const String id = '/AddRoomScreen';
  final Room? roomToEdit; // Optional parameter for editing

  const AddRoomScreen({super.key, this.roomToEdit});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String? uploadedImageUrl;
  String? _editingRoomId; // To keep track of the room being edited

  // Cloudinary config
  final String _cloudName = 'dlykpbl7s';
  final String _uploadPreset = 'rooms_images';

  // Store fetched room types from API
  List<Map<String, dynamic>> roomTypes = [];
  String? selectedRoomTypeId;

  String selectedLocation = 'ភ្នំពេញ'; // Default selected location
  final List<String> locations = const [
    'ភ្នំពេញ',
    'សៀមរាប',
    'បាត់ដំបង',
    'ព្រះសីហនុ',
    'កំពត',
    'កែប',
    'កោះរុង',
    'បន្ទាយមានជ័យ',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('AddRoomScreen: initState called.');
    fetchRoomTypes().then((_) {
      // After room types are fetched, then populate form if editing
      if (widget.roomToEdit != null) {
        _editingRoomId = widget.roomToEdit!.id;
        nameController.text = widget.roomToEdit!.name;
        priceController.text = widget.roomToEdit!.price;
        descriptionController.text = widget.roomToEdit!.description;
        uploadedImageUrl = widget.roomToEdit!.image;
        selectedLocation = widget.roomToEdit!.location;

        // Set selectedRoomTypeId based on the room being edited
        selectedRoomTypeId = widget.roomToEdit!.roomTypeId;
        debugPrint(
          'AddRoomScreen: Populated form for editing room ID: $_editingRoomId, Type ID: $selectedRoomTypeId',
        );
      } else {
        // If adding a new room and no type is selected, default to the first available
        if (selectedRoomTypeId == null && roomTypes.isNotEmpty) {
          setState(() {
            selectedRoomTypeId = roomTypes[0]['id'];
            debugPrint(
              'AddRoomScreen: Defaulting selectedRoomTypeId to: ${selectedRoomTypeId}',
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    debugPrint('AddRoomScreen: dispose called.');
    super.dispose();
  }

  Future<void> fetchRoomTypes() async {
    debugPrint('AddRoomScreen: Starting fetchRoomTypes...');
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (!mounted) {
        debugPrint(
          'AddRoomScreen: fetchRoomTypes completed, but widget is not mounted.',
        );
        return;
      }
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          roomTypes = data
              .map<Map<String, dynamic>>(
                (e) => {'id': e['id'], 'name': e['name']},
              )
              .toList();

          // Ensure selectedRoomTypeId is valid after fetching types
          if (selectedRoomTypeId != null &&
              !roomTypes.any((type) => type['id'] == selectedRoomTypeId)) {
            // If the previously selected ID is no longer valid, reset it
            selectedRoomTypeId = null;
          }

          if (selectedRoomTypeId == null && roomTypes.isNotEmpty) {
            selectedRoomTypeId = roomTypes[0]['id'];
          }
          debugPrint(
            'AddRoomScreen: Successfully fetched ${roomTypes.length} room types. Selected: $selectedRoomTypeId',
          );
        });
      } else {
        debugPrint(
          'AddRoomScreen: Failed to fetch room types: ${res.statusCode}, Body: ${res.body}',
        );
        _showSnackBar('បរាជ័យក្នុងការផ្ទុកប្រភេទបន្ទប់។', isError: true);
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Error fetching room types: $e');
      _showSnackBar('កំហុសបណ្តាញពេលទាញយកប្រភេទបន្ទប់។', isError: true);
    }
  }

  /// Displays a SnackBar with the given [message] and [isError] status.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Resets the form fields and clears any editing state.
  void _resetForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      uploadedImageUrl = null;
      selectedRoomTypeId = roomTypes.isNotEmpty ? roomTypes[0]['id'] : null;
      selectedLocation = 'ភ្នំពេញ';
      _editingRoomId = null; // Clear editing state
    });
    debugPrint('AddRoomScreen: Form reset.');
  }

  // --- Image Upload Logic (same as before) ---
  Future<String?> uploadImage(XFile pickedFile) async {
    debugPrint('AddRoomScreen: Starting image upload...');
    try {
      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
        );
        request.fields['upload_preset'] = _uploadPreset;
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: pickedFile.name,
          ),
        );

        var response = await request.send();
        if (response.statusCode == 200) {
          final resStr = await response.stream.bytesToString();
          final jsonRes = jsonDecode(resStr);
          debugPrint(
            'AddRoomScreen: Image uploaded successfully (Web). URL: ${jsonRes['secure_url']}',
          );
          return jsonRes['secure_url'];
        } else {
          final resStr = await response.stream.bytesToString();
          debugPrint(
            'AddRoomScreen: Web Image Upload failed: ${response.statusCode}, Response: $resStr',
          );
          return null;
        }
      } else {
        final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
        File file = File(pickedFile.path);

        final res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'flutter_hotel_booking_rooms',
          ),
        );
        debugPrint(
          'AddRoomScreen: Image uploaded successfully (Mobile/Desktop). URL: ${res.secureUrl}',
        );
        return res.secureUrl;
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Image Upload Error: $e');
      return null;
    }
  }

  Future<void> handlePickUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      _showSnackBar('មិនមានរូបភាពត្រូវបានជ្រើសរើសទេ។');
      debugPrint('AddRoomScreen: No image selected.');
      return;
    }

    _showSnackBar('កំពុងបង្ហោះរូបភាព...');

    final url = await uploadImage(picked);
    debugPrint("AddRoomScreen: Uploaded URL: $url");

    if (!mounted) return;

    if (url != null) {
      setState(() {
        uploadedImageUrl = url;
      });
      _showSnackBar('រូបភាពត្រូវបានបង្ហោះដោយជោគជ័យ!');
    } else {
      _showSnackBar(
        'បរាជ័យក្នុងការបង្ហោះរូបភាព។ សូមព្យាយាមម្តងទៀត។',
        isError: true,
      );
    }
  }

  // --- API Calls ---
  Future<void> saveRoom() async {
    debugPrint('AddRoomScreen: saveRoom called. Editing ID: $_editingRoomId');
    if (!_formKey.currentState!.validate()) {
      debugPrint('AddRoomScreen: Form validation failed.');
      return;
    }

    if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
      _showSnackBar('សូមបង្ហោះរូបភាពសម្រាប់បន្ទប់។', isError: true);
      debugPrint('AddRoomScreen: No image uploaded.');
      return;
    }

    if (selectedRoomTypeId == null) {
      _showSnackBar('សូមជ្រើសរើសប្រភេទបន្ទប់។', isError: true);
      debugPrint('AddRoomScreen: No room type selected.');
      return;
    }

    if (_editingRoomId == null) {
      await _addRoom();
    } else {
      await _updateRoom(_editingRoomId!);
    }
  }

  Future<void> _addRoom() async {
    debugPrint('AddRoomScreen: _addRoom called.');
    final newRoom = Room(
      id: null,
      name: nameController.text.trim(),
      image: uploadedImageUrl!,
      price: priceController.text.trim(),
      roomTypeId: selectedRoomTypeId!,
      rate: '4.5',
      location: selectedLocation,
      isFavorited: false,
      isBooked: false,
      albumImages: const [],
      description: descriptionController.text.trim(),
    );

    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/rooms'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newRoom.toJson()..remove('id')),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _addRoom completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 201) {
        _showSnackBar('បន្ទប់ត្រូវបានបន្ថែមដោយជោគជ័យ!');
        _resetForm();
        debugPrint(
          'AddRoomScreen: Room added successfully. Popping with true.',
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } else {
        debugPrint(
          'AddRoomScreen: Failed to add room. Status: ${res.statusCode}, Body: ${res.body}',
        );
        _showSnackBar(
          'បរាជ័យក្នុងការបន្ថែមបន្ទប់។ ស្ថានភាព: ${res.statusCode}។',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Add room error: $e');
      _showSnackBar(
        'កំហុសបណ្តាញ។ បរាជ័យក្នុងការបន្ថែមបន្ទប់។ សូមព្យាយាមម្តងទៀត។',
        isError: true,
      );
    }
  }

  Future<void> _updateRoom(String id) async {
    final updatedRoom = Room(
      id: id,
      name: nameController.text.trim(),
      image: uploadedImageUrl!,
      price: priceController.text.trim(),
      roomTypeId: selectedRoomTypeId!,
      rate: '4.5',
      location: selectedLocation,
      isFavorited: false,
      isBooked: false,
      albumImages: const [],
      description: descriptionController.text.trim(),
    );

    try {
      final res = await http.put(
        Uri.parse('$kBaseUrl/rooms/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedRoom.toJson()),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _updateRoom completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 200) {
        _showSnackBar('បន្ទប់ត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!');
        _resetForm();
        debugPrint(
          'AddRoomScreen: Room updated successfully. Popping with true.',
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } else {
        debugPrint('AddRoomScreen: Update failed: ${res.body}');
        _showSnackBar(
          'បរាជ័យក្នុងការធ្វើបច្ចុប្បន្នភាពបន្ទប់។ ស្ថានភាព: ${res.statusCode}។',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Update error: $e');
      _showSnackBar(
        'កំហុសបណ្តាញ។ បរាជ័យក្នុងការធ្វើបច្ចុប្បន្នភាពបន្ទប់។',
        isError: true,
      );
    }
  }

  Future<void> _addRoomType(String name) async {
    debugPrint('AddRoomScreen: _addRoomType called with name: $name');
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/room_types'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _addRoomType completed, but widget is not mounted.',
        );
        return;
      }

      if (response.statusCode == 201) {
        _showSnackBar('ប្រភេទបន្ទប់ត្រូវបានបន្ថែម');
        debugPrint(
          'AddRoomScreen: Room type added successfully. Refreshing dropdown.',
        );
        await fetchRoomTypes(); // refresh the dropdown
      } else {
        debugPrint(
          'AddRoomScreen: Failed to add room type: ${response.statusCode}, Body: ${response.body}',
        );
        _showSnackBar('បរាជ័យក្នុងការបន្ថែមប្រភេទបន្ទប់។', isError: true);
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Add room type error: $e');
      _showSnackBar('កំហុសបណ្តាញ។ សូមព្យាយាមម្តងទៀត។', isError: true);
    }
  }

  void _showAddRoomTypeDialog() {
    final TextEditingController typeController = TextEditingController();
    debugPrint('AddRoomScreen: Showing Add Room Type dialog.');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('បន្ថែមប្រភេទបន្ទប់'),
          content: TextField(
            controller: typeController,
            decoration: const InputDecoration(
              labelText: 'ឈ្មោះប្រភេទបន្ទប់',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('AddRoomScreen: Add Room Type dialog cancelled.');
                Navigator.of(ctx).pop();
              },
              child: const Text('បោះបង់'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = typeController.text.trim();
                if (name.isEmpty) {
                  debugPrint('AddRoomScreen: Room type name is empty.');
                  return;
                }
                Navigator.of(ctx).pop();
                await _addRoomType(name);
              },
              child: const Text('បន្ថែម'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'AddRoomScreen: build method called. Selected Room Type ID: $selectedRoomTypeId',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingRoomId == null ? 'បន្ថែមបន្ទប់ថ្មី' : 'កែសម្រួលបន្ទប់',
          style: const TextStyle(
            color: Colors.white, // Set app bar title color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan, // Consistent app bar color
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingRoomId == null
                    ? 'បន្ថែមព័ត៌មានលម្អិតបន្ទប់ថ្មី'
                    : 'កែសម្រួលព័ត៌មានលម្អិតបន្ទប់',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan, // Consistent color for titles
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFormField(
                      controller: nameController,
                      labelText: 'ឈ្មោះបន្ទប់',
                      validator: (val) =>
                          val!.trim().isEmpty ? 'ទាមទារឈ្មោះបន្ទប់' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: priceController,
                      labelText: 'តម្លៃ',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.trim().isEmpty) return 'ទាមទារតម្លៃ';
                        if (double.tryParse(val) == null) {
                          return 'បញ្ចូលលេខត្រឹមត្រូវសម្រាប់តម្លៃ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'រូបភាពបន្ទប់',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    uploadedImageUrl != null &&
                            uploadedImageUrl!.startsWith("http")
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              uploadedImageUrl!,
                              height: 150, // Increased image height
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 80, // Larger icon
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 150, // Increased height
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Center(
                              child: Text(
                                'មិនមានរូបភាពត្រូវបានជ្រើសរើសទេ',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        // Changed to ElevatedButton
                        onPressed: handlePickUploadImage,
                        icon: const Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'បង្ហោះរូបភាព',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blueAccent, // Distinct color for upload
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedRoomTypeId,
                            decoration: const InputDecoration(
                              labelText: 'ប្រភេទបន្ទប់',
                              border: OutlineInputBorder(),
                            ),
                            items: roomTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['id'],
                                child: Text(type['name']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedRoomTypeId = val);
                                debugPrint(
                                  'AddRoomScreen: Selected Room Type ID: $val',
                                );
                              }
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? 'ទាមទារប្រភេទបន្ទប់'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.cyan,
                          ), // Consistent color
                          tooltip: 'បន្ថែមប្រភេទបន្ទប់',
                          onPressed: _showAddRoomTypeDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'ទីតាំង',
                        border: OutlineInputBorder(),
                      ),
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedLocation = val);
                          debugPrint('AddRoomScreen: Selected Location: $val');
                        }
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? 'ទាមទារទីតាំង' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: descriptionController,
                      labelText: 'ការពិពណ៌នា',
                      maxLines: 3,
                      alignLabelWithHint: true,
                      validator: (val) =>
                          val!.trim().isEmpty ? 'ទាមទារការពិពណ៌នា' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveRoom,
                        icon: Icon(
                          _editingRoomId == null ? Icons.add_home : Icons.save,
                          color: Colors.white, // Icon color
                        ),
                        label: Text(
                          _editingRoomId == null
                              ? 'បន្ថែមបន្ទប់'
                              : 'ធ្វើបច្ចុប្បន្នភាពបន្ទប់',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan, // Consistent color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Rounded corners
                          ),
                          elevation: 5, // Add elevation
                        ),
                      ),
                    ),
                    if (_editingRoomId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              debugPrint(
                                'AddRoomScreen: Cancel Edit button pressed. Popping with false.',
                              );
                              _resetForm();
                              Navigator.pop(
                                context,
                                false,
                              ); // Pop without success
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.redAccent,
                            ), // Icon color
                            label: const Text(
                              'បោះបង់ការកែសម្រួល',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ), // Text color
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                color: Colors.redAccent,
                              ), // Border color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // Rounded corners
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent TextFormField styling
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        alignLabelWithHint: alignLabelWithHint,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
