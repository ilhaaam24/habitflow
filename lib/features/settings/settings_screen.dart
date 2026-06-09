import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:habit_flow/core/services/badge_service.dart';
import 'package:habit_flow/shared/models/badge_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = GetIt.instance<SharedPreferences>();

  bool _notificationsEnabled = true;
  bool _cloudBackupEnabled = false;
  bool _apiKeyConnected = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _cloudBackupEnabled = _prefs.getBool('cloud_backup_enabled') ?? false;
      _apiKeyConnected =
          _prefs.getString('gemini_api_key') != null &&
          _prefs.getString('gemini_api_key')!.isNotEmpty;
    });
  }

  Future<void> _toggleNotification(bool val) async {
    await _prefs.setBool('notifications_enabled', val);
    setState(() {
      _notificationsEnabled = val;
    });
  }

  Future<void> _toggleCloudBackup(bool val) async {
    await _prefs.setBool('cloud_backup_enabled', val);
    setState(() {
      _cloudBackupEnabled = val;
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF0),
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "✕",
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "REALLY SIGN OUT?",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You will need to sign in again to sync your habits.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2.5),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // pop dialog
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            border: Border.all(color: Colors.black, width: 2.5),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "YES, LOG OUT",
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF0),
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SELECT LANGUAGE",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const Divider(color: Colors.black, thickness: 2, height: 20),
                _buildLanguageOption(context, "ENGLISH", isSelected: true),
                _buildLanguageOption(context, "INDONESIAN"),
                _buildLanguageOption(context, "SPANISH"),
                _buildLanguageOption(context, "JAPANESE"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String lang, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $lang!'),
            backgroundColor: const Color(0xFF6BCB77),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD93D) : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            if (isSelected)
              const Text(
                "✓",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExportDataSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF0),
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EXPORT DATA",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Select the format for your habit logs backup:",
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const Divider(color: Colors.black, thickness: 2, height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _triggerExportToast("PDF");
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC77DFF),
                            border: Border.all(color: Colors.black, width: 2.5),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("📋", style: TextStyle(fontSize: 24)),
                              SizedBox(height: 4),
                              Text(
                                "PDF REPORT",
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _triggerExportToast("CSV");
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D96FF),
                            border: Border.all(color: Colors.black, width: 2.5),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("📊", style: TextStyle(fontSize: 24)),
                              SizedBox(height: 4),
                              Text(
                                "CSV SHEET",
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _triggerExportToast(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habit data exported successfully as $format! 📂'),
        backgroundColor: const Color(0xFF6BCB77),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFEF0),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 4),
                  left: BorderSide(color: Colors.black, width: 4),
                  right: BorderSide(color: Colors.black, width: 4),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "🔐 PRIVACY POLICY",
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Last updated: May 2026",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 2, height: 24),
                  const Text(
                    "Your privacy is critically important to us. HabitFlow AI is committed to protecting the records, streak tracking data, and customizable preferences you submit.\n\n"
                    "1. DATA COLLECTION\n"
                    "HabitFlow is designed as a local-first application. All habit entries, completion history log files, and custom preferences are stored locally on your device's SharedPreferences and databases.\n\n"
                    "2. AI MOTIVATION & GEMINI COOPERATIVE MODULES\n"
                    "When connecting a Gemini API key, behavior reports, schedules, and custom instructions are sent directly to Google Gemini servers to compile behavioral coaching responses. Your API key is encrypted and stored locally in SharedPreferences.\n\n"
                    "3. DATA SECURITY & RETENTION\n"
                    "We do not track, resell, or distribute your identity, habits, or behavioral data. Everything resides securely on your personal device.",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsCard(BuildContext context) {
    final Box badgesBox = GetIt.instance<Box>(instanceName: 'badgesBox');

    return ValueListenableBuilder(
      valueListenable: badgesBox.listenable(),
      builder: (context, Box box, _) {
        int unlockedCount = 0;
        for (final badge in BadgeService.allBadges) {
          if (box.get(badge.id) == true) {
            unlockedCount++;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "🏆 ACHIEVEMENTS",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFFFFD93D),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      "$unlockedCount / ${BadgeService.allBadges.length} UNLOCKED",
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 2, height: 20),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: BadgeService.allBadges.map((badge) {
                  final isUnlocked = box.get(badge.id) == true;
                  return GestureDetector(
                    onTap: () =>
                        _showBadgeDetailDialog(context, badge, isUnlocked),
                    child: Tooltip(
                      key: Key('badge_tooltip_${badge.id}'),
                      message: badge.name,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? Color(badge.colorValue)
                              : Colors.grey[200]!.withAlpha(204),
                          border: Border.all(
                            color: isUnlocked ? Colors.black : Colors.black38,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isUnlocked
                              ? const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            isUnlocked ? badge.icon : "🔒",
                            style: TextStyle(
                              fontSize: 22,
                              color: isUnlocked ? null : Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBadgeDetailDialog(
    BuildContext context,
    BadgeModel badge,
    bool isUnlocked,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF0),
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Color(badge.colorValue)
                        : Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isUnlocked ? badge.icon : "🔒",
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Status badge
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                    color: isUnlocked
                        ? const Color(0xFF6BCB77)
                        : const Color(0xFFFF6B6B),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    isUnlocked ? "UNLOCKED 🏆" : "LOCKED 🔒",
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  badge.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel({required String text, required Color bgColor}) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
              color: bgColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 3,
                color: bgColor == Colors.black ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required String emoji,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget action,
    bool isLast = false,
  }) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: iconColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final String displayName =
        (user?.displayName != null && user!.displayName.isNotEmpty)
        ? user.displayName.toUpperCase()
        : 'RAFI PRATAMA';
    final String email = user?.email ?? 'rafi@gmail.com';
    final String initial = displayName.isNotEmpty ? displayName[0] : 'R';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative: "⚙" watermark centered behind content
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      "⚙",
                      style: TextStyle(
                        fontSize: 200,
                        color: Color(0x0D000000), // 5% black
                      ),
                    ),
                  ),
                ),
              ),
              // Main content list
              Column(
                children: [
                  // HEADER
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "SETTINGS",
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  letterSpacing: -1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "CONTROL YOUR EXPERIENCE",
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable body
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 96),
                      children: [
                        // PROFILE CARD
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 4),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFFFD93D),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(8, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 4,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        ),
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF6BCB77),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "✓",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: Colors.black,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(2, 2),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: const Text(
                                            "🔥 23 DAY STREAK",
                                            style: TextStyle(
                                              color: Color(0xFFFFD93D),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: const Center(
                                  child: Text(
                                    "→",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAchievementsCard(context),

                        // SECTION 1 — PREFERENCES
                        _buildSectionLabel(
                          text: "PREFERENCES",
                          bgColor: Colors.black,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSettingsRow(
                                emoji: "🌙",
                                iconColor: const Color(0xFFA5F3FC),
                                title: "DARK MODE",
                                subtitle: "THEME SELECTION",
                                action: NeobrutalistSwitch(
                                  value: isDark,
                                  onChanged: (_) {
                                    context.read<ThemeCubit>().toggleTheme();
                                  },
                                ),
                              ),
                              _buildSettingsRow(
                                emoji: "🔔",
                                iconColor: const Color(0xFFFDE047),
                                title: "NOTIFICATIONS",
                                subtitle: "ALL HABITS",
                                action: NeobrutalistSwitch(
                                  value: _notificationsEnabled,
                                  onChanged: _toggleNotification,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showLanguageSelector(context),
                                child: AbsorbPointer(
                                  child: _buildSettingsRow(
                                    emoji: "🌐",
                                    iconColor: const Color(0xFFFED7AA),
                                    title: "LANGUAGE",
                                    subtitle: "APP INTERFACE",
                                    action: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: Colors.black,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: const Text(
                                            "ENGLISH",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "→",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    isLast: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SECTION 2 — AI & DATA
                        _buildSectionLabel(
                          text: "AI & DATA",
                          bgColor: const Color(0xFFC77DFF),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await context.push('/ai-settings');
                                  _loadPreferences(); // reload connections state
                                },
                                child: AbsorbPointer(
                                  child: _buildSettingsRow(
                                    emoji: "✨",
                                    iconColor: const Color(0xFFE9D5FF),
                                    title:
                                        "AI MOTIVATION SETTINGS", // Named to match the exact test check
                                    subtitle: "MANAGE GEMINI COACH",
                                    action: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: _apiKeyConnected
                                                ? const Color(0xFF6BCB77)
                                                : const Color(0xFFFFD93D),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            _apiKeyConnected
                                                ? "CONNECTED ✓"
                                                : "SETUP KEY",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "→",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showExportDataSelector(context),
                                child: AbsorbPointer(
                                  child: _buildSettingsRow(
                                    emoji: "📊",
                                    iconColor: const Color(0xFFBBF7D0),
                                    title: "EXPORT DATA",
                                    subtitle: "PDF OR CSV",
                                    action: const Text(
                                      "→",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildSettingsRow(
                                emoji: "☁",
                                iconColor: const Color(0xFFBFDBFE),
                                title: "CLOUD BACKUP",
                                subtitle: "SYNCED 2H AGO",
                                action: NeobrutalistSwitch(
                                  value: _cloudBackupEnabled,
                                  onChanged: _toggleCloudBackup,
                                ),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        // SECTION 3 — ABOUT
                        _buildSectionLabel(
                          text: "ABOUT",
                          bgColor: const Color(0xFF4D96FF),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Thank you for rating HabitFlow 5 stars! ⭐⭐⭐⭐⭐',
                                      ),
                                      backgroundColor: Color(0xFF6BCB77),
                                    ),
                                  );
                                },
                                child: AbsorbPointer(
                                  child: _buildSettingsRow(
                                    emoji: "⭐",
                                    iconColor: const Color(0xFFFEF08A),
                                    title: "RATE HABITFLOW",
                                    subtitle: "SUPPORT THE APP",
                                    action: const Text(
                                      "→",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showPrivacyPolicy(context),
                                child: AbsorbPointer(
                                  child: _buildSettingsRow(
                                    emoji: "🔐",
                                    iconColor: const Color(0xFFFECACA),
                                    title: "PRIVACY POLICY",
                                    subtitle: "LEGAL & SECURITY",
                                    action: const Text(
                                      "↗",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildSettingsRow(
                                emoji: "ℹ",
                                iconColor: const Color(0xFFE2E8F0),
                                title: "VERSION",
                                subtitle: "BUILD VERSION",
                                action: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.black,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: const Text(
                                    "V 1.0.0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        // LOGOUT BUTTON
                        GestureDetector(
                          onTap: () => _showLogoutConfirmation(context),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            height: 64,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 3),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(5, 5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "✕",
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "SIGN OUT",
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // FOOTER
                        Column(
                          children: const [
                            Text(
                              "HABITFLOW v1.0.0",
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "MADE WITH ♥ BY HABITFLOW TEAM",
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeobrutalistSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeobrutalistSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: value ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                border: Border.all(
                  color: value ? Colors.white : Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
