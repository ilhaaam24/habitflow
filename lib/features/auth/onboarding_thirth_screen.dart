import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/core/di/injection.dart';
import 'package:habit_flow/shared/widgets/neobrutalist_button.dart';

class OnboardingThirthScreen extends StatelessWidget {
  const OnboardingThirthScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('is_onboarded', true);
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // Scrollable Main Content Section
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Page Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 8,
                            width: 64,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Illustration Card
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
                              child: SvgPicture.asset(
                                'assets/icons/onboarding_2.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Step Label Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple,
                          border: Border.all(width: 2, color: AppColors.black),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Text(
                          '03 / 03',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Text
                      const Text(
                        'YOUR AI\nCOACH.\nALWAYS ON.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description Text
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
                  ),
                ),
              ),
            ),

            // Bottom Next Button Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: NeobrutalistButton(
                color: AppColors.accentPurple,
                borderRadius: 0,
                borderWidth: 3,
                shadowOffset: 5,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                onTap: () => _completeOnboarding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: AppColors.white,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.white, size: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
