import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:confetti/confetti.dart';
import '../models/habit.dart';
import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // --- 11.3 DYNAMIC GREETING ---
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  double _getDailyProgress(Box<Habit> box) {
    if (box.isEmpty) return 0.0;
    
    int completedToday = 0;
    final today = DateTime.now();
    
    for (var habit in box.values) {
      bool isCompleted = habit.completedDays.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
      if (isCompleted) completedToday++;
    }
    return completedToday / box.length;
  }

  int _getTotalActiveStreaks(Box<Habit> box) {
    int totalStreaks = 0;
    for (var habit in box.values) {
      totalStreaks += habit.streak;
    }
    return totalStreaks;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');
    
    // Check if the app is currently in Dark Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Stack(
      children: [
        // Main Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // --- DYNAMIC GRADIENTS ---
              colors: isDark 
                  ? const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)] // Sleek Dark
                  : const [Color(0xFFE0EAFC), Color(0xFFCFDEF3), Color(0xFFE0EAFC)], // Sleek Light
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 2,
                  shadows: isDark ? const [
                    Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 0),
                  ] : null,
                ),
              ),
              centerTitle: false,
              foregroundColor: textColor,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart, size: 30),
                  onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const StatsScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person, size: 30),
                  onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Habit> box, _) {
                double progress = _getDailyProgress(box);
                int totalStreak = _getTotalActiveStreaks(box);

                return CustomScrollView(
                  slivers: [
                    // --- 11.3 HOME DASHBOARD HEADER ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_getGreeting()}, Champion! 🔥",
                              style: TextStyle(
                                fontSize: 22,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Overview Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.3) : Colors.black12, 
                                  width: 1.5
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Today's Progress",
                                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${(progress * 100).toInt()}%",
                                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 12,
                                      backgroundColor: isDark ? Colors.white.withOpacity(0.2) : Colors.black12,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Text(
                                        "$totalStreak Total Active Streaks",
                                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 16),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Habit List
                    box.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "Add your first habit",
                                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final habit = box.getAt(index)!;
                                final today = DateTime.now();
                                bool isCompletedToday = habit.completedDays.any((date) =>
                                    date.year == today.year &&
                                    date.month == today.month &&
                                    date.day == today.day);

                                return TweenAnimationBuilder(
                                  duration: Duration(milliseconds: 400 + (index * 100)),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 50 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: HabitTile(
                                    habit: habit,
                                    isCompleted: isCompletedToday,
                                    onDelete: () => habit.delete(),
                                    onChanged: (value) {
                                      if (value == true) {
                                        habit.completedDays.add(today);
                                        _confettiController.play();
                                      } else {
                                        habit.completedDays.removeWhere((date) =>
                                            date.year == today.year &&
                                            date.month == today.month &&
                                            date.day == today.day);
                                      }
                                      habit.save();
                                    },
                                  ),
                                );
                              },
                              childCount: box.length,
                            ),
                          ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: isDark ? Colors.white.withOpacity(0.3) : const Color(0xFF38BDF8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.5) : Colors.transparent),
              ),
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddHabitScreen()),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),

        // --- CONFETTI WIDGET LAYER ---
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            gravity: 0.2,
            emissionFrequency: 0.05,
          ),
        ),
      ],
    );
  }
}