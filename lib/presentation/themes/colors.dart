import 'package:flutter/material.dart';

/// 应用颜色系统
/// 参考 WebOTA 项目的设计风格
class AppColors {
  AppColors._();

  // ========== 主色调 (Shared) ==========
  static const Color primary = Color(0xFF2196F3); // Blue 500
  static const Color primaryLight = Color(0xFF64B5F6); // Blue 300
  static const Color primaryDark = Color(0xFF1976D2); // Blue 700

  static const Color secondary = Color(0xFF03A9F4); // Light Blue
  static const Color accent = Color(0xFF00BCD4); // Cyan

  // ========== Dark Mode Colors ==========
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color bgDarker = Color(0xFF020617); // Slate 950
  static const Color bgCardDark = Color(0xFF1E293B); // Slate 800
  static const Color glassBorderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // ========== Light Mode Colors ==========
  static const Color bgLight = Color(0xFFF1F5F9); // Slate 100
  static const Color bgLighter = Color(0xFFF8FAFC); // Slate 50
  static const Color bgCardLight = Color(0xFFFFFFFF); // White
  static const Color glassBorderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // ========== Status Colors (Shared) ==========
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // ========== Glass Effect ==========
  static const Color glassBackgroundDark = Color(0xCC1E293B); // 80% Slate 800
  static const Color glassBackgroundLight = Color(0xCCFFFFFF); // 80% White

  // High quality glass borders
  static const Color glassBorderWhite20 = Color(0x33FFFFFF);
  static const Color glassBorderWhite10 = Color(0x1AFFFFFF);
  static const Color glassBorderWhite5 = Color(0x0DFFFFFF);

  // ========== Diffuse Blob Colors (Neon/Cyberpunk) ==========
  static const List<Color> diffuseAuthColors = [
    Color(0xFF4F46E5), // Indigo 600
    Color(0xFF7C3AED), // Violet 600
    Color(0xFFDB2777), // Pink 600
  ];

  static const List<Color> diffuseHomeColors = [
    Color(0xFF3B82F6), // Blue 500
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFF8B5CF6), // Violet 500
  ];

  // ========== Gradients ==========
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== 颜色选择器预设 ==========
  static const List<Color> presetColors = [
    Color(0xFFFF0000), // 红
    Color(0xFFFF6600), // 橙
    Color(0xFFFFFF00), // 黄
    Color(0xFF00FF00), // 绿
    Color(0xFF00FFFF), // 青
    Color(0xFF0000FF), // 蓝
    Color(0xFF6600FF), // 紫
    Color(0xFFFF00FF), // 品红
    Color(0xFFFFFFFF), // 白
  ];
}
