import 'package:flutter/material.dart';
import 'package:fuoco/utils/progress_utils.dart';

import '../utils/constants.dart';
import 'manga_card_content.dart';
import 'manga_card_progress.dart';
import 'manga_edit_modal.dart';

class MangaCard extends StatefulWidget {
  final Map<String, dynamic> comic;
  final Function(Map<String, dynamic>)? onComicUpdated;
  final String selectedProfile;

  const MangaCard({
    super.key,
    required this.comic,
    this.onComicUpdated,
    required this.selectedProfile,
  });

  @override
  _MangaCardState createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {
  bool _isTapped = false;

  late Map<String, dynamic> _progressData; // Memorizza i dati di progresso

  @override
  void initState() {
    super.initState();
    _progressData = ProgressUtils.calculateProgress(widget.comic, widget.selectedProfile);
  }

  @override
  void didUpdateWidget(MangaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comic != widget.comic || oldWidget.selectedProfile != widget.selectedProfile) {
      _progressData = ProgressUtils.calculateProgress(widget.comic, widget.selectedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _progressData['isCompleted'];
    final hasProgressBars = _progressData['hasProgressBars'] && !isCompleted;
    final isWide = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => _handleTapUp(context),
      onTapCancel: () => setState(() => _isTapped = false),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: AppConstants.animationDurationMs),
        builder: (context, double value, child) => _buildAnimatedCard(isCompleted, value, child!),
        child: _buildCardContent(isCompleted, hasProgressBars, isWide),
      ),
    );
  }

  /// Gestisce il tap per mostrare il modal e ripristinare lo stato
  void _handleTapUp(BuildContext context) {
    setState(() => _isTapped = false);
    _showEditModal(context);
  }

  /// Costruisce il contenuto animato della card
  Widget _buildAnimatedCard(bool isCompleted, double animationValue, Widget child) {
    return Transform.scale(
      scale: _isTapped
          ? AppConstants.tapScale
          : (animationValue < 1.0 ? AppConstants.initialScale + (animationValue * 0.1) : 1.0),
      child: Opacity(
        opacity: animationValue,
        child: Card(
          elevation: _isTapped ? AppConstants.elevationTapped : AppConstants.elevationNormal,
          margin: const EdgeInsets.all(AppConstants.cardMargin),
          shape: _buildCardShape(isCompleted),
          clipBehavior: Clip.none,
          child: child,
        ),
      ),
    );
  }

  /// Costruisce la forma della card con bordi personalizzati
  ShapeBorder _buildCardShape(bool isCompleted) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      side: isCompleted
          ? const BorderSide(color: AppConstants.completedColor, width: 3)
          : const BorderSide(color: Colors.black12, width: 2),
    );
  }

  /// Costruisce il contenuto interno della card
  Widget _buildCardContent(bool isCompleted, bool hasProgressBars, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        gradient: isCompleted ? AppConstants.completedGradient : AppConstants.defaultGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MangaCardContent(
            comic: widget.comic,
            isWide: isWide,
            isCompleted: isCompleted,
            selectedProfile: widget.selectedProfile,
          ),
          if (isCompleted)
            const SizedBox(height: AppConstants.placeholderHeight)
          else if (hasProgressBars)
            MangaCardProgress(
              comic: widget.comic,
              isWide: isWide,
              selectedProfile: widget.selectedProfile,
            )
          else
            _buildToReadPlaceholder(),
        ],
      ),
    );
  }

  /// Costruisce il placeholder "Da leggere"
  Widget _buildToReadPlaceholder() {
    return Container(
      height: AppConstants.placeholderHeight,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppConstants.cardBorderRadius)),
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

  /// Mostra il modal di modifica
  void _showEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MangaEditModal(
        comic: widget.comic,
        onSave: widget.onComicUpdated,
        selectedProfile: widget.selectedProfile,
      ),
    );
  }
}