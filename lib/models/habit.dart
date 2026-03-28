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
}