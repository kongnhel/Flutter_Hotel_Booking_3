import 'dart:io'; // Needed for File
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:flutter/material.dart'; // Needed for Flutter widgets

class ProfileAvatar extends StatelessWidget {
  final File? profileImageFile;
  final String? profileImageUrl;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final VoidCallback onTap;
  final VoidCallback onImageError;

  const ProfileAvatar({
    Key? key,
    this.profileImageFile,
    this.profileImageUrl,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.onTap,
    required this.onImageError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageProvider;

    if (profileImageFile != null && !kIsWeb) {
      imageProvider = FileImage(profileImageFile!);
    } else if (kIsWeb &&
        profileImageUrl != null &&
        (profileImageUrl!.startsWith('blob:') ||
            profileImageUrl!.startsWith('data:'))) {
      imageProvider = NetworkImage(profileImageUrl!);
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(profileImageUrl!);
    }

    String initials = "";
    if (firstNameController.text.isNotEmpty) {
      initials += firstNameController.text[0].toUpperCase();
    }
    if (lastNameController.text.isNotEmpty) {
      initials += lastNameController.text[0].toUpperCase();
    }
    if (initials.isEmpty && emailController.text.isNotEmpty) {
      initials = emailController.text[0].toUpperCase();
    }
    if (initials.isEmpty) initials = "?";

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          imageProvider != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      const Color.fromARGB(255, 15, 189, 27).withOpacity(0.3),
                  backgroundImage: imageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('កំហុសក្នុងការផ្ទុករូបភាព: $exception');
                    onImageError();
                  },
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      const Color.fromARGB(255, 15, 189, 27).withOpacity(0.3),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 15, 189, 27),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}