import 'dart:ui';
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// 毛玻璃卡片组件
/// 参考 WebOTA 项目的 card-glass 样式
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double blur;
  final VoidCallback? onTap;
  final Widget? header;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.blur = 10,
    this.onTap,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color:
                backgroundColor ?? Theme.of(context).cardColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header!,
              Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// 卡片头部组件
class GlassCardHeader extends StatelessWidget {
  final String title;
  final String? icon;
  final Widget? trailing;

  const GlassCardHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
