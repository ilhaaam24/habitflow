import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/badge_model.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';

class BadgeService {
  final Box badgesBox;
  final HabitRepository habitRepository;
  final SharedPreferences sharedPreferences;

  BadgeService({
    required this.badgesBox,
    required this.habitRepository,
    required this.sharedPreferences,
  });

  static const List<BadgeModel> allBadges = [
    BadgeModel(
      id: 'first_flame',
      name: 'First Flame',
      description: 'Complete habit pertama kali',
      icon: '🔥',
      colorValue: 0xFFFFD93D, // Yellow
    ),
    BadgeModel(
      id: 'warrior_3',
      name: '3-Day Warrior',
      description: 'Streak 3 hari',
      icon: '⚡',
      colorValue: 0xFF6BCB77, // Green
    ),
    BadgeModel(
      id: 'champion_7',
      name: 'Week Champion',
      description: 'Streak 7 hari',
      icon: '🏆',
      colorValue: 0xFFC77DFF, // Purple
    ),
    BadgeModel(
      id: 'master_30',
      name: 'Month Master',
      description: 'Streak 30 hari',
      icon: '💎',
      colorValue: 0xFF4D96FF, // Blue
    ),
    BadgeModel(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Complete semua habit 1 hari penuh',
      icon: '🎯',
      colorValue: 0xFFFF6B6B, // Red
    ),
    BadgeModel(
      id: 'multi_tasker',
      name: 'Multi-Tasker',
      description: 'Punya 5+ habit aktif',
      icon: '🌟',
      colorValue: 0xFFFF9F43, // Orange
    ),
    BadgeModel(
      id: 'ai_explorer',
      name: 'AI Explorer',
      description: 'Setup AI pertama kali',
      icon: '🚀',
      colorValue: 0xFF1DD1A1, // Teal
    ),
  ];

  bool isUnlocked(String badgeId) {
    return badgesBox.get(badgeId) == true;
  }

  Future<List<BadgeModel>> checkAndUnlockBadges(String userId) async {
    final newlyUnlocked = <BadgeModel>[];

    try {
      // 1. Fetch all active habits
      final habits = await habitRepository.getHabits(userId).first;

      // 🔥 "First Flame": Complete habit pertama kali
      if (!isUnlocked('first_flame')) {
        bool hasAnyCompletion = false;
        for (final habit in habits) {
          final logs = await habitRepository.getLogsForHabit(habit.id);
          if (logs.any((l) => l.isCompleted)) {
            hasAnyCompletion = true;
            break;
          }
        }
        if (hasAnyCompletion) {
          await _unlock('first_flame', newlyUnlocked);
        }
      }

      // Streaks checks
      int maxStreak = 0;
      for (final habit in habits) {
        final streak = await habitRepository.getLongestStreak(habit.id);
        if (streak > maxStreak) {
          maxStreak = streak;
        }
      }

      // ⚡ "3-Day Warrior": Streak 3 hari
      if (!isUnlocked('warrior_3') && maxStreak >= 3) {
        await _unlock('warrior_3', newlyUnlocked);
      }

      // 🏆 "Week Champion": Streak 7 hari
      if (!isUnlocked('champion_7') && maxStreak >= 7) {
        await _unlock('champion_7', newlyUnlocked);
      }

      // 💎 "Month Master": Streak 30 hari
      if (!isUnlocked('master_30') && maxStreak >= 30) {
        await _unlock('master_30', newlyUnlocked);
      }

      // 🎯 "Perfectionist": Complete semua habit 1 hari penuh
      if (!isUnlocked('perfectionist')) {
        bool hasPerfectionistDay = false;
        final today = _stripTime(DateTime.now());

        // Scan past 30 days
        for (int i = 0; i < 30; i++) {
          final date = today.subtract(Duration(days: i));
          final weekdayStr = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][date.weekday - 1];

          final scheduled = habits.where((h) {
            final createdStripped = _stripTime(h.createdAt);
            final isCreated = createdStripped.isBefore(date) || createdStripped.isAtSameMomentAs(date);
            return isCreated && h.activeDays.contains(weekdayStr);
          }).toList();

          if (scheduled.isNotEmpty) {
            final dateLogs = await habitRepository.getLogsForDate(userId, date);
            final completedIds = dateLogs.where((l) => l.isCompleted).map((l) => l.habitId).toSet();
            if (scheduled.every((h) => completedIds.contains(h.id))) {
              hasPerfectionistDay = true;
              break;
            }
          }
        }

        if (hasPerfectionistDay) {
          await _unlock('perfectionist', newlyUnlocked);
        }
      }

      // 🌟 "Multi-Tasker": Punya 5+ habit aktif
      if (!isUnlocked('multi_tasker') && habits.length >= 5) {
        await _unlock('multi_tasker', newlyUnlocked);
      }

      // 🚀 "AI Explorer": Setup AI pertama kali
      if (!isUnlocked('ai_explorer')) {
        final key = sharedPreferences.getString('gemini_api_key');
        if (key != null && key.isNotEmpty) {
          await _unlock('ai_explorer', newlyUnlocked);
        }
      }
    } catch (_) {
      // Absorb calculation exceptions gracefully
    }

    return newlyUnlocked;
  }

  Future<void> _unlock(String badgeId, List<BadgeModel> newlyUnlocked) async {
    await badgesBox.put(badgeId, true);
    final badge = allBadges.firstWhere((b) => b.id == badgeId);
    newlyUnlocked.add(badge);
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
