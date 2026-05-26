import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/shared/widgets/neobrutalist_button.dart';

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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: Border.all(color: AppColors.black, width: 2),
              content: Text(
                state.message.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.black, width: 3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
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
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow,
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
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
                  decoration: const BoxDecoration(
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
                        return const Center(
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
                        const Positioned(
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
                        const Positioned(
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
                        const Positioned(
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
                            border: Border.all(
                              width: 4,
                              color: AppColors.black,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.black,
                                offset: Offset(8, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
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
                    const Text(
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
                      decoration: const BoxDecoration(color: AppColors.black),
                    ),

                    const SizedBox.square(dimension: 8),

                    const Text(
                      'Sign in to continue your habit journey →',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox.square(dimension: 40),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: NeobrutalistButton(
                        color: Colors.white,
                        borderRadius: 0,
                        borderWidth: 3,
                        shadowOffset: 6,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        onTap: isLoading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                  GoogleSignInRequested(),
                                );
                              },
                        child: Row(
                          spacing: 16,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: AppColors.black,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                            const Expanded(
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
                                border: Border.all(
                                  width: 2,
                                  color: AppColors.black,
                                ),
                                color: AppColors.accentYellow,
                              ),
                              child: const Center(
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
                    ),

                    const SizedBox.square(dimension: 32),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(height: 3, color: AppColors.black),
                          ),

                          const SizedBox(width: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(
                                width: 3,
                                color: AppColors.black,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
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

                          const SizedBox(width: 16),

                          Expanded(
                            child: Container(height: 3, color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox.square(dimension: 32),

                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        border: Border.all(width: 3, color: AppColors.black),
                        boxShadow: const [
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
                          const Expanded(
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

              // Full-screen loading overlay
              if (isLoading)
                Container(
                  color: const Color(
                    0x66000000,
                  ), // semi-transparent black overlay
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        border: Border.all(color: AppColors.black, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.black,
                            offset: Offset(8, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.black,
                            ),
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'AUTHENTICATING...',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
