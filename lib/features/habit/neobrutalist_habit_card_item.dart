import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/neobrutalist_card.dart';
import '../../shared/widgets/neobrutalist_checkbox.dart';

class NeobrutalistHabitCardItem extends StatefulWidget {
  final String id;
  final String title;
  final String emoji;
  final int colorVal;
  final int streak;
  final bool isDone;
  final String category;
  final VoidCallback onToggle;

  const NeobrutalistHabitCardItem({
    super.key,
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorVal,
    required this.streak,
    required this.isDone,
    required this.category,
    required this.onToggle,
  });

  @override
  State<NeobrutalistHabitCardItem> createState() =>
      _NeobrutalistHabitCardItemState();
}

class _NeobrutalistHabitCardItemState extends State<NeobrutalistHabitCardItem>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _borderColorAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isMilestone = false;
  bool _flashSetup = false;

  @override
  void initState() {
    super.initState();
    final s = widget.streak;
    _isMilestone = s == 7 || s == 14 || s == 21 || s == 30;

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Border flash animation colors will be resolved in build
    _borderColorAnimation = const AlwaysStoppedAnimation(null);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    if (_isMilestone) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _slideController.forward();
      });
    }
  }

  void _setupFlashAnimation(Color baseColor, Color flashColor) {
    _borderColorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: baseColor, end: flashColor),
        weight: 16.6,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: flashColor, end: baseColor),
        weight: 16.6,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: baseColor, end: flashColor),
        weight: 16.6,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: flashColor, end: baseColor),
        weight: 16.6,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: baseColor, end: flashColor),
        weight: 16.6,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: flashColor, end: baseColor),
        weight: 16.6,
      ),
    ]).animate(_flashController);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.borderOf(context);
    final textColor = AppColors.textOf(context);
    final cardBg = AppColors.cardOf(context);
    final accentYellow = AppColors.accentYellowOf(context);
    final accentGreen = AppColors.accentGreenOf(context);

    // Setup flash animation once with resolved colors
    if (_isMilestone && !_flashSetup) {
      _setupFlashAnimation(borderColor, accentYellow);
      _flashController.forward();
      _flashSetup = true;
    }

    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        final animBorderColor = _isMilestone
            ? (_borderColorAnimation.value ?? borderColor)
            : borderColor;

        return NeobrutalistCard(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          borderColor: animBorderColor,
          borderWidth: 3,
          onTap: () => context.push('/habit/detail/${widget.id}'),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(widget.colorVal),
                        border: Border.all(color: borderColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                height: 22,
                                decoration: BoxDecoration(
                                  color: accentYellow,
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '🔥 ${widget.streak} DAYS',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 22,
                                decoration: BoxDecoration(
                                  color: widget.isDone
                                      ? accentGreen
                                      : cardBg,
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.isDone
                                      ? 'DONE ✓'
                                      : widget.category.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_isMilestone) ...[
                                const SizedBox(width: 8),
                                ClipRect(
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: Container(
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: borderColor,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '🔥 ${widget.streak} DAYS!',
                                        style: TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          color: accentYellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              NeobrutalistCheckbox(
                value: widget.isDone,
                onChanged: (_) => widget.onToggle(),
              ),
            ],
          ),
        );
      },
    );
  }
}
