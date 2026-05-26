import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category; // e.g., health, study, fitness, etc.
  final String icon; // emoji or icon name string
  final int colorValue; // Color represented as ARGB int
  final String reminderTime; // "HH:mm" format string
  final List<String> activeDays; // e.g., ['mon', 'tue', ...]
  final DateTime createdAt;
  final bool isActive;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.colorValue,
    required this.reminderTime,
    required this.activeDays,
    required this.createdAt,
    this.isActive = true,
  });

  // Helper getter to convert colorValue to flutter Color
  Color get color => Color(colorValue);

  // Helper getter to convert reminderTime string ("HH:mm") to TimeOfDay
  TimeOfDay get reminderTimeOfDay {
    final parts = reminderTime.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  // Serialize to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'colorValue': colorValue,
      'reminderTime': reminderTime,
      'activeDays': activeDays,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Deserialize from JSON Map
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      icon: json['icon'] as String,
      colorValue: json['colorValue'] as int,
      reminderTime: json['reminderTime'] as String? ?? '08:00',
      activeDays: List<String>.from(json['activeDays'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
