import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // --- 11.4 NEW PRO FEATURES STATE ---
  String _selectedFrequency = 'Daily';
  TimeOfDay? _reminderTime;
  Color _selectedColor = const Color(0xFF38BDF8); // Primary Color from 11.7
  IconData _selectedIcon = Icons.star;

  // Options for pickers
  final List<String> _frequencies = ['Daily', 'Weekly', 'Weekdays', 'Weekends'];
  
  final List<Color> _colorOptions = [
    const Color(0xFF38BDF8), // Blue
    const Color(0xFFE94057), // Pink
    const Color(0xFFF27121), // Orange
    const Color(0xFF8A2387), // Purple
    const Color(0xFF4ADE80), // Green
    const Color(0xFFFBBF24), // Yellow
  ];

  final List<IconData> _iconOptions = [
    Icons.star, Icons.favorite, Icons.fitness_center, 
    Icons.menu_book, Icons.water_drop, Icons.directions_run,
    Icons.self_improvement, Icons.music_note, Icons.laptop_mac
  ];

  // Pick Reminder Time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Habit>('habits');
      
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        createdAt: DateTime.now(),
        completedDays: [],
        frequency: _selectedFrequency,
        colorValue: _selectedColor.value,
        iconCodePoint: _selectedIcon.codePoint,
        reminderTime: _reminderTime != null 
            ? '${_reminderTime!.hour}:${_reminderTime!.minute}' 
            : null,
      );

      box.add(newHabit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark UI from 11.7
      appBar: AppBar(
        title: const Text('New Habit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Habit Name Input
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'e.g., Read 10 pages',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a habit name' : null,
              ),
              const SizedBox(height: 30),

              // --- 11.4 FREQUENCY SELECTION ---
              const Text("Frequency", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: _frequencies.map((freq) {
                  final isSelected = _selectedFrequency == freq;
                  return ChoiceChip(
                    label: Text(freq),
                    selected: isSelected,
                    selectedColor: _selectedColor,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFrequency = freq);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // --- 11.4 REMINDER TIME ---
              const Text("Reminder Time", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectTime(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: _selectedColor),
                      const SizedBox(width: 12),
                      Text(
                        _reminderTime != null ? _reminderTime!.format(context) : "Set a daily reminder",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 11.4 ICON SELECTOR ---
              const Text("Icon", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final icon = _iconOptions[index];
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? _selectedColor : Colors.transparent, width: 2),
                        ),
                        child: Icon(icon, color: isSelected ? _selectedColor : Colors.white54, size: 28),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // --- 11.4 COLOR PICKER ---
              const Text("Theme Color", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final color = _colorOptions[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: isSelected ? 3 : 0),
                          boxShadow: [
                            if (isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: _selectedColor.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Create Habit",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}