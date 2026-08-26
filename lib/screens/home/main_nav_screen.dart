import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_event.dart';
import '../../theme/colors.dart';
import '../../widgets/liquid_glass_bar.dart';
import '../settings/settings_screen.dart';
import '../timetable/timetable_screen.dart';
import 'home_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentTab = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      context.read<ClassBloc>().add(LoadClasses());
    }
    if (_currentTab != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentTab = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Enables liquid glass bar to float over page content
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              TimetableScreen(),
              SettingsScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassBar(
              items: [
                LiquidGlassBarItem(
                  icon: Icons.school_rounded,
                  label: 'Classes',
                  isSelected: _currentTab == 0,
                  activeColor: AppColors.primaryLight,
                  onTap: () => _onTabSelected(0),
                ),
                LiquidGlassBarItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Timetable',
                  isSelected: _currentTab == 1,
                  activeColor: AppColors.accentColor,
                  onTap: () => _onTabSelected(1),
                ),
                LiquidGlassBarItem(
                  icon: Icons.tune_rounded,
                  label: 'Settings',
                  isSelected: _currentTab == 2,
                  activeColor: const Color(0xFFA855F7), // Violet
                  onTap: () => _onTabSelected(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
