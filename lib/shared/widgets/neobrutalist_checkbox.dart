import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeobrutalistCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeobrutalistCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<NeobrutalistCheckbox> createState() => _NeobrutalistCheckboxState();
}

class _NeobrutalistCheckboxState extends State<NeobrutalistCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSquishing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Checked transition: scale spring 1.1x -> 1.0x
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NeobrutalistCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value && !oldWidget.value) {
      _controller.forward(from: 0.0);
    }
  }

  void _handleTap() async {
    if (_isSquishing) return;
    setState(() {
      _isSquishing = true;
    });
    // Squish animation: 80ms at 0.9x scale
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _isSquishing = false;
      });
      widget.onChanged(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.borderOf(context);
    final bgUnchecked = AppColors.cardOf(context);
    final greenColor = AppColors.accentGreenOf(context);
    final textColor = AppColors.textOf(context);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double currentScale = 1.0;
          if (_isSquishing) {
            currentScale = 0.9;
          } else if (_controller.isAnimating && widget.value) {
            currentScale = _scaleAnimation.value;
          }

          return Transform.scale(
            scale: currentScale,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.value ? greenColor : bgUnchecked,
                border: Border.all(color: borderColor, width: 3),
                borderRadius: BorderRadius.circular(6),
                boxShadow: widget.value
                    ? null
                    : [
                        BoxShadow(
                          color: borderColor,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: widget.value
                  ? Center(
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

