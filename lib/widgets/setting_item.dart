import 'package:flutter/material.dart'; // Needed for Flutter widgets
import 'package:hotel_booking/theme/color.dart'; // Assuming AppColor is here

class SettingItem extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final VoidCallback? onTap;

  const SettingItem({
    Key? key,
    required this.title,
    required this.leadingIcon,
    required this.leadingIconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(leadingIcon, color: leadingIconColor, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }
}