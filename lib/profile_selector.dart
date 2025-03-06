import 'package:flutter/material.dart';

class ProfileSelector extends StatelessWidget {
  final String selectedProfile;
  final Function(String) onProfileChanged;

  const ProfileSelector({
    super.key,
    required this.selectedProfile,
    required this.onProfileChanged,
  });

  static const Map<String, String> profileIcons = {
    'Matteo': 'https://cdn-icons-png.flaticon.com/128/1211/1211015.png',
    'Sara': 'https://cdn-icons-png.flaticon.com/128/7665/7665682.png',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Neutral light grey background
          borderRadius: BorderRadius.circular(8), // Softer corners
          border: Border.all(color: Colors.grey[400]!, width: 1), // Subtle border
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              profileIcons[selectedProfile]!,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              selectedProfile,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 0, 0), // Adjust as needed
      items: profileIcons.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Image.network(
                entry.value,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 10),
              Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onTap: () => onProfileChanged(entry.key),
        );
      }).toList(),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
    );
  }
}