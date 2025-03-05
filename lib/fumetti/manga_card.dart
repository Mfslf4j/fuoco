import 'package:flutter/material.dart';

class MangaCard extends StatelessWidget {
  final Map<String, dynamic> comic;

  const MangaCard({
    super.key,
    required this.comic,
  });

  @override
  Widget build(BuildContext context) {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress = (comic['last_read_volume'] ?? 0) / (comic['volumes'] ?? 1);

    bool isReadingInProgress = readingProgress > 0 && readingProgress < 1;
    bool isPurchasingInProgress = purchaseProgress < 1;
    bool isFullyPurchased = purchaseProgress == 1;
    bool isFullyRead = readingProgress == 1;
    bool isCompleted = isFullyPurchased && isFullyRead;
    bool hasProgressBars = (isReadingInProgress && isPurchasingInProgress) ||
        (isReadingInProgress && isFullyPurchased) ||
        (isPurchasingInProgress && isFullyRead);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? BorderSide(color: Colors.orange[800]!, width: 2)
            : BorderSide.none,
      ),
      color: isCompleted ? Colors.amber[300] : null,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width > 300;
          final progressBarHeight = isWide ? 25.0 : 20.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Immagine
                    SizedBox(
                      height: width * 1.4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(comic['cover_url'] ?? 'https://via.placeholder.com/150'),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            foregroundDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                                stops: const [0.7, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 4,
                            child: Text(
                              comic['title'] ?? 'Titolo sconosciuto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWide ? 18 : 14,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isFullyPurchased || isFullyRead)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (isCompleted)
                                    _buildBadge('Completato', Colors.orange[800]!, isWide)
                                  else ...[
                                    if (isFullyPurchased)
                                      _buildBadge('Acquistato', Colors.green[700]!, isWide),
                                    if (isFullyRead)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: _buildBadge('Letto', Colors.blue[700]!, isWide),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Contenuto testuale
                    Padding(
                      padding: EdgeInsets.all(isWide ? 8 : 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: isWide ? 16 : 14,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: isWide ? 6 : 4),
                              Text(
                                'Autore: ${comic['author'] ?? 'Sconosciuto'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: isWide ? 14 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(height: isWide ? 4 : 2),
                          Row(
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: isWide ? 16 : 14,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: isWide ? 6 : 4),
                              Text(
                                'Volumi: ${comic['volumes'] ?? 'N/A'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: isWide ? 14 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Barre di progresso
              if (hasProgressBars && !isCompleted)
                SizedBox(
                  height: progressBarHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: _buildProgressBars(
                      isReadingInProgress: isReadingInProgress,
                      isPurchasingInProgress: isPurchasingInProgress,
                      isFullyPurchased: isFullyPurchased,
                      isFullyRead: isFullyRead,
                      readingProgress: readingProgress,
                      purchaseProgress: purchaseProgress,
                      isWide: isWide,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 12 : 8,
        vertical: isWide ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isWide ? 14 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBars({
    required bool isReadingInProgress,
    required bool isPurchasingInProgress,
    required bool isFullyPurchased,
    required bool isFullyRead,
    required double readingProgress,
    required double purchaseProgress,
    required bool isWide,
  }) {
    if (isReadingInProgress && isPurchasingInProgress) {
      return Row(
        children: [
          Expanded(
            child: _buildProgressBar('Lettura', readingProgress, Colors.blue, isWide, isLeft: true),
          ),
          Expanded(
            child: _buildProgressBar('Acquisto', purchaseProgress, Colors.green, isWide, isLeft: false),
          ),
        ],
      );
    } else if (isReadingInProgress && isFullyPurchased) {
      return _buildProgressBar('Lettura', readingProgress, Colors.blue, isWide, isLeft: true);
    } else if (isPurchasingInProgress && isFullyRead) {
      return _buildProgressBar('Acquisto', purchaseProgress, Colors.green, isWide, isLeft: true);
    }
    return const SizedBox.shrink();
  }

  Widget _buildProgressBar(String label, double value, Color color, bool isWide, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.only(
          bottomLeft: isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: isLeft ? const Radius.circular(12) : Radius.zero,
              bottomRight: !isLeft ? const Radius.circular(12) : Radius.zero,
            ),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: isWide ? 25 : 20,
            ),
          ),
          Center(
            child: Text(
              '$label: ${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isWide ? 12 : 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}