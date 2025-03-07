import 'package:flutter/material.dart';
import 'package:fuoco/utils/progress_utils.dart';

import '../utils/constants.dart';
import 'manga_badge.dart';

class MangaCardContent extends StatelessWidget {
  final Map<String, dynamic> comic;
  final bool isWide;
  final bool isCompleted;
  final String selectedProfile;

  const MangaCardContent({
    super.key,
    required this.comic,
    required this.isWide,
    required this.isCompleted,
    required this.selectedProfile,
  });

  @override
  Widget build(BuildContext context) {
    final progressData = ProgressUtils.calculateProgress(comic, selectedProfile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCoverSection(progressData),
        _buildTextSection(context, progressData),
      ],
    );
  }

  /// Costruisce la sezione della copertina con immagine, titolo e badge
  Widget _buildCoverSection(Map<String, dynamic> progressData) {
    return SizedBox(
      height: AppConstants.cardHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCoverImage(),
          Positioned(
            top: AppConstants.wrapSpacing,
            left: AppConstants.wrapSpacing,
            right: AppConstants.wrapSpacing,
            child: _buildTitle(),
          ),
          if (progressData['isFullyPurchased'] || progressData['isFullyRead'])
            Positioned(
              top: AppConstants.wrapSpacing,
              right: AppConstants.wrapSpacing,
              child: _buildBadges(progressData),
            ),
        ],
      ),
    );
  }

  /// Costruisce l'immagine di copertina con gradient overlay
  Widget _buildCoverImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.coverBorderRadius)),
        image: DecorationImage(
          image: NetworkImage(comic['cover_url'] ?? AppConstants.placeholderImageUrl),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.coverBorderRadius)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  /// Costruisce il titolo del manga
  Widget _buildTitle() {
    return Text(
      comic['title'] ?? 'Titolo sconosciuto',
      style: TextStyle(
        color: isCompleted ? AppConstants.completedColor : Colors.white,
        fontSize: isWide ? 20 : 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        shadows: isCompleted ? _completedShadows() : _defaultShadows(),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  /// Ombre per il testo del titolo quando completato
  List<Shadow> _completedShadows() => const [
    Shadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 2),
    Shadow(color: Colors.black, offset: Offset(1, -1), blurRadius: 2),
    Shadow(color: Colors.black, offset: Offset(-1, 1), blurRadius: 2),
    Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
  ];

  /// Ombre predefinite per il testo del titolo
  List<Shadow> _defaultShadows() => const [
    Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 3),
  ];

  /// Costruisce la sezione testuale con informazioni sul manga
  Widget _buildTextSection(BuildContext context, Map<String, dynamic> progressData) {
    return Padding(
      padding: EdgeInsets.all(isWide ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(context, Icons.person_outline, 'Autore: ${comic['author'] ?? 'Sconosciuto'}'),
          SizedBox(height: isWide ? 6 : 4),
          _buildInfoRow(context, Icons.book_outlined, 'Volumi: ${comic['volumes'] ?? 'N/A'}'),
          SizedBox(height: isWide ? 6 : 4),
          _buildInfoRow(context, Icons.local_mall_outlined, 'Ultimo acquistato: ${progressData['lastPurchasedVolume']}'),
        ],
      ),
    );
  }

  /// Costruisce una riga di informazioni con icona e testo
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
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

  /// Costruisce i badge in base allo stato di progresso
  Widget _buildBadges(Map<String, dynamic> progressData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (progressData['isCompleted'])
          MangaBadge(
            text: 'Completato',
            color: AppConstants.completedColor,
            isWide: isWide,
          )
        else ...[
          if (progressData['isFullyPurchased'])
            MangaBadge(
              text: 'Acquistato',
              color: AppConstants.purchasedColor,
              isWide: isWide,
            ),
          if (progressData['isFullyRead'])
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.badgeSpacing),
              child: MangaBadge(
                text: 'Letto',
                color: AppConstants.readColor,
                isWide: isWide,
              ),
            ),
        ],
      ],
    );
  }
}