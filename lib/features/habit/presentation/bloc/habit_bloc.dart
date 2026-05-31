import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _habitRepository;
  StreamSubscription<List<HabitModel>>? _habitsSubscription;

  String? _userId;
  DateTime? _selectedDate;
  List<HabitModel> _currentHabits = [];

  HabitBloc({required HabitRepository habitRepository})
    : _habitRepository = habitRepository,
      super(HabitInitial()) {
    on<LoadHabitsRequested>(_onLoadHabitsRequested);
    on<HabitsUpdated>(_onHabitsUpdated);
    on<AddHabitRequested>(_onAddHabitRequested);
    on<UpdateHabitRequested>(_onUpdateHabitRequested);
    on<DeleteHabitRequested>(_onDeleteHabitRequested);
    on<ToggleHabitLogRequested>(_onToggleHabitLogRequested);
  }

  Future<void> _onLoadHabitsRequested(
    LoadHabitsRequested event,
    Emitter<HabitState> emit,
  ) async {
    _userId = event.userId;
    _selectedDate = event.date;

    emit(HabitLoading());

    _habitsSubscription?.cancel();
    _habitsSubscription = _habitRepository.getHabits(event.userId).listen((
      habits,
    ) {
      add(HabitsUpdated(habits));
    });
  }

  Future<void> _onHabitsUpdated(
    HabitsUpdated event,
    Emitter<HabitState> emit,
  ) async {
    _currentHabits = event.habits;

    try {
      if (sl.isRegistered<NotificationService>()) {
        sl<NotificationService>().rescheduleAll(event.habits);
      }
    } catch (_) {}

    if (_userId == null || _selectedDate == null) return;

    try {
      final logs = await _habitRepository.getLogsForDate(
        _userId!,
        _selectedDate!,
      );
      final streaks = <String, int>{};
      for (final habit in _currentHabits) {
        streaks[habit.id] = await _habitRepository.calculateStreak(habit.id);
      }
      final overallStreak = await _calculateOverallStreak(_currentHabits);
      emit(
        HabitLoaded(
          habits: _currentHabits,
          todayLogs: logs,
          selectedDate: _selectedDate!,
          streaks: streaks,
          overallStreak: overallStreak,
        ),
      );
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onAddHabitRequested(
    AddHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitRepository.addHabit(event.habit);
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onUpdateHabitRequested(
    UpdateHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitRepository.updateHabit(event.habit);
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onDeleteHabitRequested(
    DeleteHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitRepository.deleteHabit(event.id);
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onToggleHabitLogRequested(
    ToggleHabitLogRequested event,
    Emitter<HabitState> emit,
  ) async {
    if (_userId == null || _selectedDate == null) return;

    try {
      final logs = await _habitRepository.getLogsForHabit(event.habitId);

      // Look for a log matching the selected date (year, month, day)
      final existingLog = logs
          .where(
            (l) =>
                l.date.year == event.date.year &&
                l.date.month == event.date.month &&
                l.date.day == event.date.day,
          )
          .firstOrNull;

      if (existingLog != null) {
        final updatedLog = HabitLogModel(
          id: existingLog.id,
          habitId: existingLog.habitId,
          date: existingLog.date,
          isCompleted: !existingLog.isCompleted,
          note: existingLog.note,
        );
        await _habitRepository.logHabit(updatedLog);
      } else {
        final newLog = HabitLogModel(
          id: const Uuid().v4(),
          habitId: event.habitId,
          date: event.date,
          isCompleted: true,
        );
        await _habitRepository.logHabit(newLog);
      }

      final updatedLogs = await _habitRepository.getLogsForDate(
        _userId!,
        _selectedDate!,
      );
      final streaks = <String, int>{};
      for (final habit in _currentHabits) {
        streaks[habit.id] = await _habitRepository.calculateStreak(habit.id);
      }
      final overallStreak = await _calculateOverallStreak(_currentHabits);
      emit(
        HabitLoaded(
          habits: _currentHabits,
          todayLogs: updatedLogs,
          selectedDate: _selectedDate!,
          streaks: streaks,
          overallStreak: overallStreak,
        ),
      );
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<int> _calculateOverallStreak(List<HabitModel> habits) async {
    if (habits.isEmpty) return 0;

    final completionMap = <String, Set<String>>{};
    DateTime earliestCreatedAt = DateTime.now();

    for (final habit in habits) {
      if (habit.createdAt.isBefore(earliestCreatedAt)) {
        earliestCreatedAt = habit.createdAt;
      }
      final logs = await _habitRepository.getLogsForHabit(habit.id);
      for (final log in logs) {
        if (log.isCompleted) {
          final dateKey = _toDateKey(log.date);
          completionMap.putIfAbsent(dateKey, () => <String>{}).add(habit.id);
        }
      }
    }

    final today = _stripTime(DateTime.now());
    final earliestStripped = _stripTime(earliestCreatedAt);

    int streak = 0;
    DateTime current = today;

    while (current.isAfter(earliestStripped) || current.isAtSameMomentAs(earliestStripped)) {
      final activeHabitsOnDay = habits.where((h) => _isDayActive(h, current)).toList();

      if (activeHabitsOnDay.isEmpty) {
        current = current.subtract(const Duration(days: 1));
        continue;
      }

      final completedHabitIdsOnDay = completionMap[_toDateKey(current)] ?? {};

      bool allCompleted = true;
      for (final habit in activeHabitsOnDay) {
        if (!completedHabitIdsOnDay.contains(habit.id)) {
          allCompleted = false;
          break;
        }
      }

      if (allCompleted) {
        streak++;
      } else {
        if (current.isAtSameMomentAs(today)) {
          // Today not fully completed doesn't break the streak yet, as it's still ongoing
        } else {
          break;
        }
      }

      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String _toDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDayActive(HabitModel habit, DateTime date) {
    final weekdayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekdayStr = weekdayNames[date.weekday - 1];
    return habit.activeDays.contains(weekdayStr);
  }

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }
}
