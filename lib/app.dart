// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'bloc/class/class_bloc.dart';
import 'bloc/class/class_event.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/advanced_splash_screen.dart';  // Add this import
import 'theme/app_theme.dart';

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Attendance',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [AppNavigatorObserver()],
          
          // Set splash screen as initial route
          initialRoute: '/',
          routes: {
            '/': (context) => const AdvancedSplashScreen(),
            '/home': (context) => const HomeScreen(),
          },
          
          // Fallback for any undefined routes
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
          },
        );
      },
    );
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    
    // When returning to a previous route, refresh data
    final context = previousRoute?.navigator?.context;
    if (context != null) {
      try {
        // Try to reload classes if ClassBloc is available in this context
        BlocProvider.of<ClassBloc>(context, listen: false).add(LoadClasses());
      } catch (_) {
        // Ignore if ClassBloc is not available
      }
    }
  }
}