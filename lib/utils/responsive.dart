// lib/utils/responsive.dart
import 'package:flutter/material.dart';

class Responsive {
  static double getWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  static double getHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  static double getFontSize(BuildContext context, double size) {
    double scaleFactor = MediaQuery.of(context).size.width / 1080;
    return size * scaleFactor.clamp(0.7, 1.3);
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: width * 0.05,
      vertical: width * 0.03,
    );
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLand = isLandscape(context);
    if (isLand) {
      return width * 0.35;
    } else {
      return width * 0.85;
    }
  }

  static double getCardHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isLand = isLandscape(context);
    if (isLand) {
      return height * 0.45;
    } else {
      return height * 0.35;
    }
  }
}