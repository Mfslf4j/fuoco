import 'package:flutter/material.dart';
import 'manga_badge.dart';

class MangaCardContent extends StatelessWidget {
  final Map<String, dynamic> comic;
  final bool isWide;
  final bool isCompleted; // Nuovo parametro

  const MangaCardContent({
    super.key,
    required this.comic,
    required this.isWide,
    required this.isCompleted, // Richiesto
  });

  @override
  Widget build(BuildContext context) {
    final progressData = _calculateProgress();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCoverImage(),
              Positioned(bottom: 8, left: 8, right: 8, child: _buildTitle()),
              if (progressData['isFullyPurchased'] ||
                  progressData['isFullyRead'])
                Positioned(top: 8, right: 8, child: _buildBadges(progressData)),
            ],
          ),
        ),
        _buildTextContent(context),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        image: DecorationImage(
          image: NetworkImage(
            comic['cover_url'] ?? 'https://via.placeholder.com/150',
          ),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      comic['title'] ?? 'Titolo sconosciuto',
      style: TextStyle(
        color: isCompleted ? const Color(0xFFCF9A16) : Colors.white,
        // Dorato se completato
        fontSize: isWide ? 20 : 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        shadows:
            isCompleted
                ? [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(-1, -1),
                    blurRadius: 2,
                  ),
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(1, -1),
                    blurRadius: 2,
                  ),
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(-1, 1),
                    blurRadius: 2,
                  ),
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ] // Bordo evidente
                : const [
                  Shadow(
                    color: Colors.black87,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextContent(BuildContext context) {
    final progressData = _calculateProgress();
    return Padding(
      padding: EdgeInsets.all(isWide ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(
            Icons.person_outline,
            'Autore: ${comic['author'] ?? 'Sconosciuto'}',
            context,
          ),
          SizedBox(height: isWide ? 6 : 4),
          _buildInfoRow(
            Icons.book_outlined,
            'Volumi: ${comic['volumes'] ?? 'N/A'}',
            context,
          ),
          SizedBox(height: isWide ? 6 : 4),
          _buildInfoRow(
            Icons.local_mall_outlined,
            'Ultimo acquistato: ${progressData['lastPurchasedVolume']}',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: isWide ? 18 : 16, color: Colors.grey[800]),
        SizedBox(width: isWide ? 8 : 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: isWide ? 16 : 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(Map<String, dynamic> progressData) {
    return Column(
      children: [
        if (progressData['isCompleted'])
          MangaBadge(
            text: 'Completato',
            color: Color(0xFFCF9A16),
            isWide: isWide,
          )
        else ...[
          if (progressData['isFullyPurchased'])
            MangaBadge(
              text: 'Acquistato',
              color: Colors.green[800]!,
              isWide: isWide,
            ),
          if (progressData['isFullyRead'])
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: MangaBadge(
                text: 'Letto',
                color: Colors.blue[800]!,
                isWide: isWide,
              ),
            ),
        ],
      ],
    );
  }

  Map<String, dynamic> _calculateProgress() {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress =
        (comic['last_read_volume'] ?? 0) / (comic['volumes'] ?? 1);
    String lastPurchasedVolume =
        purchasedNumbers.isNotEmpty ? purchasedNumbers.last : 'N/A';

    return {
      'isReadingInProgress': readingProgress > 0 && readingProgress < 1,
      'isPurchasingInProgress': purchaseProgress < 1,
      'isFullyPurchased': purchaseProgress == 1,
      'isFullyRead': readingProgress == 1,
      'isCompleted': purchaseProgress == 1 && readingProgress == 1,
      'readingProgress': readingProgress,
      'purchaseProgress': purchaseProgress,
      'lastPurchasedVolume': lastPurchasedVolume,
    };
  }
}
