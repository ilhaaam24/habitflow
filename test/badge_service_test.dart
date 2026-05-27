import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/core/services/badge_service.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';

class FakeBadgesBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Iterable get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  bool get isOpen => true;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  dynamic getAt(int index) => _data.values.elementAt(index);

  @override
  Future<void> putAt(int index, dynamic value) async {
    _data[_data.keys.elementAt(index)] = value;
  }

  @override
  Future<int> add(dynamic value) async {
    final nextKey = _data.length;
    _data[nextKey] = value;
    return nextKey;
  }

  @override
  Future<Iterable<int>> addAll(Iterable values) async {
    final keys = <int>[];
    for (final val in values) {
      keys.add(await add(val));
    }
    return keys;
  }

  @override
  Future<void> putAll(Map entries) async {
    _data.addAll(entries);
  }

  @override
  Future<void> deleteAt(int index) async {
    _data.remove(_data.keys.elementAt(index));
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final k in keys) {
      _data.remove(k);
    }
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> compact() async {}

  @override
  Future<void> close() async {}

  @override
  String? get path => null;

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  dynamic keyAt(int index) => _data.keys.elementAt(index);

  @override
  Map<dynamic, dynamic> toMap() => Map.unmodifiable(_data);

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);
}

class MockHabitRepository implements HabitRepository {
  final List<HabitModel> habits;
  final Map<String, List<HabitLogModel>> logs;
  final Map<String, int> streaks;

  MockHabitRepository({
    this.habits = const [],
    this.logs = const {},
    this.streaks = const {},
  });

  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => Stream.value(habits);
  @override
  Future<void> logHabit(HabitLogModel log) async {}
  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async {
    final dateLogs = <HabitLogModel>[];
    for (final key in logs.keys) {
      for (final log in logs[key]!) {
        if (log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day) {
          dateLogs.add(log);
        }
      }
    }
    return dateLogs;
  }
  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async => logs[habitId] ?? [];
  @override
  Future<int> calculateStreak(String habitId) async => streaks[habitId] ?? 0;
  @override
  Future<int> getLongestStreak(String habitId) async => streaks[habitId] ?? 0;
}

void main() {
  late FakeBadgesBox badgesBox;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    badgesBox = FakeBadgesBox();
  });

  test('BadgeService checks and unlocks First Flame when a habit is completed', () async {
    final today = DateTime.now();
    final h1 = HabitModel(
      id: 'h1',
      userId: 'u1',
      title: 'Water Intake',
      description: 'hydrate',
      category: 'health',
      icon: '💧',
      colorValue: 0xFF4D96FF,
      reminderTime: '08:00',
      activeDays: const ['mon', 'wed', 'fri'],
      createdAt: today.subtract(const Duration(days: 5)),
    );

    final log1 = HabitLogModel(
      id: 'l1',
      habitId: 'h1',
      date: today.subtract(const Duration(days: 2)),
      isCompleted: true,
    );

    final repo = MockHabitRepository(
      habits: [h1],
      logs: {'h1': [log1]},
    );

    final badgeService = BadgeService(
      badgesBox: badgesBox,
      habitRepository: repo,
      sharedPreferences: prefs,
    );

    expect(badgeService.isUnlocked('first_flame'), false);

    final unlocked = await badgeService.checkAndUnlockBadges('u1');

    expect(unlocked.any((b) => b.id == 'first_flame'), true);
    expect(badgeService.isUnlocked('first_flame'), true);

    // Running again shouldn't flag it as newly unlocked
    final unlockedAgain = await badgeService.checkAndUnlockBadges('u1');
    expect(unlockedAgain.any((b) => b.id == 'first_flame'), false);
  });

  test('BadgeService checks and unlocks streak badges (3-Day, Week Champion, Month Master)', () async {
    final today = DateTime.now();
    final h1 = HabitModel(
      id: 'h1',
      userId: 'u1',
      title: 'Daily Run',
      description: 'run',
      category: 'fitness',
      icon: '🏃',
      colorValue: 0xFFFF6B6B,
      reminderTime: '06:00',
      activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      createdAt: today.subtract(const Duration(days: 40)),
    );

    final repo = MockHabitRepository(
      habits: [h1],
      streaks: {'h1': 8}, // week champion streak
    );

    final badgeService = BadgeService(
      badgesBox: badgesBox,
      habitRepository: repo,
      sharedPreferences: prefs,
    );

    final unlocked = await badgeService.checkAndUnlockBadges('u1');

    // Should unlock 3-day and 7-day, but not 30-day
    expect(unlocked.any((b) => b.id == 'warrior_3'), true);
    expect(unlocked.any((b) => b.id == 'champion_7'), true);
    expect(unlocked.any((b) => b.id == 'master_30'), false);
  });

  test('BadgeService checks and unlocks Perfectionist when all habits are completed on a day', () async {
    final today = DateTime.now();
    final h1 = HabitModel(
      id: 'h1',
      userId: 'u1',
      title: 'Water Intake',
      description: 'hydrate',
      category: 'health',
      icon: '💧',
      colorValue: 0xFF4D96FF,
      reminderTime: '08:00',
      activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      createdAt: today.subtract(const Duration(days: 5)),
    );

    final logToday = HabitLogModel(
      id: 'l1',
      habitId: 'h1',
      date: today,
      isCompleted: true,
    );

    final repo = MockHabitRepository(
      habits: [h1],
      logs: {'h1': [logToday]},
    );

    final badgeService = BadgeService(
      badgesBox: badgesBox,
      habitRepository: repo,
      sharedPreferences: prefs,
    );

    final unlocked = await badgeService.checkAndUnlockBadges('u1');
    expect(unlocked.any((b) => b.id == 'perfectionist'), true);
  });

  test('BadgeService checks and unlocks Multi-Tasker when user has 5+ habits', () async {
    final today = DateTime.now();
    final List<HabitModel> habits = List.generate(5, (index) => HabitModel(
      id: 'h_$index',
      userId: 'u1',
      title: 'Habit $index',
      description: 'desc',
      category: 'cat',
      icon: '🔹',
      colorValue: 0xFFFFFFFF,
      reminderTime: '09:00',
      activeDays: const ['mon'],
      createdAt: today,
    ));

    final repo = MockHabitRepository(habits: habits);

    final badgeService = BadgeService(
      badgesBox: badgesBox,
      habitRepository: repo,
      sharedPreferences: prefs,
    );

    final unlocked = await badgeService.checkAndUnlockBadges('u1');
    expect(unlocked.any((b) => b.id == 'multi_tasker'), true);
  });

  test('BadgeService checks and unlocks AI Explorer when API Key is active in settings', () async {
    final repo = MockHabitRepository();
    final badgeService = BadgeService(
      badgesBox: badgesBox,
      habitRepository: repo,
      sharedPreferences: prefs,
    );

    // Initial check without API key
    var unlocked = await badgeService.checkAndUnlockBadges('u1');
    expect(unlocked.any((b) => b.id == 'ai_explorer'), false);

    // Write API key and verify
    await prefs.setString('gemini_api_key', 'valid_gemini_api_key_123');
    unlocked = await badgeService.checkAndUnlockBadges('u1');
    expect(unlocked.any((b) => b.id == 'ai_explorer'), true);
  });
}
