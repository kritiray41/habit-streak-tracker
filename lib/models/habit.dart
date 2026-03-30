import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<DateTime> completedDays;

  // --- NEW FIELDS FOR 11.8 (PERSISTING 11.4 PRO FEATURES) ---
  @HiveField(4)
  String frequency;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  int iconCodePoint;

  @HiveField(7)
  String? reminderTime;

  Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.completedDays,
    this.frequency = 'Daily',
    this.colorValue = 0xFF38BDF8, // Default Primary Color
    this.iconCodePoint = 0xe5f9, // Default Star Icon (Icons.star)
    this.reminderTime,
  });

  // --- STREAK CALCULATION ALGORITHM ---
  int get streak {
    int currentStreak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; ; i++) {
      DateTime dateToCheck = today.subtract(Duration(days: i));

      bool isCompletedOnDate = completedDays.any((d) =>
          d.year == dateToCheck.year &&
          d.month == dateToCheck.month &&
          d.day == dateToCheck.day);

      if (isCompletedOnDate) {
        currentStreak++;
      } else {
        if (i == 0) {
          continue; 
        } else {
          break; 
        }
      }
    }
    
    return currentStreak;
  }
}