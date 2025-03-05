import 'package:flutter/material.dart';

class MangaCard extends StatelessWidget {
  final Map<String, dynamic> comic;

  const MangaCard({
    super.key,
    required this.comic,
  });

  @override
  Widget build(BuildContext context) {
    List<String> purchasedNumbers = comic['bought_volumes'].split(",");
    var purchaseProgress = purchasedNumbers.length / comic['volumes'];
    var readingProgress = comic['last_read_volume'] / comic['volumes'];

    bool isReadingInProgress = readingProgress > 0 && readingProgress < 1;
    bool isPurchasingInProgress = purchaseProgress < 1;
    bool isFullyPurchased = purchaseProgress == 1;
    bool isFullyRead = readingProgress == 1;
    bool hasProgressBars = (isReadingInProgress && isPurchasingInProgress) ||
        (isReadingInProgress && isFullyPurchased) ||
        (isPurchasingInProgress && isFullyRead);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Angoli tondi per la card
      ),
      clipBehavior: Clip.antiAlias, // Per garantire che l'immagine rispetti i bordi tondi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immagine con titolo e badge
          Stack(
            children: [
              // Immagine di copertina
              Container(
                height: 220, // Altezza fissa per mostrare l'immagine intera
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12), // Solo angoli superiori tondi
                  ),
                  image: DecorationImage(
                    image: NetworkImage(comic['cover_url']),
                    fit: BoxFit.cover, // L'immagine occupa tutto lo spazio
                    alignment: Alignment.topCenter,
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6), // Fading inferiore
                    ],
                    stops: const [0.7, 1.0], // Inizia il fading al 70%
                  ),
                ),
              ),
              // Titolo sopra l'immagine
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  comic['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Badge
              if (isFullyPurchased)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
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
                    child: const Text(
                      'Acquistato',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isFullyRead)
                Positioned(
                  top: isFullyPurchased ? 48 : 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
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
                    child: const Text(
                      'Letto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Contenuto sotto l'immagine
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autore: ${comic['author']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Volumi: ${comic['volumes']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (hasProgressBars) ...[
                  const SizedBox(height: 8),
                  if (isReadingInProgress && isPurchasingInProgress) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressBar('Lettura', readingProgress, Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildProgressBar('Acquisto', purchaseProgress, Colors.green),
                        ),
                      ],
                    ),
                  ] else if (isReadingInProgress && isFullyPurchased) ...[
                    _buildProgressBar('Progresso lettura', readingProgress, Colors.blue),
                  ] else if (isPurchasingInProgress && isFullyRead) ...[
                    _buildProgressBar('Progresso acquisto', purchaseProgress, Colors.green),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          height: 25,
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 25,
              ),
              Center(
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}