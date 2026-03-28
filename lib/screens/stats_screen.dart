import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../models/habit.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Map<DateTime, int> _prepHeatmapData(Box<Habit> box) {
    Map<DateTime, int> dataset = {};
    for (var habit in box.values) {
      for (var date in habit.completedDays) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        dataset[normalizedDate] = (dataset[normalizedDate] ?? 0) + 1;
      }
    }
    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A2387),
            Color(0xFFE94057),
            Color(0xFFF27121),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
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
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Habit> box, _) {
            final heatmapData = _prepHeatmapData(box);

            // --- THE FIX: SingleChildScrollView added here ---
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Activity Heatmap",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // GLASSMORPHISM HEATMAP
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          ),
                          child: HeatMapCalendar(
                            datasets: heatmapData,
                            colorMode: ColorMode.opacity,
                            defaultColor: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                            weekTextColor: Colors.white70,
                            colorsets: const {
                              1: Colors.amberAccent,
                            },
                            onClick: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.deepPurple.shade800,
                                  content: Text(
                                    'Activity on ${value.toString().split(' ')[0]}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Extra padding at the bottom for smooth scrolling
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}