import 'dart:ui';
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class DiffuseBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;

  const DiffuseBackground({
    super.key,
    required this.child,
    this.colors = AppColors.diffuseHomeColors,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background color based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Stack(
      children: [
        // 1. Solid Background
        Container(color: bgColor),

        // 2. Diffuse Blobs
        Positioned(
          top: -100,
          left: -100,
          child: _buildBlob(colors[0], 400),
        ),
        Positioned(
          top: 100,
          right: -100,
          child: _buildBlob(colors[1], 300),
        ),
        Positioned(
          bottom: -100,
          left: 100,
          child: _buildBlob(colors[2], 350),
        ),

        // 3. Blur Mesh (Backdrop Filter)
        // Heavily blur the blobs to create diffuse effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 4. Content
        child,
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.6),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
