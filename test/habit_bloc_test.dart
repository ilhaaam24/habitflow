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
}
