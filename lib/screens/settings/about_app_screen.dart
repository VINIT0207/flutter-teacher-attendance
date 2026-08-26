import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About ClassTrack'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 350),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 25.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // App Logo / Crest with Smooth Ambient Glow
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor
                                .withValues(alpha: isDark ? 0.45 : 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'lib/assets/logo/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // App Title and Subtitle
                  const Text(
                    'ClassTrack',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor
                          .withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Version 1.0.0 • Professional Edition',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Intelligent, privacy-first classroom attendance tracking, weekly lecture scheduling, and statistical academic insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color:
                          isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Core Architecture Highlights
                  _buildSectionTitle('Core Architectural Pillars'),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.presentColor,
                    title: '100% Offline & Privacy First',
                    description:
                        'All student records, attendance logs, and timetable schedules are stored locally in an on-device SQLite database. Zero external trackers or unauthorized telemetry.',
                  ),
                  const SizedBox(height: 10),

                  _buildFeatureCard(
                    context,
                    icon: Icons.table_chart_rounded,
                    iconColor: Colors.teal,
                    title: 'Dual CSV & Excel Compatibility',
                    description:
                        'Seamlessly import large student rosters or export analytical attendance spreadsheets in both Microsoft Excel (.xlsx, .xls) and CSV (.csv) formats.',
                  ),
                  const SizedBox(height: 10),

                  _buildFeatureCard(
                    context,
                    icon: Icons.notifications_active_outlined,
                    iconColor: AppColors.primaryLight,
                    title: 'Smart Timetable & Lecture Alerts',
                    description:
                        'Define recurring weekly lecture periods and receive automated background notifications before each lecture with room and subject details.',
                  ),
                  const SizedBox(height: 10),

                  _buildFeatureCard(
                    context,
                    icon: Icons.analytics_outlined,
                    iconColor: Colors.indigoAccent,
                    title: 'Statistical Variance & Risk Matrix',
                    description:
                        'Calculates attendance consistency scores, recent session momentum trends, target recovery projections, and flags critical defaulter risk (< 75%).',
                  ),
                  const SizedBox(height: 28),

                  // Technology Stack Details
                  _buildSectionTitle('Built With Cutting-Edge Technology'),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBackground : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTechRow('Framework', 'Flutter 3.x (Dart 3.x)'),
                        const Divider(height: 20),
                        _buildTechRow('Design System',
                            'Custom Glassmorphism + High Contrast OLED Dark'),
                        const Divider(height: 20),
                        _buildTechRow(
                            'State Management', 'BLoC 8.x (Clean MVVM Pattern)'),
                        const Divider(height: 20),
                        _buildTechRow('Database Engine',
                            'SQLite (sqflite / sqflite_common_ffi)'),
                        const Divider(height: 20),
                        _buildTechRow('Notification Engine',
                            'Flutter Local Notifications with Exact Alarms'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Database & Backup Integrity
                  _buildSectionTitle('Data Portability & Backup'),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBackground : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.backup_table_rounded,
                              color: AppColors.primaryLight, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'JSON Database Snapshot',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Create full portable backups of all classes, students, logs, and timetable slots anytime from Settings.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Copyright & credits
                  Text(
                    '© 2026 ClassTrack • Crafted for Educators',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Designed with Flutter',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color:
                        isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
