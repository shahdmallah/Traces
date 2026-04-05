import 'package:flutter/material.dart';

/// Design system constants for consistent spacing and sizing
class Spacing {
  // Extra small
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}


class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}



class IconSize {
  static const xs = 16.0;
  static const sm = 20.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const xxl = 64.0;
}

class Elevation {
  static const none = 0.0;
  static const xs = 1.0;
  static const sm = 2.0;
  static const md = 4.0;
  static const lg = 8.0;
  static const xl = 12.0;
  static const xxl = 16.0;
}

class ShadowStyle {
  static const small = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  static const large = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
  ];

  static const extraLarge = [
    BoxShadow(
      color: Color(0x15000000),
      offset: Offset(0, 20),
      blurRadius: 25,
    ),
  ];
}

class AnimationDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}

class BreakPoint {
  static const mobile = 480.0;
  static const tablet = 768.0;
  static const desktop = 1024.0;
  static const largeDesktop = 1440.0;
}
