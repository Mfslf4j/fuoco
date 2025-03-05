import 'package:flutter/material.dart';

class MangaCardProgress extends StatelessWidget {
  final Map<String, dynamic> comic;
  final bool isWide;

  const MangaCardProgress({
    super.key,
    required this.comic,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final progressData = _calculateProgress();
    if (!progressData['hasProgressBars'] || progressData['isCompleted']) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300], // Colore più scuro per visibilità
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ), // Bordi più arrotondati
      ),
      child: _buildProgressBars(progressData),
    );
  }

  Map<String, dynamic> _calculateProgress() {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress =
        (comic['last_read_volume'] ?? 0) / (comic['volumes'] ?? 1);

    bool isReadingInProgress = readingProgress > 0 && readingProgress < 1;
    bool isPurchasingInProgress = purchaseProgress < 1;
    bool isFullyPurchased = purchaseProgress == 1;
    bool isFullyRead = readingProgress == 1;
    bool isCompleted = isFullyPurchased && isFullyRead;

    return {
      'isReadingInProgress': isReadingInProgress,
      'isPurchasingInProgress': isPurchasingInProgress,
      'isFullyPurchased': isFullyPurchased,
      'isFullyRead': isFullyRead,
      'isCompleted': isCompleted,
      'readingProgress': readingProgress,
      'purchaseProgress': purchaseProgress,
      'hasProgressBars':
          (isReadingInProgress && isPurchasingInProgress) ||
          (isReadingInProgress && isFullyPurchased) ||
          (isPurchasingInProgress && isFullyRead),
    };
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
    } else if (progressData['isReadingInProgress'] &&
        progressData['isFullyPurchased']) {
      return _buildProgressBar(
        'Lettura',
        progressData['readingProgress'],
        Colors.blue[700]!,
        true,
        true,
      );
    } else if (progressData['isPurchasingInProgress'] &&
        progressData['isFullyRead']) {
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
      height: isWide ? 40 : 30, // Barre molto più spesse
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
              minHeight: isWide ? 40 : 30, // Altezza piena
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
