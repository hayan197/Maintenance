import 'package:flutter/material.dart';

/// نفس لوحة الألوان المستخدمة في نسخة الويب من لوحة العميل،
/// حتى تكون الهوية البصرية موحدة بين الويب والتطبيق.
class AppColors {
  static const primary = Color(0xFF2F6FED);
  static const primarySoft = Color(0xFFE9F1FF);
  static const success = Color(0xFF1F9D61);
  static const successSoft = Color(0xFFEAFAF2);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFF4DC);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const background = Color(0xFFF4F7FB);
  static const muted = Color(0xFF667085);
  static const text = Color(0xFF1F2937);
}

const Map<String, Color> statusColors = {
  'pending': AppColors.warning,
  'assigned': AppColors.primary,
  'in_progress': Color(0xFFB45309),
  'on_hold': Color(0xFF475569),
  'completed': AppColors.success,
  'cancelled': AppColors.danger,
};

const Map<String, Color> statusBackgrounds = {
  'pending': AppColors.warningSoft,
  'assigned': AppColors.primarySoft,
  'in_progress': AppColors.warningSoft,
  'on_hold': Color(0xFFF1F5F9),
  'completed': AppColors.successSoft,
  'cancelled': AppColors.dangerSoft,
};

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Tahoma',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
