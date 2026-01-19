import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../../core/localization/app_localizations.dart';

class ZoneControlItem extends StatefulWidget {
  final String label;
  final int count;
  final bool direction;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<bool> onDirectionChanged;

  const ZoneControlItem({
    super.key,
    required this.label,
    required this.count,
    required this.direction,
    required this.onCountChanged,
    required this.onDirectionChanged,
  });

  @override
  State<ZoneControlItem> createState() => _ZoneControlItemState();
}

class _ZoneControlItemState extends State<ZoneControlItem> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.count.toString());
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(ZoneControlItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count && !_focusNode.hasFocus) {
      _controller.text = widget.count.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _submitValue();
    }
  }

  void _submitValue() {
    final value = int.tryParse(_controller.text);
    if (value != null) {
      final clamped = value.clamp(1, 255);
      if (clamped != value) {
        _controller.text = clamped.toString();
      }
      if (clamped != widget.count) {
        widget.onCountChanged(clamped);
      }
    } else {
      _controller.text = widget.count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              // Direction Toggle
              InkWell(
                onTap: () => widget.onDirectionChanged(!widget.direction),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.direction
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.direction
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.direction
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        size: 14,
                        color: widget.direction
                            ? AppColors.primary
                            : Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.direction
                            ? i18n.get('forward')
                            : i18n.get('reverse'),
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.direction
                              ? AppColors.primary
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Count Input
          SizedBox(
            height: 36,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                suffixText: i18n.get('led_unit'),
                suffixStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              onSubmitted: (_) => _submitValue(),
            ),
          ),
        ],
      ),
    );
  }
}
