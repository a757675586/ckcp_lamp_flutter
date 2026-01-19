import 'package:flutter/material.dart';

/// 预设颜色常量
/// 参考 WebOTA 项目的颜色配置
class PresetColors {
  PresetColors._();

  /// 基础预设颜色
  static const List<Color> basicColors = [
    Color(0xFFFF0000), // 红色
    Color(0xFFFF6600), // 橙色
    Color(0xFFFFFF00), // 黄色
    Color(0xFF00FF00), // 绿色
    Color(0xFF00FFFF), // 青色
    Color(0xFF0000FF), // 蓝色
    Color(0xFF6600FF), // 紫色
    Color(0xFFFF00FF), // 品红
    Color(0xFFFFFFFF), // 白色
  ];

  /// 多色主题预设 (参考 WebOTA)
  static const List<MultiColorTheme> multiColorThemes = [
    MultiColorTheme(
      id: 1,
      nameKey: 'preset_lakeside',
      name: '湖滨晴雨',
      colors: [
        Color(0xFFFF0000),
        Color(0xFFFF7F00),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF0000FF),
        Color(0xFF8B00FF)
      ],
    ),
    MultiColorTheme(
      id: 2,
      nameKey: 'preset_lotus',
      name: '曲院风荷',
      colors: [
        Color(0xFF006994),
        Color(0xFF40E0D0),
        Color(0xFF00CED1),
        Color(0xFF20B2AA)
      ],
    ),
    MultiColorTheme(
      id: 3,
      nameKey: 'preset_sunset',
      name: '雷峰夕照',
      colors: [
        Color(0xFFFF4500),
        Color(0xFFFF6347),
        Color(0xFFFF7F50),
        Color(0xFFFFD700)
      ],
    ),
    MultiColorTheme(
      id: 4,
      nameKey: 'preset_moonspring',
      name: '月泉晓彻',
      colors: [
        Color(0xFF228B22),
        Color(0xFF32CD32),
        Color(0xFF00FA9A),
        Color(0xFF98FB98)
      ],
    ),
    MultiColorTheme(
      id: 5,
      nameKey: 'preset_fishpond',
      name: '琼岛春阴',
      colors: [
        Color(0xFF9400D3),
        Color(0xFF8A2BE2),
        Color(0xFF9932CC),
        Color(0xFFBA55D3)
      ],
    ),
    MultiColorTheme(
      id: 6,
      nameKey: 'preset_westlake',
      name: '西山晴雪',
      colors: [
        Color(0xFFFF0000),
        Color(0xFFFF4500),
        Color(0xFFFF6600),
        Color(0xFFFF8C00)
      ],
    ),
    MultiColorTheme(
      id: 7,
      nameKey: 'preset_autumn',
      name: '平湖秋月',
      colors: [
        Color(0xFF87CEEB),
        Color(0xFFADD8E6),
        Color(0xFFB0E0E6),
        Color(0xFFE0FFFF)
      ],
    ),
    MultiColorTheme(
      id: 8,
      nameKey: 'preset_bamboo',
      name: '云栖竹径',
      colors: [
        Color(0xFF191970),
        Color(0xFF000080),
        Color(0xFF4169E1),
        Color(0xFF6495ED)
      ],
    ),
    MultiColorTheme(
      id: 9,
      nameKey: 'preset_lakeglow',
      name: '洞庭秋色',
      colors: [
        Color(0xFFFFB6C1),
        Color(0xFFFFC0CB),
        Color(0xFFFF69B4),
        Color(0xFFFF1493)
      ],
    ),
    MultiColorTheme(
      id: 10,
      nameKey: 'preset_aurora',
      name: '无极渐变',
      colors: [Color(0xFFFFFFFF), Color(0xFF000000)], // 示意色
    ),
    MultiColorTheme(
      id: 11,
      nameKey: 'custom',
      name: '自定义',
      colors: [],
      isCustom: true,
    ),
  ];

  /// 律动模式预设 (参考 WebOTA: 8种模式)
  static const List<RhythmPreset> rhythmPresets = [
    RhythmPreset(id: 1, nameKey: 'mode_1', name: '模式 1', icon: '🎵'),
    RhythmPreset(id: 2, nameKey: 'mode_2', name: '模式 2', icon: '🎶'),
    RhythmPreset(id: 3, nameKey: 'mode_3', name: '模式 3', icon: '🎼'),
    RhythmPreset(id: 4, nameKey: 'mode_4', name: '模式 4', icon: '🎧'),
    RhythmPreset(id: 5, nameKey: 'mode_5', name: '模式 5', icon: '🎤'),
    RhythmPreset(id: 6, nameKey: 'mode_6', name: '模式 6', icon: '🎹'),
    RhythmPreset(id: 7, nameKey: 'mode_7', name: '模式 7', icon: '🎷'),
    RhythmPreset(id: 8, nameKey: 'mode_8', name: '模式 8', icon: '🎸'),
  ];
}

/// 多色主题数据类
class MultiColorTheme {
  final int id;
  final String nameKey;
  final String name;
  final List<Color> colors;
  final bool isCustom;

  const MultiColorTheme({
    required this.id,
    required this.nameKey,
    required this.name,
    required this.colors,
    this.isCustom = false,
  });
}

/// 律动预设数据类
class RhythmPreset {
  final int id;
  final String nameKey;
  final String name;
  final String icon;

  const RhythmPreset({
    required this.id,
    required this.nameKey,
    required this.name,
    required this.icon,
  });
}
