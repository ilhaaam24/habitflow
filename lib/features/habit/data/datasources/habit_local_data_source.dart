import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

abstract class HabitLocalDataSource {
  Future<void> cacheHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  HabitModel? getCachedHabit(String id);
  List<HabitModel> getCachedHabits(String userId);
  Stream<List<HabitModel>> watchCachedHabits(String userId);
  Future<void> cacheHabitLog(HabitLogModel log);
  List<HabitLogModel> getCachedLogsForDate(String userId, DateTime date);
  List<HabitLogModel> getCachedLogsForHabit(String habitId);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final Box habitsBox;
  final Box logsBox;

  HabitLocalDataSourceImpl({
    required this.habitsBox,
    required this.logsBox,
  });

  @override
  Future<void> cacheHabit(HabitModel habit) async {
    await habitsBox.put(habit.id, habit.toJson());
  }

  @override
  HabitModel? getCachedHabit(String id) {
    final data = habitsBox.get(id);
    if (data == null) return null;
    return HabitModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> deleteHabit(String id) async {
    await habitsBox.delete(id);
    
    // Clean up associated logs from local storage
    final logKeysToDelete = <dynamic>[];
    for (final key in logsBox.keys) {
      final data = logsBox.get(key);
      if (data != null) {
        final logMap = Map<String, dynamic>.from(data as Map);
        if (logMap['habitId'] == id) {
          logKeysToDelete.add(key);
        }
      }
    }
    if (logKeysToDelete.isNotEmpty) {
      await logsBox.deleteAll(logKeysToDelete);
    }
  }

  @override
  List<HabitModel> getCachedHabits(String userId) {
    final habits = <HabitModel>[];
    for (final key in habitsBox.keys) {
      final data = habitsBox.get(key);
      if (data != null) {
        final habitMap = Map<String, dynamic>.from(data as Map);
        if (habitMap['userId'] == userId) {
          habits.add(HabitModel.fromJson(habitMap));
        }
      }
    }
    // Sort by createdAt descending or ascending. Let's do ascending (oldest first) or default
    habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return habits;
  }

  @override
  Stream<List<HabitModel>> watchCachedHabits(String userId) async* {
    yield getCachedHabits(userId);
    await for (final _ in habitsBox.watch()) {
      yield getCachedHabits(userId);
    }
  }

  @override
  Future<void> cacheHabitLog(HabitLogModel log) async {
    await logsBox.put(log.id, log.toJson());
  }

  @override
  List<HabitLogModel> getCachedLogsForDate(String userId, DateTime date) {
    // 1. Get all habit IDs belonging to the user
    final userHabitIds = getCachedHabits(userId).map((h) => h.id).toSet();

    // 2. Filter logs for this date that belong to one of those habits
    final logs = <HabitLogModel>[];
    for (final key in logsBox.keys) {
      final data = logsBox.get(key);
      if (data != null) {
        final logMap = Map<String, dynamic>.from(data as Map);
        final logDate = DateTime.parse(logMap['date'] as String);
        final habitId = logMap['habitId'] as String;

        if (userHabitIds.contains(habitId) &&
            logDate.year == date.year &&
            logDate.month == date.month &&
            logDate.day == date.day) {
          logs.add(HabitLogModel.fromJson(logMap));
        }
      }
    }
    return logs;
  }

  @override
  List<HabitLogModel> getCachedLogsForHabit(String habitId) {
    final logs = <HabitLogModel>[];
    for (final key in logsBox.keys) {
      final data = logsBox.get(key);
      if (data != null) {
        final logMap = Map<String, dynamic>.from(data as Map);
        if (logMap['habitId'] == habitId) {
          logs.add(HabitLogModel.fromJson(logMap));
        }
      }
    }
    logs.sort((a, b) => a.date.compareTo(b.date));
    return logs;
  }
}
