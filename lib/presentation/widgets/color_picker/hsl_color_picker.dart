import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// HSL 颜色选择器 - 紧凑版
class HslColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color>? onColorChanged;
  final VoidCallback? onColorSelected;

  const HslColorPicker({
    super.key,
    this.initialColor = Colors.red,
    this.onColorChanged,
    this.onColorSelected,
  });

  @override
  State<HslColorPicker> createState() => _HslColorPickerState();
}

class _HslColorPickerState extends State<HslColorPicker> {
  late HSLColor _hslColor;
  Offset? _pickerPosition;

  @override
  void initState() {
    super.initState();
    _hslColor = HSLColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 色相/饱和度选择区域 - 使用固定高度
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              final height = constraints.maxHeight;
              return GestureDetector(
                onPanDown: (details) =>
                    _handleTouch(details.localPosition, size, height),
                onPanUpdate: (details) =>
                    _handleTouch(details.localPosition, size, height),
                onPanEnd: (_) => widget.onColorSelected?.call(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // 色相渐变背景
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF0000), // 红
                              const Color(0xFFFFFF00), // 黄
                              const Color(0xFF00FF00), // 绿
                              const Color(0xFF00FFFF), // 青
                              const Color(0xFF0000FF), // 蓝
                              const Color(0xFFFF00FF), // 品红
                              const Color(0xFFFF0000), // 红
                            ],
                          ),
                        ),
                      ),
                      // 白色到透明渐变（饱和度）
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                      // 透明到黑色渐变（亮度）
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                      // 选择指示器
                      Positioned(
                        left: (_pickerPosition?.dx ?? size / 2) - 10,
                        top: (_pickerPosition?.dy ?? height / 3) - 10,
                        child: _buildIndicator(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // 色相滑块
        _buildHueSlider(),
      ],
    );
  }

  Widget _buildIndicator() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _hslColor.toColor(),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHueSlider() {
    final i18n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              i18n.get('hue'),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              '${_hslColor.hue.toInt()}°',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF0000),
                Color(0xFFFFFF00),
                Color(0xFF00FF00),
                Color(0xFF00FFFF),
                Color(0xFF0000FF),
                Color(0xFFFF00FF),
                Color(0xFFFF0000),
              ],
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 24,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _hslColor.hue / 360,
              onChanged: (value) {
                setState(() {
                  _hslColor = _hslColor.withHue(value * 360);
                });
                widget.onColorChanged?.call(_hslColor.toColor());
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleTouch(Offset position, double width, double height) {
    // 限制在区域内
    final x = position.dx.clamp(0.0, width);
    final y = position.dy.clamp(0.0, height);

    // 计算色相 (横向)
    final hue = (x / width) * 360;
    // 计算饱和度和亮度 (纵向)
    final saturation = 1.0 - (y / height) * 0.5;
    final lightness = 0.5 - (y / height) * 0.3;

    setState(() {
      _pickerPosition = Offset(x, y);
      _hslColor = HSLColor.fromAHSL(
        1,
        hue.clamp(0.0, 360.0),
        saturation.clamp(0.0, 1.0),
        lightness.clamp(0.15, 0.85),
      );
    });

    widget.onColorChanged?.call(_hslColor.toColor());
  }
}

/// 预设颜色网格
class PresetColorGrid extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color>? onColorSelected;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  const PresetColorGrid({
    super.key,
    required this.colors,
    this.selectedColor,
    this.onColorSelected,
    this.showAddButton = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...colors.map((color) => _ColorButton(
              color: color,
              isSelected: color == selectedColor,
              onTap: () => onColorSelected?.call(color),
            )),
        if (showAddButton) _AddColorButton(onTap: onAddPressed),
      ],
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ColorButton({
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isSelected
            ? Container(
                margin: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}

class _AddColorButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddColorButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.add,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 20,
        ),
      ),
    );
  }
}
