import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/notification_service.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Calculate the user's highest historical streak across all habits
  int _getHighestStreak(Box<Habit> box) {
    int best = 0;
    for (var habit in box.values) {
      if (habit.streak > best) best = habit.streak;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');
    // Check current theme
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // --- DYNAMIC GRADIENT ---
          colors: isDark 
              ? const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)] // Sleek Dark
              : const [Color(0xFFE0EAFC), Color(0xFFCFDEF3), Color(0xFFE0EAFC)], // Sleek Light
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Profile & Achievements", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Habit> box, _) {
            final bestStreak = _getHighestStreak(box);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 11.6 USER PROFILE HEADER ---
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF38BDF8).withOpacity(0.2),
                          child: const Icon(Icons.person, size: 50, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Habit Champion",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Best Overall Streak: $bestStreak Days",
                          style: const TextStyle(fontSize: 16, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 11.5 BADGES AND ACHIEVEMENTS ---
                  Text(
                    "Achievements",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildBadge("Bronze Starter", "3 Day Streak", Icons.local_fire_department, bestStreak >= 3, Colors.orangeAccent, isDark),
                      _buildBadge("Silver Consistent", "7 Day Streak", Icons.shield, bestStreak >= 7, Colors.grey.shade400, isDark),
                      _buildBadge("Gold Dedicated", "30 Day Streak", Icons.emoji_events, bestStreak >= 30, Colors.amber, isDark),
                      _buildBadge("Master", "100 Day Streak", Icons.diamond, bestStreak >= 100, Colors.cyan, isDark),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- 11.6 PROFILE AND SETTINGS ---
                  Text(
                    "Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        // --- DYNAMIC DARK MODE SWITCH ---
                        ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          builder: (context, settingsBox, _) {
                            bool isDarkMode = settingsBox.get('isDarkMode', defaultValue: true);
                            return _buildSettingTile(
                              Icons.dark_mode, 
                              "Dark Theme", 
                              textColor: textColor,
                              iconColor: isDark ? Colors.white70 : Colors.black54,
                              trailing: Switch(
                                value: isDarkMode, 
                                onChanged: (value) {
                                  settingsBox.put('isDarkMode', value); 
                                }, 
                                activeColor: const Color(0xFF38BDF8),
                              ),
                            );
                          }
                        ),
                        Divider(color: isDark ? Colors.white24 : Colors.black12, height: 1),
                        
                        // --- DYNAMIC NOTIFICATIONS SWITCH ---
                        ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          builder: (context, settingsBox, _) {
                            bool isNotificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: true);
                            return _buildSettingTile(
                              Icons.notifications, 
                              "Notifications", 
                              textColor: textColor,
                              iconColor: isDark ? Colors.white70 : Colors.black54,
                              trailing: Switch(
                                value: isNotificationsEnabled, 
                                onChanged: (value) async {
                                  settingsBox.put('notificationsEnabled', value); // Save preference
                                  
                                  if (value) {
                                    // FIRE A TEST NOTIFICATION WHEN TURNED ON!
                                    await NotificationService().showTestNotification();
                                  }
                                }, 
                                activeColor: const Color(0xFF38BDF8),
                              ),
                            );
                          }
                        ),
                        
                        Divider(color: isDark ? Colors.white24 : Colors.black12, height: 1),
                        _buildSettingTile(Icons.logout, "Logout", textColor: Colors.redAccent, iconColor: Colors.redAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for Badges (11.5)
  Widget _buildBadge(String title, String subtitle, IconData icon, bool isUnlocked, Color badgeColor, bool isDark) {
    Color textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked 
            ? badgeColor.withOpacity(0.15) 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked 
              ? badgeColor.withOpacity(0.5) 
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.black12),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? icon : Icons.lock_outline,
            size: 40,
            color: isUnlocked ? badgeColor : (isDark ? Colors.white38 : Colors.black38),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? textColor : (isDark ? Colors.white54 : Colors.black54),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isUnlocked ? (isDark ? Colors.white70 : Colors.black54) : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Settings List (11.6)
  Widget _buildSettingTile(IconData icon, String title, {Widget? trailing, Color? textColor, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: () {
        // Handle setting tap
      },
    );
  }
}