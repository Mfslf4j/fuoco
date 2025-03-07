import 'package:flutter/material.dart';

class AppConstants {
  static const int animationDurationPerCardMs = 100;
  static const double cardScaleMin = 0.8;
  static const double cardScaleMax = 1.0;
  static const double wrapSpacing = 8.0;
  static const double wrapRunSpacing = 8.0;
  static const int maxColumns = 7;
  static const int widthStep = 300;
  static const double cardHeight = 200.0;
  static const double badgeSpacing = 6.0;
  static const Color completedColor = Color(0xFFCF9A16);
  static const Color purchasedColor = Colors.green;
  static const Color readColor = Colors.blue;
  static const double coverBorderRadius = 20.0;
  static const String placeholderImageUrl = 'https://via.placeholder.com/150';
  static const double cardMargin = 12.0;
  static const double cardBorderRadius = 20.0;
  static const double tapScale = 0.9;
  static const double initialScale = 0.5;
  static const int animationDurationMs = 500;
  static const double elevationTapped = 4.0;
  static const double elevationNormal = 8.0;
  static const double placeholderHeight = 40.0;

  static const LinearGradient completedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDDBD0E), Color(0xFFCF9A16), Color(0xFFFFE4B5), Color(0xFFA3770A)],
    stops: [0.0, 0.4, 0.6, 1.0],
  );

  static const LinearGradient defaultGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color.fromRGBO(245, 245, 245, 1)],
  );
}