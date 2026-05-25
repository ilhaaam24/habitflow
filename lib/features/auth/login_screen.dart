import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_flow/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  final double _scrollSpeed = 1.0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients && !_isUserInteracting) {
        _scrollController.jumpTo(_scrollController.offset + _scrollSpeed);

        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200) {
          _scrollController.jumpTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // bottom section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.12,
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.black, width: 3),
                ),
              ),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Text(
                    'BY CONTINUING YOU AGREE TO OUR TERMS & PRIVACY POLICY',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          border: Border.all(color: AppColors.black, width: 2),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          border: Border.all(color: AppColors.black, width: 2),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black, width: 2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.08,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                border: Border(
                  bottom: BorderSide(color: AppColors.black, width: 3),
                ),
              ),

              child: GestureDetector(
                onPanDown: (_) {
                  _isUserInteracting = true;
                },
                onPanCancel: () {
                  _isUserInteracting = false;
                  _startAutoScroll();
                },
                onPanEnd: (_) {
                  _isUserInteracting = false;
                  _startAutoScroll();
                },

                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        '✦ HABITFLOW',
                        style: TextStyle(
                          letterSpacing: 1.6,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                    );
                  },
                ),
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
                      height: 80,
                      width: 80,
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
                            fontSize: 40,
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 32),
                Text(
                  'WELCOME \nBACK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                const SizedBox.square(dimension: 8),

                // divider
                Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(color: AppColors.black),
                ),

                const SizedBox.square(dimension: 8),

                Text(
                  'Sign in to continue your habit journey →',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox.square(dimension: 40),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 3, color: AppColors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    spacing: 16,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: AppColors.black),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/google.svg',
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SIGN IN WITH GOOGLE',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'Quick, free, no password needed',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: AppColors.darkCard,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: AppColors.black),
                          color: AppColors.accentYellow,
                        ),
                        child: Center(
                          child: Text(
                            '\u2192',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox.square(dimension: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 3, color: AppColors.black),
                      ),

                      SizedBox(width: 16),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(width: 3, color: AppColors.black),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'OR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: Container(height: 3, color: AppColors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox.square(dimension: 32),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    border: Border.all(width: 3, color: AppColors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    spacing: 16,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/info.svg',
                        height: 24,
                        width: 24,
                      ),
                      Expanded(
                        child: Text(
                          'No account? No problem. Signing in automatically creates your account.',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
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
