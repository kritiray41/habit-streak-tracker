import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onChanged;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // --- GLASSMORPHISM STARTS HERE ---
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The Frost Effect
            child: Container(
              decoration: BoxDecoration(
                // Semi-transparent white
                color: isCompleted
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                // A subtle white border makes the "glass" edge pop
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CheckboxListTile(
                  title: Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800, // Bolder
                      color: Colors.white, // White text for contrast
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white70,
                      decorationThickness: 3,
                      // --- SUBTLE 3D POP FOR LIST ITEMS ---
                      shadows: const [
                        Shadow(color: Colors.black38, offset: Offset(1.5, 1.5), blurRadius: 0),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: habit.streak > 0 ? Colors.amberAccent : Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.streak} Day Streak',
                          style: TextStyle(
                            color: habit.streak > 0 ? Colors.amberAccent : Colors.white54,
                            fontWeight: habit.streak > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  value: isCompleted,
                  onChanged: onChanged,
                  activeColor: Colors.white.withOpacity(0.4),
                  checkColor: Colors.white,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: Colors.white.withOpacity(0.8)),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}