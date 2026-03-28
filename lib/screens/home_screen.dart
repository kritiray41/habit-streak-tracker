import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
      ),

      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {

          final habits = provider.habits;

          if (habits.isEmpty) {
            return const Center(
              child: Text("No habits yet"),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {

              final habit = habits[index];

              bool completedToday =
                  habit.completedDays.any(
                (d) => provider.isSameDay(
                    d, DateTime.now()),
              );

              return ListTile(
                title: Text(habit.name),

                trailing: Checkbox(
                  value: completedToday,
                  onChanged: (_) {
                    provider.toggleHabit(habit);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddHabitScreen(),
            ),
          );
        },
      ),
    );
  }
}