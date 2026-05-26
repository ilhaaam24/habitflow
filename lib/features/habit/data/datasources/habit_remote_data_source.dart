import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

abstract class HabitRemoteDataSource {
  Future<void> syncHabit(HabitModel habit);
  Future<void> deleteHabit(String userId, String id);
  Future<void> syncHabitLog(String userId, HabitLogModel log);
  Future<List<HabitModel>> fetchHabits(String userId);
  Future<List<HabitLogModel>> fetchLogsForDate(String userId, DateTime date);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final FirebaseFirestore firestore;

  HabitRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> syncHabit(HabitModel habit) async {
    final habitRef = firestore
        .collection('users')
        .doc(habit.userId)
        .collection('habits')
        .doc(habit.id);
    await habitRef.set(habit.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteHabit(String userId, String id) async {
    final habitRef = firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(id);
    await habitRef.delete();

    // Optionally: delete associated logs from Firestore.
    // In a production app, we would write a Cloud Function or perform a batch delete.
    // Since we're in client-side Firestore, we can query and delete logs.
    final logsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .where('habitId', isEqualTo: id)
        .get();

    final batch = firestore.batch();
    for (final doc in logsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> syncHabitLog(String userId, HabitLogModel log) async {
    final logRef = firestore
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .doc(log.id);
    await logRef.set(log.toJson(), SetOptions(merge: true));
  }

  @override
  Future<List<HabitModel>> fetchHabits(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .get();

    return snapshot.docs
        .map((doc) => HabitModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<HabitLogModel>> fetchLogsForDate(String userId, DateTime date) async {
    // Format date string to match our ISO format start and end of day
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toIso8601String();

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    return snapshot.docs
        .map((doc) => HabitLogModel.fromJson(doc.data()))
        .toList();
  }
}
