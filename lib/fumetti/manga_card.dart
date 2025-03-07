import 'package:flutter/material.dart';
import 'manga_card_content.dart';
import 'manga_card_progress.dart';
import 'manga_edit_modal.dart';
import '../utils/progress_utils.dart';

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
  bool _isTapped = false; // Stato per l'animazione del tap

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isCompleted();
    final hasProgressBars = _hasProgressBars();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        _showEditModal(context);
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: _isTapped ? 0.9 : (value < 1.0 ? 0.5 + (value * 0.1) : 1.0),
            child: Opacity(
              opacity: value,
              child: Card(
                elevation: _isTapped ? 4 : 8,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: isCompleted
                      ? const BorderSide(color: Color(0xFFB8860B), width: 3)
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
                        comic: widget.comic,
                        isWide: MediaQuery.of(context).size.width > 600,
                        isCompleted: isCompleted,
                        selectedProfile: widget.selectedProfile,
                      ),
                      if (isCompleted)
                        const SizedBox(height: 40)
                      else if (hasProgressBars)
                        MangaCardProgress(
                          comic: widget.comic,
                          isWide: MediaQuery.of(context).size.width > 600,
                          selectedProfile: widget.selectedProfile,
                        )
                      else
                        _buildToReadPlaceholder(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );
    }
  }

  Widget _buildToReadPlaceholder() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
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
    final progressData = ProgressUtils.calculateProgress(widget.comic, widget.selectedProfile);
    return progressData['isCompleted'];
  }

  bool _hasProgressBars() {
    final progressData = ProgressUtils.calculateProgress(widget.comic, widget.selectedProfile);
    return progressData['hasProgressBars'] && !_isCompleted();
  }

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