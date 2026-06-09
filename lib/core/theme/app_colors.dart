import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================
  // Light Mode Palette (Core Neobrutalism)
  // ==========================================
  static const Color background = Color(0xFFFFFEF0); // Warm Cream
  static const Color black = Color(0xFF000000); // Pure Black for borders & text
  static const Color white = Color(0xFFFFFFFF); // Pure White
  static const Color bottomAppbar = Color(
    0xFFFBFAEC,
  ); // Off-White for Bottom Appbar

  // Light Punchy Accents
  static const Color accentYellow = Color(0xFFFFD93D); // Electric Yellow
  static const Color accentRed = Color(0xFFFF6B6B); // Coral Red
  static const Color accentGreen = Color(0xFF6BCB77); // Bold Green
  static const Color accentBlue = Color(0xFF4D96FF); // Bold Blue
  static const Color accentPink = Color(0xFFFF6FC8); // Hot Pink
  static const Color accentPurple = Color(0xFFC77DFF); // Bold Purple
  static const Color accentBrown = Color(0xFF4C4546); // Bold Neutral Brown

  // Light Cards
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardYellow = Color(0xFFFFD93D);
  static const Color cardPink = Color(0xFFFF6FC8);
  static const Color cardBlue = Color(0xFF4D96FF);

  // ==========================================
  // Dark Mode Palette (Cyber Neobrutalism)
  // ==========================================
  static const Color darkBackground = Color(0xFF121212); // Sleek Dark Charcoal
  static const Color darkCard = Color(
    0xFF1E1E1E,
  ); // Slightly Lighter Dark Gray for Cards
  static const Color darkText = Color(
    0xFFFFFEF0,
  ); // Warm Cream Text for high readability
  static const Color darkBorder = Color(0xFFFFFEF0); // Warm Cream Border
  static const Color darkBottomAppbar = Color(0xFF1A1A1A); // Dark Bottom Appbar

  // Dark Punchy Accents (Adjusted for high-contrast & comfort on dark backgrounds)
  static const Color darkAccentYellow = Color(
    0xFFFFE17D,
  ); // Soft/Vibrant Neon Yellow
  static const Color darkAccentRed = Color(0xFFFF8A8A); // Soft Neon Red
  static const Color darkAccentGreen = Color(0xFF8CE397); // Soft Neon Green
  static const Color darkAccentBlue = Color(0xFF7CB1FF); // Soft Neon Blue
  static const Color darkAccentPink = Color(0xFFFF94D9); // Soft Neon Pink
  static const Color darkAccentPurple = Color(0xFFDCA8FF); // Soft Neon Purple
  static const Color darkAccentBrown = Color(
    0xFF8C8284,
  ); // Soft Neutral Gray/Brown

  // Dark Cards
  static const Color darkCardYellow = Color(
    0xFF3A361D,
  ); // Dark muted yellow for cards
  static const Color darkCardPink = Color(
    0xFF3D2333,
  ); // Dark muted pink for cards
  static const Color darkCardBlue = Color(
    0xFF1E2A3A,
  ); // Dark muted blue for cards

  // ==========================================
  // Dynamic Theme Helpers
  // ==========================================

  /// Resolves the background color automatically based on context theme.
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : background;

  /// Resolves the text/icon color automatically based on context theme.
  static Color textOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : black;

  /// Resolves the border color automatically based on context theme.
  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : black;

  /// Resolves the card background color automatically based on context theme.
  static Color cardOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : cardWhite;

  /// Resolves the bottom appbar color automatically based on context theme.
  static Color bottomAppbarOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBottomAppbar
      : bottomAppbar;

  /// Resolves accent yellow color automatically based on context theme.
  static Color accentYellowOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentYellow
      : accentYellow;

  /// Resolves accent red color automatically based on context theme.
  static Color accentRedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentRed
      : accentRed;

  /// Resolves accent green color automatically based on context theme.
  static Color accentGreenOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentGreen
      : accentGreen;

  /// Resolves accent blue color automatically based on context theme.
  static Color accentBlueOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentBlue
      : accentBlue;

  /// Resolves accent pink color automatically based on context theme.
  static Color accentPinkOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentPink
      : accentPink;

  /// Resolves accent purple color automatically based on context theme.
  static Color accentPurpleOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAccentPurple
      : accentPurple;
}
