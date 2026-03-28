import 'package:hive/hive.dart';

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

  Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.completedDays,
  });

  // --- STREAK CALCULATION ALGORITHM ---
  int get streak {
    int currentStreak = 0;
    DateTime today = DateTime.now();

    // Loop backwards day by day
    for (int i = 0; ; i++) {
      // Get the date we are currently checking (today, then yesterday, etc.)
      DateTime dateToCheck = today.subtract(Duration(days: i));

      // Check if this date exists in our completed list (ignoring the exact time)
      bool isCompletedOnDate = completedDays.any((d) =>
          d.year == dateToCheck.year &&
          d.month == dateToCheck.month &&
          d.day == dateToCheck.day);

      if (isCompletedOnDate) {
        currentStreak++;
      } else {
        // If it's today and we haven't completed it yet, don't break the streak!
        // We only break the streak if a past day (yesterday or older) was missed.
        if (i == 0) {
          continue; 
        } else {
          break; // A gap was found, break the loop
        }
      }
    }
    
    return currentStreak;
  }
}