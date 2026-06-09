// main.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'app.dart';
import 'bloc/class/class_bloc.dart';
import 'bloc/attendance/attendance_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'database/app_database.dart';
import 'screens/home/advanced_splash_screen.dart';  

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'attendance_app.db'),
    onCreate: (db, version) => AppDatabase.createTables(db),
    version: 1,
  );

  // Initialize app with database instance
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ClassBloc(database)),
        BlocProvider(create: (_) => AttendanceBloc(database)),
      ],
      child: const AttendanceApp(),
    ),
  );
}