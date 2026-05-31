import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';

class MockHabitRepository implements HabitRepository {
  final List<HabitModel> habits = [];
  final List<HabitLogModel> logs = [];
  final StreamController<List<HabitModel>> _habitsController = StreamController<List<HabitModel>>.broadcast();

  void triggerHabitsUpdate() {
    if (!_habitsController.isClosed) {
      _habitsController.add(habits);
    }
  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    habits.add(habit);
    triggerHabitsUpdate();
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    habits.removeWhere((h) => h.id == habit.id);
    habits.add(habit);
    triggerHabitsUpdate();
  }

  @override
  Future<void> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);
    logs.removeWhere((l) => l.habitId == id);
    triggerHabitsUpdate();
  }

  @override
  Stream<List<HabitModel>> getHabits(String userId) {
    Timer.run(() => triggerHabitsUpdate());
    return _habitsController.stream;
  }

  @override
  Future<void> logHabit(HabitLogModel log) async {
    logs.removeWhere((l) => l.id == log.id);
    logs.add(log);
  }

  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async {
    return logs.where((l) =>
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day).toList();
  }

  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    return logs.where((l) => l.habitId == habitId).toList();
  }

  @override
  Future<int> calculateStreak(String habitId) async => 0;

  @override
  Future<int> getLongestStreak(String habitId) async => 0;

  void dispose() {
    _habitsController.close();
  }
}

void main() {
  late MockHabitRepository repository;
  late HabitBloc bloc;

  setUp(() {
    repository = MockHabitRepository();
    bloc = HabitBloc(habitRepository: repository);
  });

  tearDown(() {
    bloc.close();
    repository.dispose();
  });

  final testDate = DateTime(2026, 5, 26);
  final testHabit = HabitModel(
    id: 'h1',
    userId: 'u1',
    title: 'Code Dart',
    description: 'Every day',
    category: 'study',
    icon: '💻',
    colorValue: 0xFF00FF00,
    reminderTime: '10:00',
    activeDays: ['mon'],
    createdAt: testDate,
  );

  test('initial state should be HabitInitial', () {
    expect(bloc.state, isA<HabitInitial>());
  });

  test('LoadHabitsRequested emits HabitLoading then HabitLoaded', () async {
    repository.habits.add(testHabit);

    final expectedStates = [
      isA<HabitLoading>(),
      isA<HabitLoaded>().having((s) => s.habits.first.id, 'habitId', 'h1'),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(LoadHabitsRequested(userId: 'u1', date: testDate));
  });

  test('AddHabitRequested adds habit to repository and triggers load emission', () async {
    bloc.add(LoadHabitsRequested(userId: 'u1', date: testDate));

    // Wait for initial load
    await expectLater(
      bloc.stream,
      emitsThrough(isA<HabitLoaded>().having((s) => s.habits, 'habits', isEmpty)),
    );

    // Now add a habit
    final nextStates = [
      isA<HabitLoaded>().having((s) => s.habits.length, 'habits length', 1),
    ];
    expectLater(bloc.stream, emitsInOrder(nextStates));

    bloc.add(AddHabitRequested(testHabit));
  });

  test('ToggleHabitLogRequested toggles habit log and updates state', () async {
    repository.habits.add(testHabit);
    bloc.add(LoadHabitsRequested(userId: 'u1', date: testDate));

    await expectLater(
      bloc.stream,
      emitsThrough(isA<HabitLoaded>().having((s) => s.todayLogs, 'todayLogs', isEmpty)),
    );

    // Toggle once -> Should create log
    expectLater(
      bloc.stream,
      emitsThrough(isA<HabitLoaded>().having((s) => s.todayLogs.length, 'todayLogs length', 1)),
    );

    bloc.add(ToggleHabitLogRequested(habitId: 'h1', date: testDate));
  });

  test('overallStreak is calculated correctly based on completion of all active habits', () async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final weekdayNames = const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayStr = weekdayNames[today.weekday - 1];
    final yesterdayStr = weekdayNames[yesterday.weekday - 1];
    final twoDaysAgoStr = weekdayNames[twoDaysAgo.weekday - 1];

    final h1 = HabitModel(
      id: 'h1',
      userId: 'u1',
      title: 'Habit 1',
      description: 'Daily',
      category: 'health',
      icon: '💧',
      colorValue: 0xFF0000FF,
      reminderTime: '08:00',
      activeDays: [todayStr, yesterdayStr, twoDaysAgoStr],
      createdAt: twoDaysAgo,
    );

    final h2 = HabitModel(
      id: 'h2',
      userId: 'u1',
      title: 'Habit 2',
      description: 'Daily',
      category: 'health',
      icon: '🏃',
      colorValue: 0xFFFF0000,
      reminderTime: '09:00',
      activeDays: [todayStr, yesterdayStr, twoDaysAgoStr],
      createdAt: twoDaysAgo,
    );

    repository.habits.addAll([h1, h2]);

    // 1. Logs for two days ago (both completed)
    repository.logs.addAll([
      HabitLogModel(id: 'l1', habitId: 'h1', date: twoDaysAgo, isCompleted: true),
      HabitLogModel(id: 'l2', habitId: 'h2', date: twoDaysAgo, isCompleted: true),
    ]);

    // 2. Logs for yesterday (both completed)
    repository.logs.addAll([
      HabitLogModel(id: 'l3', habitId: 'h1', date: yesterday, isCompleted: true),
      HabitLogModel(id: 'l4', habitId: 'h2', date: yesterday, isCompleted: true),
    ]);

    // Today is not completed yet, so the streak should be 2
    bloc.add(LoadHabitsRequested(userId: 'u1', date: today));

    await expectLater(
      bloc.stream,
      emitsThrough(isA<HabitLoaded>().having((s) => s.overallStreak, 'overallStreak (today incomplete)', 2)),
    );

    // 3. Now complete both for today
    repository.logs.addAll([
      HabitLogModel(id: 'l5', habitId: 'h1', date: today, isCompleted: true),
      HabitLogModel(id: 'l6', habitId: 'h2', date: today, isCompleted: true),
    ]);

    // Trigger reload/update by adding/toggling a log
    bloc.add(LoadHabitsRequested(userId: 'u1', date: today));

    await expectLater(
      bloc.stream,
      emitsThrough(isA<HabitLoaded>().having((s) => s.overallStreak, 'overallStreak (today complete)', 3)),
    );
  });
}
