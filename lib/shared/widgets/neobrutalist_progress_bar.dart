import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeobrutalistProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final bool showLoadingText;
  final Color? fillColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const NeobrutalistProgressBar({
    super.key,
    required this.value,
    this.height = 16.0,
    this.showLoadingText = false,
    this.fillColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  State<NeobrutalistProgressBar> createState() => _NeobrutalistProgressBarState();
}

class _NeobrutalistProgressBarState extends State<NeobrutalistProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _prevTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _prevTarget = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant NeobrutalistProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _prevTarget) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );
      _prevTarget = widget.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedFillColor = widget.fillColor ?? AppColors.borderOf(context);
    final resolvedBgColor = widget.backgroundColor ?? AppColors.cardOf(context);
    final resolvedBorderColor = widget.borderColor ?? AppColors.borderOf(context);
    final textColor = AppColors.textOf(context);
    final invertedTextColor = AppColors.cardOf(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: resolvedBgColor,
        border: Border.all(color: resolvedBorderColor, width: widget.borderWidth),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = _animation.value;
          final isAnimating = _controller.isAnimating;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                heightFactor: 1.0,
                child: Container(
                  color: resolvedFillColor,
                ),
              ),
              if (widget.showLoadingText && isAnimating)
                Center(
                  child: Text(
                    "LOADING...",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      fontSize: widget.height * 0.6,
                      color: progress > 0.5 ? invertedTextColor : textColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

