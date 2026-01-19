import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// 滑块控制组件
/// 参考 WebOTA 项目的亮度滑块样式
class SliderControl extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String? suffix;
  final bool showValue;

  const SliderControl({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 10,
    this.divisions,
    this.onChanged,
    this.suffix,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (showValue)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suffix != null
                      ? '${value.toInt()}$suffix'
                      : '${value.toInt()}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Theme.of(context).cardColor,
            thumbColor: AppColors.primaryLight,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions ?? (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// 区域亮度控制组件
class ZoneBrightnessControl extends StatelessWidget {
  final String zoneName;
  final double value;
  final ValueChanged<double>? onChanged;
  final String? icon;

  const ZoneBrightnessControl({
    super.key,
    required this.zoneName,
    required this.value,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
              ],
              Text(
                zoneName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.bgDarker
                      : Colors.grey[200],
            ),
            child: Slider(
              value: value.clamp(0, 10),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
