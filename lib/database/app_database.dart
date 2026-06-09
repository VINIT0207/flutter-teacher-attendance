import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Future<void> createTables(Database db) async {
    // Classes table
    await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        year TEXT NOT NULL,
        totalStudents INTEGER NOT NULL DEFAULT 0,
        lastAttendanceDate TEXT
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        name TEXT NOT NULL,
        rollNo TEXT NOT NULL,
        parentContact TEXT NOT NULL,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');

    // Attendance Records table
    await db.execute('''
      CREATE TABLE attendance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        presentCount INTEGER NOT NULL DEFAULT 0,
        absentCount INTEGER NOT NULL DEFAULT 0,
        lateCount INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        recordId INTEGER NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (recordId) REFERENCES attendance_records (id) ON DELETE CASCADE
      )
    ''');
  }
}
