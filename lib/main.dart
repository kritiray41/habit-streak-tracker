import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Removed the google_fonts import!

import 'models/habit.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());

  await Hive.openBox<Habit>('habits');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple, 
        scaffoldBackgroundColor: Colors.grey.shade100, 
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.deepPurple),
          titleTextStyle: TextStyle(
            color: Colors.deepPurple,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Changed from CardTheme to CardThemeData to match your Flutter version
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: const Color.fromARGB(255, 240, 25, 43).withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}