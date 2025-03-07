import 'package:flutter/material.dart';

import '../utils/progress_utils.dart';

class MangaCardProgress extends StatelessWidget {
  final Map<String, dynamic> comic;
  final bool isWide;
  final String selectedProfile;

  const MangaCardProgress({
    super.key,
    required this.comic,
    required this.isWide,
    required this.selectedProfile,
  });

  @override
  Widget build(BuildContext context) {
    final progressData = ProgressUtils.calculateProgress(comic, selectedProfile);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: _buildProgressBars(progressData),
    );
  }

  Widget _buildProgressBars(Map<String, dynamic> progressData) {
    if (progressData['isReadingInProgress'] &&
        progressData['isPurchasingInProgress']) {
      return Row(
        children: [
          Expanded(
            child: _buildProgressBar(
              'Lettura',
              progressData['readingProgress'],
              Colors.blue[700]!,
              true,
              false,
            ),
          ),
          Expanded(
            child: _buildProgressBar(
              'Acquisto',
              progressData['purchaseProgress'],
              Colors.green[700]!,
              false,
              false,
            ),
          ),
        ],
      );
    } else if (progressData['isReadingInProgress']) {
      return _buildProgressBar(
        'Lettura',
        progressData['readingProgress'],
        Colors.blue[700]!,
        true,
        true,
      );
    } else if (progressData['isPurchasingInProgress']) {
      return _buildProgressBar(
        'Acquisto',
        progressData['purchaseProgress'],
        Colors.green[700]!,
        true,
        true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProgressBar(
    String label,
    double value,
    Color color,
    bool isLeft,
    bool isFull,
  ) {
    return Container(
      height: 40, // Barre molto più spesse
      decoration: BoxDecoration(
        color: Colors.grey[400], // Sfondo visibile per contrasto
        borderRadius:
            !isFull
                ? BorderRadius.only(
                  bottomLeft: isLeft ? const Radius.circular(20) : Radius.zero,
                  bottomRight:
                      !isLeft ? const Radius.circular(20) : Radius.zero,
                )
                : BorderRadius.only(
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius:
                !isFull
                    ? BorderRadius.only(
                      bottomLeft:
                          isLeft ? const Radius.circular(20) : Radius.zero,
                      bottomRight:
                          !isLeft ? const Radius.circular(20) : Radius.zero,
                    )
                    : BorderRadius.only(
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              // Sfondo trasparente per usare il Container
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 40, // Altezza piena
            ),
          ),
          Text(
            '$label: ${(value * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isWide ? 14 : 12, // Testo più grande
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}