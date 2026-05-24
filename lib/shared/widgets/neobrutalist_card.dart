import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeobrutalistCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeobrutalistCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.borderColor = AppColors.black,
    this.shadowColor = AppColors.black,
    this.borderWidth = 3.0,
    this.shadowOffset = 4.0,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
