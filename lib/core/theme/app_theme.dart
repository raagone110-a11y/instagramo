import 'package:flutter/material.dart';

/// Custom color definitions for Instagramo
class InstagramoColors {
  // Brand colors
  static const Color primaryLight = Color(0xFFE1306C);
  static const Color primaryDark = Color(0xFFC13584);
  static const Color secondaryLight = Color(0xFF833AB4);
  static const Color secondaryDark = Color(0xFF5B51D8);
  static const Color accentLight = Color(0xFFFD1D1D);
  static const Color accentDark = Color(0xFFF77737);
  static const Color highlightLight = Color(0xFFFCAF45);
  static const Color highlightDark = Color(0xFF405DE6);

  // Gradient colors
  static const List<Color> brandGradient = [
    accentLight,
    primaryLight,
    secondaryLight,
    highlightDark,
  ];

  static const List<Color> darkGradient = [
    accentDark,
    primaryDark,
    secondaryDark,
    highlightDark,
  ];
}

/// Light theme configuration
final ThemeData instagramoLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: InstagramoColors.primaryLight,
    brightness: Brightness.light,
    primary: InstagramoColors.primaryLight,
    secondary: InstagramoColors.secondaryLight,
    tertiary: InstagramoColors.accentLight,
    surface: const Color(0xFFFFFBFF),
    surfaceContainerHighest: const Color(0xFFE7E0EC),
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFBFF),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: const Color(0xFFFFFBFF),
    scrolledUnderElevation: 0,
    titleTextStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Montserrat',
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFFFFBFF),
    type: BottomNavigationBarType.fixed,
    selectedItemColor: InstagramoColors.primaryLight,
    unselectedItemColor: Colors.black54,
    elevation: 8,
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFFFFFBFF),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3EDF7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: InstagramoColors.primaryLight, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: InstagramoColors.primaryLight,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: InstagramoColors.primaryLight,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF3EDF7),
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: InstagramoColors.primaryLight,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: const Color(0xFFFFFBFF),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Color(0xFFFFFBFF),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE7E0EC),
    thickness: 0.5,
    space: 0,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
      height: 1.2,
    ),
  ),
);

/// Dark theme configuration
final ThemeData instagramoDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: InstagramoColors.primaryDark,
    brightness: Brightness.dark,
    primary: InstagramoColors.primaryDark,
    secondary: InstagramoColors.secondaryDark,
    tertiary: InstagramoColors.accentDark,
    surface: const Color(0xFF1C1B1F),
    surfaceContainerHighest: const Color(0xFF2B2930),
  ),
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: const Color(0xFF0D0D0D),
    scrolledUnderElevation: 0,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Montserrat',
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0D0D0D),
    type: BottomNavigationBarType.fixed,
    selectedItemColor: InstagramoColors.primaryDark,
    unselectedItemColor: Colors.white54,
    elevation: 8,
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1C1B1F),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2B2930),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: InstagramoColors.primaryDark, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: InstagramoColors.primaryDark,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: InstagramoColors.primaryDark,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF2B2930),
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: InstagramoColors.primaryDark,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: const Color(0xFF1C1B1F),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Color(0xFF0D0D0D),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2B2930),
    thickness: 0.5,
    space: 0,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white54,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.white54,
      height: 1.2,
    ),
  ),
);

/// Theme extension for gradient backgrounds
extension InstagramoThemeExtension on ThemeData {
  LinearGradient get brandGradient => LinearGradient(
        colors: brightness == Brightness.dark
            ? InstagramoColors.darkGradient
            : InstagramoColors.brandGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Color get surfaceElevated => brightness == Brightness.dark
      ? const Color(0xFF1C1B1F)
      : const Color(0xFFF3EDF7);
}
