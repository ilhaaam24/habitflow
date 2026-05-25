import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/core/di/injection.dart';
import 'package:habit_flow/shared/widgets/neobrutalist_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('is_onboarded', true);
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildIllustrationCard(int index) {
    if (index == 0) {
      return Container(
        height: MediaQuery.sizeOf(context).height * 0.32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.accentYellow,
          border: Border.all(width: 4, color: AppColors.black),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SvgPicture.asset(
              'assets/icons/onboarding_1.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    } else if (index == 1) {
      return // Illustration Card
      Container(
        height: MediaQuery.sizeOf(context).height * 0.32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.accentRed,
          border: Border.all(width: 4, color: AppColors.black),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),

        child: PatternBoxWidget(
          pattern: StripePattern(
            gap: 8,
            thickness: 0.5,
            color: AppColors.darkText,
          ),
          backgroundColor: AppColors.accentRed,
          child: Stack(
            children: [
              Positioned(
                top: 24,
                right: 40,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: AppColors.white,

                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      '7',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/fire.json',
                      height: MediaQuery.sizeOf(context).height * 0.15,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox.square(dimension: 16),
                    SvgPicture.asset(
                      'assets/icons/onboarding_3.svg',
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.32,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              border: Border.all(width: 4, color: AppColors.black),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),

            child: PatternBoxWidget(
              pattern: StripePattern(
                gap: 8,
                thickness: 0.5,
                color: AppColors.darkText,
              ),
              backgroundColor: AppColors.accentPurple,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  // child: SvgPicture.asset(
                  //   'assets/icons/onboarding_2.svg',
                  //   fit: BoxFit.contain,
                  // ),
                  child: Image.asset('assets/icons/onboarding_2.png'),
                ),
              ),
            ),
          ),
          Positioned(
            top: 88,
            left: 40,
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 56,
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ),
          Positioned(
            top: 56,
            right: 80,
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTextContent(int index) {
    if (index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRACK YOUR',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 2,
                left: -2,
                right: -2,
                top: 14,
                child: Container(color: AppColors.accentYellow),
              ),
              const Text(
                'HABITS.',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Build unstoppable routines with AI-driven insights. Discipline isn't easy, but HabitFlow makes it visible. Radical progress starts with a single checkmark.",
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "DON'T\nBREAK THE",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: SvgPicture.asset('assets/icons/wave.svg', height: 20),
              ),
              const Text(
                'CHAIN.',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Habit formation is a game of momentum. Every day you show up is a link in your chain. Missing one day is a mistake; missing two is the start of a new habit.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'YOUR AI COACH.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ALWAYS ON.',
            style: TextStyle(
              color: AppColors.black,
              fontFamily: 'Syne',
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Connect your Gemini keys to unlock real-time behavioral insights. HabitFlow doesn't just track—it evolves with your unique discipline patterns.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStepLabel(int index) {
    final String text = '0${index + 1} / 03';
    final Color color = index == 0
        ? AppColors.accentYellow
        : index == 1
        ? AppColors.accentRed
        : AppColors.accentPurple;
    final Color textColor = index == 0 ? AppColors.black : AppColors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(width: 2, color: AppColors.black),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _currentPage == 0
        ? AppColors.accentYellow
        : _currentPage == 1
        ? AppColors.accentRed
        : AppColors.accentPurple;

    final btnTextColor = _currentPage == 0 ? AppColors.black : AppColors.white;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.black, width: 3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HABITFLOW',
                    style: TextStyle(
                      color: AppColors.black,
                      fontFamily: 'Syne',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _completeOnboarding(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.black,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'SKIP →',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: 3,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: index == 0
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          // Page Indicator Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (dotIndex) {
                              final isCurrent = index == dotIndex;
                              final dotColor = isCurrent
                                  ? AppColors.accentYellow
                                  : AppColors.white;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 8,
                                width: isCurrent ? 64.0 : 32.0,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  border: Border.all(
                                    color: AppColors.black,
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),

                          // Illustration Card Entry Animation
                          TweenAnimationBuilder<double>(
                            key: ValueKey('illustration_$index'),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (value * 0.2),
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildIllustrationCard(index),
                          ),
                          const SizedBox(height: 32),

                          // Step Label Badge
                          _buildStepLabel(index),
                          const SizedBox(height: 16),

                          // Text Content Entry Animation
                          TweenAnimationBuilder<double>(
                            key: ValueKey('text_$index'),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 24 * (1 - value)),
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildTextContent(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Next/GetStarted Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: NeobrutalistButton(
                  color: themeColor,
                  borderRadius: 0,
                  borderWidth: 3,
                  shadowOffset: 5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  onTap: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentPage == 2 ? 'GET STARTED' : 'NEXT',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: btnTextColor,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: btnTextColor, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
