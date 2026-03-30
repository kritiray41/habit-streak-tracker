import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fl_chart/fl_chart.dart'; 
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

  // --- NEW: Analytics Calculation Methods ---
  int _getTotalHabits(Box<Habit> box) => box.length;

  int _getBestStreak(Box<Habit> box) {
    int best = 0;
    for (var habit in box.values) {
      if (habit.streak > best) best = habit.streak;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Habit> box, _) {
            final heatmapData = _prepHeatmapData(box);
            final totalHabits = _getTotalHabits(box);
            final bestStreak = _getBestStreak(box);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- NEW: Analytics Dashboard Cards ---
                    Row(
                      children: [
                        Expanded(child: _buildStatCard("Total Habits", "$totalHabits", Icons.list_alt)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard("Best Streak", "$bestStreak Days", Icons.local_fire_department)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- NEW: Weekly Completion Graph (fl_chart) ---
                    const Text(
                      "Weekly Progress",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 24),

                    // EXISTING HEATMAP
                    const Text(
                      "Activity Heatmap",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
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
                            colorsets: const {1: Colors.amberAccent},
                          ),
                        ),
                      ),
                    ),
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

  // Helper widget for Metric Cards
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // Helper widget for fl_chart integration
  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Text(days[value.toInt()], style: const TextStyle(color: Colors.white));
                },
              ),
            ),
          ),
          barGroups: [
            // Note: You will need to calculate these Y values based on actual weekly data
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 2, color: Colors.amberAccent)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.amberAccent)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.amberAccent)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4, color: Colors.amberAccent)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1, color: Colors.amberAccent)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 0, color: Colors.amberAccent)]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 2, color: Colors.amberAccent)]),
          ],
        ),
      ),
    );
  }
}