import 'package:flutter/material.dart';
import 'manga_card_content.dart';
import 'manga_card_progress.dart';
import 'manga_edit_modal.dart';

class MangaCard extends StatelessWidget {
  final Map<String, dynamic> comic;
  final Function(Map<String, dynamic>)? onComicUpdated;

  const MangaCard({super.key, required this.comic, this.onComicUpdated});

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isCompleted();
    final hasProgressBars = _hasProgressBars();

    return InkResponse(
      onTap: () => _showEditModal(context),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              isCompleted
                  ? BorderSide(color: const Color(0xFFB8860B), width: 3)
                  : const BorderSide(color: Colors.black12, width: 2),
        ),
        clipBehavior: Clip.none,
        child: Container(
          decoration: _buildCardDecoration(isCompleted),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              MangaCardContent(
                comic: comic,
                isWide: MediaQuery.of(context).size.width > 600,
                isCompleted: isCompleted,
              ),
              if (isCompleted)
                const SizedBox(height: 40)
              else if (hasProgressBars)
                MangaCardProgress(
                  comic: comic,
                  isWide: MediaQuery.of(context).size.width > 600,
                )
              else
                _buildToReadPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(bool isCompleted) {
    if (isCompleted) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDDBD0E),
            Color(0xFFCF9A16),
            Color(0xFFFFE4B5),
            Color(0xFFA3770A),
          ],
          stops: [0.0, 0.4, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)), // Bordi uniformi
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)), // Bordi uniformi
      );
    }
  }

  Widget _buildToReadPlaceholder() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ), // Raggio uniformato a 16
      ),
      child: const Center(
        child: Text(
          'Da leggere',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  bool _isCompleted() {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress =
        (comic['last_read_volume'] ?? 0) / (comic['volumes'] ?? 1);
    return purchaseProgress == 1 && readingProgress == 1;
  }

  bool _hasProgressBars() {
    final progressData = _calculateProgress();
    return progressData['hasProgressBars'] && !_isCompleted();
  }

  Map<String, dynamic> _calculateProgress() {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress =
        (comic['last_read_volume'] ?? 0) / (comic['volumes'] ?? 1);

    bool isReadingInProgress = readingProgress > 0 && readingProgress < 1;
    bool isPurchasingInProgress = purchaseProgress < 1;

    return {
      'hasProgressBars':
          (isReadingInProgress && isPurchasingInProgress) ||
          (isReadingInProgress && purchaseProgress == 1) ||
          (isPurchasingInProgress && readingProgress == 1),
    };
  }

  void _showEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => MangaEditModal(comic: comic, onSave: onComicUpdated),
    );
  }
}
