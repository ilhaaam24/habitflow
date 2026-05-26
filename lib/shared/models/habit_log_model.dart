class HabitLogModel {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final String? note;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
    this.note,
  });

  // Serialize to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'note': note,
    };
  }

  // Deserialize from JSON Map
  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool,
      note: json['note'] as String?,
    );
  }
}
