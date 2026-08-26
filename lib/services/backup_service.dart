import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../models/settings_model.dart';
import '../widgets/app_snackbar.dart';

class BackupService {
  /// Exports all database tables and app settings into a timestamped JSON backup file.
  static Future<String?> exportDatabaseBackup(
    BuildContext context,
    Database database, {
    SettingsModel? settings,
  }) async {
    try {
      final classes = await database.query('classes');
      final students = await database.query('students');
      final attendanceRecords = await database.query('attendance_records');
      final attendance = await database.query('attendance');
      final timetable = await database.query('timetable');

      final backupData = {
        'appName': 'ClassTrack',
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'settings': settings?.toMap() ?? {},
        'classes': classes,
        'students': students,
        'attendance_records': attendanceRecords,
        'attendance': attendance,
        'timetable': timetable,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      Directory directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (_) {
        directory = Directory.systemTemp;
      }

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'ClassTrack_Backup_${dateStr}_$timeStr.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      if (!context.mounted) return filePath;

      AppSnackBar.showSuccess(
        context,
        'Backup created: ${classes.length} classes, ${students.length} students, ${attendanceRecords.length} sessions.',
        title: 'Backup Successful',
        action: SnackBarAction(
          label: 'Share / Save',
          textColor: Colors.white,
          onPressed: () {
            Share.shareXFiles(
              [XFile(filePath, mimeType: 'application/json')],
              text: 'ClassTrack Database Backup ($dateStr)',
            );
          },
        ),
      );

      // Automatically offer share sheet for easy saving to Drive/Files/WhatsApp
      Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/json')],
        text: 'ClassTrack Database Backup ($dateStr)',
      );

      return filePath;
    } catch (e) {
      if (!context.mounted) return null;
      AppSnackBar.showError(
        context,
        'Failed to generate database backup: $e',
        title: 'Backup Error',
      );
      return null;
    }
  }

  /// Prompts user to pick a backup JSON file and restores all tables inside a transaction.
  static Future<Map<String, dynamic>?> restoreDatabaseBackup(
    BuildContext context,
    Database database,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      String content = '';
      final single = result.files.single;

      if (single.path != null && File(single.path!).existsSync()) {
        content = await File(single.path!).readAsString();
      } else if (single.bytes != null) {
        content = utf8.decode(single.bytes!);
      } else {
        if (!context.mounted) return null;
        AppSnackBar.showError(
          context,
          'Could not read the selected backup file.',
          title: 'File Read Error',
        );
        return null;
      }

      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic> ||
          (!decoded.containsKey('classes') && !decoded.containsKey('students'))) {
        if (!context.mounted) return null;
        AppSnackBar.showError(
          context,
          'Invalid backup file format. Expected a ClassTrack JSON backup file.',
          title: 'Restore Failed',
        );
        return null;
      }

      final classesList = (decoded['classes'] as List<dynamic>?) ?? [];
      final studentsList = (decoded['students'] as List<dynamic>?) ?? [];
      final attendanceRecordsList =
          (decoded['attendance_records'] as List<dynamic>?) ??
              (decoded['attendance_sessions'] as List<dynamic>?) ??
              [];
      final attendanceList = (decoded['attendance'] as List<dynamic>?) ?? [];
      final timetableList = (decoded['timetable'] as List<dynamic>?) ?? [];
      final settingsMap = (decoded['settings'] as Map<String, dynamic>?) ?? {};

      await database.transaction((txn) async {
        // Clear existing tables in proper foreign key order (children first)
        await txn.delete('attendance');
        await txn.delete('attendance_records');
        await txn.delete('timetable');
        await txn.delete('students');
        await txn.delete('classes');

        // Restore classes
        for (var item in classesList) {
          if (item is Map<String, dynamic>) {
            await txn.insert(
              'classes',
              Map<String, dynamic>.from(item),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore students
        for (var item in studentsList) {
          if (item is Map<String, dynamic>) {
            await txn.insert(
              'students',
              Map<String, dynamic>.from(item),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore attendance_records
        for (var item in attendanceRecordsList) {
          if (item is Map<String, dynamic>) {
            await txn.insert(
              'attendance_records',
              Map<String, dynamic>.from(item),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore individual attendance entries
        for (var item in attendanceList) {
          if (item is Map<String, dynamic>) {
            await txn.insert(
              'attendance',
              Map<String, dynamic>.from(item),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore timetable
        for (var item in timetableList) {
          if (item is Map<String, dynamic>) {
            await txn.insert(
              'timetable',
              Map<String, dynamic>.from(item),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });

      final counts = {
        'classes': classesList.length,
        'students': studentsList.length,
        'sessions': attendanceRecordsList.length,
        'attendance': attendanceList.length,
        'timetable': timetableList.length,
        'settings': settingsMap,
      };

      if (!context.mounted) return counts;

      AppSnackBar.showSuccess(
        context,
        'Restored ${counts['classes']} classes, ${counts['students']} students, ${counts['sessions']} attendance sessions & ${counts['timetable']} timetable slots.',
        title: 'Database Restored',
      );

      return counts;
    } catch (e) {
      if (!context.mounted) return null;
      AppSnackBar.showError(
        context,
        'Failed to restore backup: $e',
        title: 'Restore Error',
      );
      return null;
    }
  }
}
