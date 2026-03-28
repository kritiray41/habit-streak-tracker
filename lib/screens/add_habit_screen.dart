import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController controller = TextEditingController();

  void saveHabit() {
    if (controller.text.isEmpty) return;
    
    final box = Hive.box<Habit>('habits');
    box.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: controller.text,
        createdAt: DateTime.now(),
        completedDays: [],
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the whole screen in the gradient container to match the Home Screen
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
        backgroundColor: Colors.transparent, // Let the gradient show through
        
        appBar: AppBar(
          title: const Text(
            "New Habit",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              // 3D Text Effect to match the other screens
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
        ),
        
        // --- THE FIX: SingleChildScrollView prevents keyboard overflow ---
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "What do you want to achieve?",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 0),
                    ]
                  ),
                ),
                const SizedBox(height: 16),
                
                // Glassmorphism Text Field
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: TextField(
                        controller: controller,
                        autofocus: true, // Keyboard pops up automatically
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "e.g., Read for 20 minutes",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Glassmorphism Save Button
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: InkWell(
                      onTap: saveHabit,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            "Save Habit",
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black38, offset: Offset(1.5, 1.5), blurRadius: 0),
                              ]
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Extra padding at the bottom so it scrolls nicely above the keyboard
                const SizedBox(height: 300), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}