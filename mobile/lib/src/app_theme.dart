import 'package:flutter/material.dart';

abstract final class AppColors {
  static const cyan = Color(0xFF009CDB);
  static const cyanDeep = Color(0xFF007EAF);
  static const navy = Color(0xFF063C50);
  static const lime = Color(0xFFA9CA20);
  static const limePale = Color(0xFFEEF6D1);
  static const grey = Color(0xFFA7A9AC);
  static const canvas = Color(0xFFEDF8FB);
  static const ink = Color(0xFF1C2C33);
  static const muted = Color(0xFF63757B);
  static const line = Color(0xFFD4E2E6);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.cyanDeep,
    brightness: Brightness.light,
    primary: AppColors.cyanDeep,
    secondary: AppColors.lime,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.navy,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
