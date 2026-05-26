import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeobrutalistCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const NeobrutalistCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.borderColor = AppColors.black,
    this.shadowColor = AppColors.black,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
  });

  @override
  State<NeobrutalistCard> createState() => _NeobrutalistCardState();
}

class _NeobrutalistCardState extends State<NeobrutalistCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;
    final double translation = _isPressed ? 3.0 : 0.0;
    final double currentShadowOffset = _isPressed ? 2.0 : widget.shadowOffset;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      curve: Curves.linear,
      transform: Matrix4.translationValues(translation, translation, 0.0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: widget.borderWidth),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            offset: Offset(currentShadowOffset, currentShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (isInteractive) {
      return Container(
        margin: widget.margin,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: widget.margin,
      child: cardContent,
    );
  }
}
