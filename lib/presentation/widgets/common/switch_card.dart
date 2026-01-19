import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// 开关卡片组件
/// 参考 WebOTA 项目的 switch-card 样式
class SwitchCard extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? icon;

  const SwitchCard({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// 分段选择器
/// 参考 WebOTA 项目的 switch-group 样式
class SegmentedSelector<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T selectedValue;
  final ValueChanged<T>? onChanged;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged?.call(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SegmentedOption<T> {
  final T value;
  final String label;

  const SegmentedOption({
    required this.value,
    required this.label,
  });
}
