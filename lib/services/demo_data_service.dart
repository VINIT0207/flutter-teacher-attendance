import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_record_model.dart';
import '../models/timetable_model.dart';

class DemoDataService {
  /// Generates clean working dates (excluding Sundays) starting from Monday of the previous week
  /// through Monday to today (Wednesday) of the current week.
  static List<String> getStructuredDemoDates() {
    return [
      // Complete Previous Week (Mon - Sat)
      '2026-08-17', // Mon
      '2026-08-18', // Tue
      '2026-08-19', // Wed
      '2026-08-20', // Thu
      '2026-08-21', // Fri
      '2026-08-22', // Sat
      // (Sunday 2026-08-23 skipped)

      // Current Week (Mon - Today)
      '2026-08-24', // Mon
      '2026-08-25', // Tue
      '2026-08-26', // Wed (Today)
    ];
  }

  static Future<void> seedDemoData(Database database,
      {bool isDailyMode = false}) async {
    final dbHelper = DatabaseHelper(database);

    // Clear existing data first
    await dbHelper.clearAllData();

    final workingDates = getStructuredDemoDates();
    final latestDate = workingDates.last;

    if (isDailyMode) {
      // ==========================================
      // SCHOOL DATASET (FULL_DAY TRACKING MODE)
      // ==========================================
      final g10ClassId = await dbHelper.insertClass(
        ClassModel(
          name: 'Grade 10 - Section A',
          subject: 'Daily Roll Call',
          year: '10th Standard',
          totalStudents: 10,
          lastAttendanceDate: latestDate,
        ),
      );

      final g10Students = [
        StudentModel(
            classId: g10ClassId,
            name: 'Alexander Wright',
            rollNo: '101',
            parentContact: '+1-555-0101'),
        StudentModel(
            classId: g10ClassId,
            name: 'Beatrix Potter',
            rollNo: '102',
            parentContact: '+1-555-0102'),
        StudentModel(
            classId: g10ClassId,
            name: 'Charlie Davis',
            rollNo: '103',
            parentContact: '+1-555-0103'),
        StudentModel(
            classId: g10ClassId,
            name: 'Diana Prince',
            rollNo: '104',
            parentContact: '+1-555-0104'),
        StudentModel(
            classId: g10ClassId,
            name: 'Ethan Hunt',
            rollNo: '105',
            parentContact: '+1-555-0105'),
        StudentModel(
            classId: g10ClassId,
            name: 'Fiona Gallagher',
            rollNo: '106',
            parentContact: '+1-555-0106'),
        StudentModel(
            classId: g10ClassId,
            name: 'George Clark',
            rollNo: '107',
            parentContact: '+1-555-0107'),
        StudentModel(
            classId: g10ClassId,
            name: 'Hannah Abbott',
            rollNo: '108',
            parentContact: '+1-555-0108'),
        StudentModel(
            classId: g10ClassId,
            name: 'Ian Malcolm',
            rollNo: '109',
            parentContact: '+1-555-0109'),
        StudentModel(
            classId: g10ClassId,
            name: 'Julia Roberts',
            rollNo: '110',
            parentContact: '+1-555-0110'),
      ];

      List<int> g10StudentIds = [];
      for (var s in g10Students) {
        final id = await dbHelper.insertStudent(s);
        g10StudentIds.add(id);
      }

      // School Daily Master Roll Call Sessions across 9 working days
      final g10Turnouts = [
        {'present': 9, 'absent': 1, 'late': 0}, // Mon 17 Aug
        {'present': 10, 'absent': 0, 'late': 0}, // Tue 18 Aug
        {'present': 8, 'absent': 1, 'late': 1}, // Wed 19 Aug
        {'present': 9, 'absent': 1, 'late': 0}, // Thu 20 Aug
        {'present': 8, 'absent': 1, 'late': 1}, // Fri 21 Aug
        {'present': 10, 'absent': 0, 'late': 0}, // Sat 22 Aug
        {'present': 7, 'absent': 2, 'late': 1}, // Mon 24 Aug
        {'present': 9, 'absent': 1, 'late': 0}, // Tue 25 Aug
        {'present': 9, 'absent': 1, 'late': 0}, // Wed 26 Aug (Today)
      ];

      for (int d = 0; d < workingDates.length; d++) {
        final sess = g10Turnouts[d % g10Turnouts.length];
        final recordId = await dbHelper.insertAttendanceRecord(
          AttendanceRecordModel(
            classId: g10ClassId,
            date: workingDates[d],
            time: '08:30 AM',
            presentCount: sess['present'] as int,
            absentCount: sess['absent'] as int,
            lateCount: sess['late'] as int,
          ),
        );

        for (int i = 0; i < g10StudentIds.length; i++) {
          final sId = g10StudentIds[i];
          AttendanceStatus st = AttendanceStatus.present;
          if (i == 4) {
            // Ethan - defaulter test
            st = (recordId % 2 == 0)
                ? AttendanceStatus.absent
                : AttendanceStatus.late;
          } else if (i == 8) {
            // Ian - occasional absent
            st = (recordId % 3 == 0)
                ? AttendanceStatus.absent
                : AttendanceStatus.present;
          } else if (i == 1 && recordId % 2 == 0) {
            st = AttendanceStatus.late;
          }

          await dbHelper.insertAttendance(
            AttendanceModel(studentId: sId, recordId: recordId, status: st),
          );
        }
      }

      // School Class 2: Grade 9 - Section B
      final g9ClassId = await dbHelper.insertClass(
        ClassModel(
          name: 'Grade 9 - Section B',
          subject: 'Daily Roll Call',
          year: '9th Standard',
          totalStudents: 6,
          lastAttendanceDate: latestDate,
        ),
      );

      final g9Students = [
        StudentModel(
            classId: g9ClassId,
            name: 'Kevin Bacon',
            rollNo: '201',
            parentContact: '+1-555-0201'),
        StudentModel(
            classId: g9ClassId,
            name: 'Laura Croft',
            rollNo: '202',
            parentContact: '+1-555-0202'),
        StudentModel(
            classId: g9ClassId,
            name: 'Michael Scott',
            rollNo: '203',
            parentContact: '+1-555-0203'),
        StudentModel(
            classId: g9ClassId,
            name: 'Nina Simone',
            rollNo: '204',
            parentContact: '+1-555-0204'),
        StudentModel(
            classId: g9ClassId,
            name: 'Oscar Martinez',
            rollNo: '205',
            parentContact: '+1-555-0205'),
        StudentModel(
            classId: g9ClassId,
            name: 'Pamela Beesly',
            rollNo: '206',
            parentContact: '+1-555-0206'),
      ];

      List<int> g9StudentIds = [];
      for (var s in g9Students) {
        final id = await dbHelper.insertStudent(s);
        g9StudentIds.add(id);
      }

      // Grade 9 Attendance Records across 9 working days
      final g9Turnouts = [
        {'present': 5, 'absent': 1, 'late': 0},
        {'present': 6, 'absent': 0, 'late': 0},
        {'present': 5, 'absent': 0, 'late': 1},
        {'present': 4, 'absent': 2, 'late': 0},
        {'present': 5, 'absent': 1, 'late': 0},
        {'present': 6, 'absent': 0, 'late': 0},
      ];

      for (int d = 0; d < workingDates.length; d++) {
        final sess = g9Turnouts[d % g9Turnouts.length];
        final recordId = await dbHelper.insertAttendanceRecord(
          AttendanceRecordModel(
            classId: g9ClassId,
            date: workingDates[d],
            time: '08:30 AM',
            presentCount: sess['present'] as int,
            absentCount: sess['absent'] as int,
            lateCount: sess['late'] as int,
          ),
        );

        for (int i = 0; i < g9StudentIds.length; i++) {
          final sId = g9StudentIds[i];
          AttendanceStatus st = AttendanceStatus.present;
          if (i == 3 && recordId % 2 == 0) {
            st = AttendanceStatus.absent;
          }
          await dbHelper.insertAttendance(
            AttendanceModel(studentId: sId, recordId: recordId, status: st),
          );
        }
      }

      // Teacher's School Lecture Timetable
      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Mathematics',
          dayOfWeek: 1, // Monday
          startTime: '08:30',
          endTime: '09:15',
          roomNumber: 'Room 10-A',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g9ClassId,
          className: 'Grade 9 - Section B',
          subject: 'General Science',
          dayOfWeek: 1, // Monday
          startTime: '10:00',
          endTime: '10:45',
          roomNumber: 'Room 9-B',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Algebra & Geometry',
          dayOfWeek: 2, // Tuesday
          startTime: '09:15',
          endTime: '10:00',
          roomNumber: 'Room 10-A',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g9ClassId,
          className: 'Grade 9 - Section B',
          subject: 'Science Practical',
          dayOfWeek: 2, // Tuesday
          startTime: '11:00',
          endTime: '11:45',
          roomNumber: 'Science Lab 1',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g9ClassId,
          className: 'Grade 9 - Section B',
          subject: 'General Science',
          dayOfWeek: 3, // Wednesday
          startTime: '08:30',
          endTime: '09:15',
          roomNumber: 'Room 9-B',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Math Activity Lab',
          dayOfWeek: 3, // Wednesday
          startTime: '10:15',
          endTime: '11:00',
          roomNumber: 'Math Lab',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Trigonometry',
          dayOfWeek: 4, // Thursday
          startTime: '09:15',
          endTime: '10:00',
          roomNumber: 'Room 10-A',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g9ClassId,
          className: 'Grade 9 - Section B',
          subject: 'Physics & Chemistry',
          dayOfWeek: 4, // Thursday
          startTime: '11:30',
          endTime: '12:15',
          roomNumber: 'Room 9-B',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Weekly Math Assessment',
          dayOfWeek: 5, // Friday
          startTime: '08:30',
          endTime: '09:15',
          roomNumber: 'Room 10-A',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g9ClassId,
          className: 'Grade 9 - Section B',
          subject: 'Science Quiz & Review',
          dayOfWeek: 5, // Friday
          startTime: '10:00',
          endTime: '10:45',
          roomNumber: 'Room 9-B',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: g10ClassId,
          className: 'Grade 10 - Section A',
          subject: 'Remedial Math Session',
          dayOfWeek: 6, // Saturday
          startTime: '09:00',
          endTime: '09:45',
          roomNumber: 'Room 10-A',
        ),
      );
    } else {
      // ==========================================
      // COLLEGE DATASET (PERIOD_WISE TRACKING MODE)
      // ==========================================
      final csClassId = await dbHelper.insertClass(
        ClassModel(
          name: 'Computer Science & AI',
          subject: 'Data Structures & Algorithms',
          year: 'FY',
          totalStudents: 10,
          lastAttendanceDate: latestDate,
        ),
      );

      final csStudents = [
        StudentModel(
            classId: csClassId,
            name: 'Alexander Wright',
            rollNo: '101',
            parentContact: '+1-555-0101'),
        StudentModel(
            classId: csClassId,
            name: 'Beatrix Potter',
            rollNo: '102',
            parentContact: '+1-555-0102'),
        StudentModel(
            classId: csClassId,
            name: 'Charlie Davis',
            rollNo: '103',
            parentContact: '+1-555-0103'),
        StudentModel(
            classId: csClassId,
            name: 'Diana Prince',
            rollNo: '104',
            parentContact: '+1-555-0104'),
        StudentModel(
            classId: csClassId,
            name: 'Ethan Hunt',
            rollNo: '105',
            parentContact: '+1-555-0105'),
        StudentModel(
            classId: csClassId,
            name: 'Fiona Gallagher',
            rollNo: '106',
            parentContact: '+1-555-0106'),
        StudentModel(
            classId: csClassId,
            name: 'George Clark',
            rollNo: '107',
            parentContact: '+1-555-0107'),
        StudentModel(
            classId: csClassId,
            name: 'Hannah Abbott',
            rollNo: '108',
            parentContact: '+1-555-0108'),
        StudentModel(
            classId: csClassId,
            name: 'Ian Malcolm',
            rollNo: '109',
            parentContact: '+1-555-0109'),
        StudentModel(
            classId: csClassId,
            name: 'Julia Roberts',
            rollNo: '110',
            parentContact: '+1-555-0110'),
      ];

      List<int> csStudentIds = [];
      for (var s in csStudents) {
        final id = await dbHelper.insertStudent(s);
        csStudentIds.add(id);
      }

      // College Period Sessions across 9 working days
      final csTurnouts = [
        {'present': 9, 'absent': 1, 'late': 0},
        {'present': 8, 'absent': 1, 'late': 1},
        {'present': 10, 'absent': 0, 'late': 0},
        {'present': 7, 'absent': 2, 'late': 1},
        {'present': 8, 'absent': 1, 'late': 1},
        {'present': 9, 'absent': 1, 'late': 0},
      ];

      for (int d = 0; d < workingDates.length; d++) {
        final sess = csTurnouts[d % csTurnouts.length];
        final recordId = await dbHelper.insertAttendanceRecord(
          AttendanceRecordModel(
            classId: csClassId,
            date: workingDates[d],
            time: '09:00 AM',
            presentCount: sess['present'] as int,
            absentCount: sess['absent'] as int,
            lateCount: sess['late'] as int,
          ),
        );

        for (int i = 0; i < csStudentIds.length; i++) {
          final sId = csStudentIds[i];
          AttendanceStatus st = AttendanceStatus.present;
          if (i == 4) {
            st = (recordId % 2 == 0)
                ? AttendanceStatus.absent
                : AttendanceStatus.late;
          } else if (i == 8) {
            st = (recordId % 3 == 0)
                ? AttendanceStatus.absent
                : AttendanceStatus.present;
          } else if (i == 1 && recordId % 2 == 0) {
            st = AttendanceStatus.late;
          }

          await dbHelper.insertAttendance(
            AttendanceModel(studentId: sId, recordId: recordId, status: st),
          );
        }
      }

      // College Class 2: Applied Physics
      final phyClassId = await dbHelper.insertClass(
        ClassModel(
          name: 'Applied Physics',
          subject: 'Electromagnetism & Waves',
          year: 'SY',
          totalStudents: 6,
          lastAttendanceDate: latestDate,
        ),
      );

      final phyStudents = [
        StudentModel(
            classId: phyClassId,
            name: 'Kevin Bacon',
            rollNo: '201',
            parentContact: '+1-555-0201'),
        StudentModel(
            classId: phyClassId,
            name: 'Laura Croft',
            rollNo: '202',
            parentContact: '+1-555-0202'),
        StudentModel(
            classId: phyClassId,
            name: 'Michael Scott',
            rollNo: '203',
            parentContact: '+1-555-0203'),
        StudentModel(
            classId: phyClassId,
            name: 'Nina Simone',
            rollNo: '204',
            parentContact: '+1-555-0204'),
        StudentModel(
            classId: phyClassId,
            name: 'Oscar Martinez',
            rollNo: '205',
            parentContact: '+1-555-0205'),
        StudentModel(
            classId: phyClassId,
            name: 'Pamela Beesly',
            rollNo: '206',
            parentContact: '+1-555-0206'),
      ];

      List<int> phyStudentIds = [];
      for (var s in phyStudents) {
        final id = await dbHelper.insertStudent(s);
        phyStudentIds.add(id);
      }

      // Applied Physics Sessions across 9 working days
      final phyTurnouts = [
        {'present': 5, 'absent': 1, 'late': 0},
        {'present': 6, 'absent': 0, 'late': 0},
        {'present': 5, 'absent': 0, 'late': 1},
        {'present': 4, 'absent': 2, 'late': 0},
        {'present': 5, 'absent': 1, 'late': 0},
        {'present': 6, 'absent': 0, 'late': 0},
      ];

      for (int d = 0; d < workingDates.length; d++) {
        final sess = phyTurnouts[d % phyTurnouts.length];
        final recordId = await dbHelper.insertAttendanceRecord(
          AttendanceRecordModel(
            classId: phyClassId,
            date: workingDates[d],
            time: '11:00 AM',
            presentCount: sess['present'] as int,
            absentCount: sess['absent'] as int,
            lateCount: sess['late'] as int,
          ),
        );

        for (int i = 0; i < phyStudentIds.length; i++) {
          final sId = phyStudentIds[i];
          AttendanceStatus st = AttendanceStatus.present;
          if (i == 3 && recordId % 2 == 0) {
            st = AttendanceStatus.absent;
          }
          await dbHelper.insertAttendance(
            AttendanceModel(studentId: sId, recordId: recordId, status: st),
          );
        }
      }

      // Timetable Slots for College
      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: csClassId,
          className: 'Computer Science & AI',
          subject: 'Data Structures & Algorithms',
          dayOfWeek: 1,
          startTime: '09:00',
          endTime: '10:30',
          roomNumber: 'Room 302',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: phyClassId,
          className: 'Applied Physics',
          subject: 'Electromagnetism & Waves',
          dayOfWeek: 2,
          startTime: '11:00',
          endTime: '12:30',
          roomNumber: 'Physics Lab 1',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: csClassId,
          className: 'Computer Science & AI',
          subject: 'Data Structures Lab',
          dayOfWeek: 3,
          startTime: '14:00',
          endTime: '16:00',
          roomNumber: 'Lab A',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: phyClassId,
          className: 'Applied Physics',
          subject: 'Wave Theory Tutorial',
          dayOfWeek: 4,
          startTime: '10:00',
          endTime: '11:30',
          roomNumber: 'Hall 105',
        ),
      );

      await dbHelper.insertTimetableSlot(
        TimetableModel(
          classId: csClassId,
          className: 'Computer Science & AI',
          subject: 'Project Mentorship',
          dayOfWeek: 5,
          startTime: '13:30',
          endTime: '15:00',
          roomNumber: 'Seminar Hall',
        ),
      );
    }
  }
}
