import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

abstract class HabitState {}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<HabitModel> habits;
  final List<HabitLogModel> todayLogs;
  final DateTime selectedDate;

  HabitLoaded({
    required this.habits,
    required this.todayLogs,
    required this.selectedDate,
  });
}

class HabitError extends HabitState {
  final String message;
  HabitError(this.message);
}
