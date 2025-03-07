import 'package:flutter/material.dart';
import 'package:fuoco/fumetti/manga_card.dart';

import '../utils/constants.dart';

class AnimatedMangaCard extends StatelessWidget {
  final Animation<double> animation;
  final MangaCard mangaCard;
  final double cardWidth;

  const AnimatedMangaCard({
    super.key,
    required this.animation,
    required this.mangaCard,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: AppConstants.cardScaleMin + (animation.value * (AppConstants.cardScaleMax - AppConstants.cardScaleMin)),
            child: SizedBox(
              width: cardWidth,
              child: mangaCard,
            ),
          ),
        );
      },
    );
  }
}