import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';
import '../datasources/habit_remote_data_source.dart';
import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addHabit(HabitModel habit) async {
    await localDataSource.cacheHabit(habit);
    try {
      await remoteDataSource.syncHabit(habit);
    } catch (_) {
      // Offline-first: allow local success even if sync fails
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await localDataSource.cacheHabit(habit);
    try {
      await remoteDataSource.syncHabit(habit);
    } catch (_) {
      // Offline-first: allow local success even if sync fails
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habit = localDataSource.getCachedHabit(id);
    if (habit != null) {
      final userId = habit.userId;
      await localDataSource.deleteHabit(id);
      try {
        await remoteDataSource.deleteHabit(userId, id);
      } catch (_) {
        // Offline-first: allow local success even if sync fails
      }
    } else {
      await localDataSource.deleteHabit(id);
    }
  }

  @override
  Stream<List<HabitModel>> getHabits(String userId) {
    _syncRemoteHabits(userId);
    return localDataSource.watchCachedHabits(userId);
  }

  Future<void> _syncRemoteHabits(String userId) async {
    try {
      final remoteHabits = await remoteDataSource.fetchHabits(userId);
      for (final habit in remoteHabits) {
        await localDataSource.cacheHabit(habit);
      }
    } catch (_) {
      // Silent catch
    }
  }

  @override
  Future<void> logHabit(HabitLogModel log) async {
    await localDataSource.cacheHabitLog(log);
    final habit = localDataSource.getCachedHabit(log.habitId);
    if (habit != null) {
      try {
        await remoteDataSource.syncHabitLog(habit.userId, log);
      } catch (_) {
        // Offline-first: allow local success even if sync fails
      }
    }
  }

  @override
  Future<List<HabitLogModel>> getLogsForDate(
    String userId,
    DateTime date,
  ) async {
    _syncRemoteLogs(userId, date);
    return localDataSource.getCachedLogsForDate(userId, date);
  }

  Future<void> _syncRemoteLogs(String userId, DateTime date) async {
    try {
      final remoteLogs = await remoteDataSource.fetchLogsForDate(userId, date);
      for (final log in remoteLogs) {
        await localDataSource.cacheHabitLog(log);
      }
    } catch (_) {
      // Silent catch
    }
  }

  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    return localDataSource.getCachedLogsForHabit(habitId);
  }

  @override
  Future<int> calculateStreak(String habitId) async {
    final habit = localDataSource.getCachedHabit(habitId);
    if (habit == null) return 0;
    final logs = await getLogsForHabit(habitId);
    return _computeCurrentStreak(habit, logs);
  }

  @override
  Future<int> getLongestStreak(String habitId) async {
    final habit = localDataSource.getCachedHabit(habitId);
    if (habit == null) return 0;
    final logs = await getLogsForHabit(habitId);
    return _computeLongestStreak(habit, logs);
  }

  int _computeCurrentStreak(HabitModel habit, List<HabitLogModel> logs) {
    final completionMap = <String, bool>{};
    for (final log in logs) {
      if (log.isCompleted) {
        final dateKey = _toDateKey(log.date);
        completionMap[dateKey] = true;
      }
    }

    final today = _stripTime(DateTime.now());
    final createdAtStripped = _stripTime(habit.createdAt);

    int streak = 0;
    DateTime current = today;

    while (current.isAfter(createdAtStripped) || current.isAtSameMomentAs(createdAtStripped)) {
      if (_isDayActive(habit, current)) {
        final dateKey = _toDateKey(current);
        final isCompleted = completionMap[dateKey] ?? false;

        if (isCompleted) {
          streak++;
        } else {
          // If it is today, we don't break the streak since today is not over yet.
          // For any other day, not completing it breaks the streak.
          if (current.isAtSameMomentAs(today)) {
            // Keep going, don't increment but don't break.
          } else {
            break;
          }
        }
      }
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _computeLongestStreak(HabitModel habit, List<HabitLogModel> logs) {
    final completionMap = <String, bool>{};
    for (final log in logs) {
      if (log.isCompleted) {
        final dateKey = _toDateKey(log.date);
        completionMap[dateKey] = true;
      }
    }

    final today = _stripTime(DateTime.now());
    final createdAtStripped = _stripTime(habit.createdAt);

    int longest = 0;
    int currentRun = 0;

    // Scan forward from createdAt to today
    DateTime current = createdAtStripped;
    while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
      if (_isDayActive(habit, current)) {
        final dateKey = _toDateKey(current);
        final isCompleted = completionMap[dateKey] ?? false;

        if (isCompleted) {
          currentRun++;
          if (currentRun > longest) {
            longest = currentRun;
          }
        } else {
          if (current.isAtSameMomentAs(today)) {
            // Today not completed yet doesn't break the longest streak run that has accumulated up to yesterday
          } else {
            currentRun = 0;
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return longest;
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
}
