import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  /// 获取主字体样式 (Noto Sans SC - 中英文支持)
  static TextStyle _baseTextStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.notoSansSc(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: GoogleFonts.notoSansSc().fontFamily,

      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCardDark,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _baseTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.bgCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorderDark),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _baseTextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: AppColors.glassBorderDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _baseTextStyle(fontWeight: FontWeight.w500),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: _baseTextStyle(color: AppColors.textMutedDark),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textMutedDark),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.bgDarker),
        trackOutlineColor: WidgetStateProperty.all(AppColors.glassBorderDark),
      ),

      // Texts
      textTheme: TextTheme(
        displayLarge: _baseTextStyle(color: AppColors.textPrimaryDark),
        displayMedium: _baseTextStyle(color: AppColors.textPrimaryDark),
        titleLarge: _baseTextStyle(color: AppColors.textPrimaryDark),
        titleMedium: _baseTextStyle(
            color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: _baseTextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: _baseTextStyle(color: AppColors.textSecondaryDark),
        bodySmall: _baseTextStyle(color: AppColors.textMutedDark),
        labelLarge: _baseTextStyle(
            color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorderDark,
        thickness: 1,
      ),
    );
  }

  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: GoogleFonts.notoSansSc().fontFamily,

      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCardLight,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _baseTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.bgCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorderLight),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _baseTextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          side: const BorderSide(color: AppColors.glassBorderLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _baseTextStyle(fontWeight: FontWeight.w500),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: _baseTextStyle(color: AppColors.textMutedLight),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textMutedLight),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.bgLighter),
        trackOutlineColor: WidgetStateProperty.all(AppColors.glassBorderLight),
      ),

      // Texts
      textTheme: TextTheme(
        displayLarge: _baseTextStyle(color: AppColors.textPrimaryLight),
        displayMedium: _baseTextStyle(color: AppColors.textPrimaryLight),
        titleLarge: _baseTextStyle(color: AppColors.textPrimaryLight),
        titleMedium: _baseTextStyle(
            color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: _baseTextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: _baseTextStyle(color: AppColors.textSecondaryLight),
        bodySmall: _baseTextStyle(color: AppColors.textMutedLight),
        labelLarge: _baseTextStyle(
            color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorderLight,
        thickness: 1,
      ),
    );
  }
}
