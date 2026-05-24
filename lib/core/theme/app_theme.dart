import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accentYellow,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentYellow,
        secondary: AppColors.accentPink,
        error: AppColors.accentRed,
        surface: AppColors.cardWhite,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.black, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.accentYellow,
          elevation: 0,
          side: const BorderSide(color: AppColors.black, width: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black, width: 4),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        labelStyle: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        titleMedium: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.caption,
      ).apply(bodyColor: AppColors.black, displayColor: AppColors.black),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accentYellow,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentYellow,
        secondary: AppColors.accentPink,
        error: AppColors.accentRed,
        surface: AppColors.darkCard,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.darkText, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.accentYellow,
          elevation: 0,
          side: const BorderSide(color: AppColors.darkText, width: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkText, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkText, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkText, width: 4),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        labelStyle: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        titleMedium: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.caption,
      ).apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
    );
  }
}
