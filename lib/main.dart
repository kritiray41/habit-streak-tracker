import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'models/habit.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart'; // <-- NOTIFICATION IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- INITIALIZE NOTIFICATIONS BEFORE APP STARTS ---
  await NotificationService().init(); 
  
  await Hive.initFlutter();
  
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }
  
  await Hive.openBox<Habit>('habits');
  await Hive.openBox('settings'); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the settings box for theme changes
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, _) {
        bool isDarkMode = box.get('isDarkMode', defaultValue: true);

        return MaterialApp(
          title: 'Habit Streak',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          
          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF38BDF8),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
          ),
          
          // --- DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF38BDF8),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          
          home: const SplashScreen(),
        );
      },
    );
  }
}