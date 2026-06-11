import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeobrutalistButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeobrutalistButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  State<NeobrutalistButton> createState() => _NeobrutalistButtonState();
}

class _NeobrutalistButtonState extends State<NeobrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentOffset = _isPressed ? 0.0 : widget.shadowOffset;
    final double translation = _isPressed ? widget.shadowOffset : 0.0;

    final resolvedColor = widget.color ?? AppColors.accentYellowOf(context);
    final resolvedBorderColor = widget.borderColor ?? AppColors.borderOf(context);
    final resolvedShadowColor = widget.shadowColor ?? AppColors.shadowOf(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
        transform: Matrix4.translationValues(translation, translation, 0.0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.onTap == null ? disabledColor : resolvedColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: resolvedBorderColor,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: resolvedShadowColor,
              offset: Offset(currentOffset, currentOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

