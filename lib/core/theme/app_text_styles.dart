import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle get headingSmall =>
      GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold);

  static TextStyle get bodyLarge =>
      GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyMedium =>
      GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get caption => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}
