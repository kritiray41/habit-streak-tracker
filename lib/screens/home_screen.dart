import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    // Wrap the Scaffold in a gradient container
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A2387), // Deep Purple
            Color(0xFFE94057), // Vibrant Pink
            Color(0xFFF27121), // Sunset Orange
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Crucial for showing the gradient!
        
        appBar: AppBar(
          title: const Text(
            "Habit Tracker",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900, // Extra bold
              color: Colors.white,
              letterSpacing: 2,
              // --- 3D TEXT EFFECT ---
              shadows: [
                Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 0),
                Shadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart, size: 30),
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StatsScreen()),
              ),
            )
          ],
        ),

        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Habit> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  "Add your first habit",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 0),
                    ]
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final habit = box.getAt(index)!;
                final today = DateTime.now();
                bool isCompletedToday = habit.completedDays.any((date) =>
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day);

                return HabitTile(
                  habit: habit,
                  isCompleted: isCompletedToday,
                  onDelete: () => habit.delete(),
                  onChanged: (value) {
                    if (value == true) {
                      habit.completedDays.add(today);
                    } else {
                      habit.completedDays.removeWhere((date) =>
                          date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day);
                    }
                    habit.save();
                  },
                );
              },
            );
          },
        ),

        // Glassmorphism Floating Action Button
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddHabitScreen(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}