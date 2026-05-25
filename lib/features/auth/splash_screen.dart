import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:pattern_box/pattern_box.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.1,
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                border: Border(
                  top: BorderSide(color: AppColors.black, width: 3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.black),
                    child: Center(
                      child: Text(
                        '*',
                        style: TextStyle(color: AppColors.accentYellow),
                      ),
                    ),
                  ),
                  Text(
                    'BUILDING BETTER HABITS SINCE DAY 1',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.black),
                    child: Center(
                      child: Text(
                        '*',
                        style: TextStyle(color: AppColors.accentYellow),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.08,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.black, width: 3),
                ),
              ),
              child: PatternBoxWidget(
                pattern: StripePattern(
                  gap: 20,
                  thickness: 10,
                  color: AppColors.white,
                ),
                backgroundColor: AppColors.black,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -48,
                      right: -80,
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: -56,
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: -56,
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        border: Border.all(width: 4, color: AppColors.black),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black,
                            offset: Offset(8, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 120,
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -16,
                      right: -16,
                      child: Transform.rotate(
                        angle: -16 * 3.14159265359 / 180,
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accentRed,
                            border: Border.all(
                              width: 4,
                              color: AppColors.black,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black,
                                offset: Offset(8, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/flash.svg',
                              alignment: Alignment.center,
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 40),
                Text(
                  'HABIT',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Stack(
                  children: [
                    Text(
                      'FLOW',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        letterSpacing: 2.5,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 8
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      'FLOW',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        letterSpacing: 2.5,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 24),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -24,
                      left: -24,
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        '[ AI POWERED ✦ ]',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          letterSpacing: 3,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 48),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    border: Border.all(color: AppColors.black, width: 3),
                  ),
                ),
                const SizedBox.square(dimension: 12),
                Text(
                  'LOADING YOUR HABITS...',
                  style: TextStyle(
                    color: AppColors.black,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
