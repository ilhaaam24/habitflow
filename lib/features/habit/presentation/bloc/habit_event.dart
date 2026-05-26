import '../../../../shared/models/habit_model.dart';

abstract class HabitEvent {}

class LoadHabitsRequested extends HabitEvent {
  final String userId;
  final DateTime date;
  LoadHabitsRequested({required this.userId, required this.date});
}

class HabitsUpdated extends HabitEvent {
  final List<HabitModel> habits;
  HabitsUpdated(this.habits);
}

class AddHabitRequested extends HabitEvent {
  final HabitModel habit;
  AddHabitRequested(this.habit);
}

class UpdateHabitRequested extends HabitEvent {
  final HabitModel habit;
  UpdateHabitRequested(this.habit);
}

class DeleteHabitRequested extends HabitEvent {
  final String id;
  DeleteHabitRequested(this.id);
}

class ToggleHabitLogRequested extends HabitEvent {
  final String habitId;
  final DateTime date;
  ToggleHabitLogRequested({required this.habitId, required this.date});
}
