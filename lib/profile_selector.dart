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
    final GlobalKey _selectorKey = GlobalKey();

    return GestureDetector(
      key: _selectorKey,
      onTap: () => _showProfileMenu(context, _selectorKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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

  void _showProfileMenu(BuildContext context, GlobalKey key) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 10,
        offset.dx + size.width,
        0,
      ),
      // Imposta la larghezza del menu uguale a quella del pulsante
      constraints: BoxConstraints(
        minWidth: size.width, // Larghezza minima = larghezza del pulsante
        maxWidth: size.width, // Larghezza massima = larghezza del pulsante
      ),
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
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
    );
  }
}