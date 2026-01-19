import 'package:flutter/material.dart';

/// 颜色工具类
class ColorUtils {
  ColorUtils._();

  /// 将 Color 转换为十六进制字符串
  /// @param color Flutter Color
  /// @param includeAlpha 是否包含透明度
  static String colorToHex(Color color, {bool includeAlpha = false}) {
    final hex = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return includeAlpha ? '#$hex' : '#${hex.substring(2)}';
  }

  /// 将十六进制字符串转换为 Color
  /// @param hex 十六进制颜色字符串 (支持 #RGB, #RRGGBB, #AARRGGBB)
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '').toUpperCase();
    
    if (hex.length == 3) {
      // #RGB -> #RRGGBB
      hex = hex.split('').map((c) => '$c$c').join();
    }
    
    if (hex.length == 6) {
      hex = 'FF$hex'; // 添加透明度
    }
    
    return Color(int.parse(hex, radix: 16));
  }

  /// 将 Color 转换为 RGB 数组
  static List<int> colorToRgb(Color color) {
    return [color.red, color.green, color.blue];
  }

  /// 将 RGB 数组转换为 Color
  static Color rgbToColor(List<int> rgb) {
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  /// 将 Color 转换为 HSL
  static HSLColor colorToHsl(Color color) {
    return HSLColor.fromColor(color);
  }

  /// 将 HSL 转换为 Color
  static Color hslToColor(double hue, double saturation, double lightness) {
    return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
  }

  /// 计算颜色的亮度 (0-1)
  static double getLuminance(Color color) {
    return color.computeLuminance();
  }

  /// 判断颜色是否较暗 (用于选择文字颜色)
  static bool isDark(Color color) {
    return getLuminance(color) < 0.5;
  }

  /// 获取对比色 (黑色或白色)
  static Color getContrastColor(Color background) {
    return isDark(background) ? Colors.white : Colors.black;
  }

  /// 混合两个颜色
  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }

  /// 调整颜色亮度
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  /// 调整颜色饱和度
  static Color adjustSaturation(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation * factor).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }
}
