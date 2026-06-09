import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/models/student_model.dart';
import 'package:teacher_attendance_app/models/attendance_model.dart';
import 'package:teacher_attendance_app/models/attendance_record_model.dart';

void main() {
  group('Model Tests', () {
    test('ClassModel correctly initializes and converts to/from map', () {
      // Create a class model
      final classModel = ClassModel(
        id: 1,
        name: 'Computer Science',
        subject: 'Programming',
        year: 'FY',
        totalStudents: 30,
        lastAttendanceDate: '2023-05-01',
      );

      // Convert to map
      final map = classModel.toMap();

      // Convert back from map
      final convertedModel = ClassModel.fromMap(map);

      // Check if the model is correctly converted
      expect(convertedModel.id, classModel.id);
      expect(convertedModel.name, classModel.name);
      expect(convertedModel.subject, classModel.subject);
      expect(convertedModel.year, classModel.year);
      expect(convertedModel.totalStudents, classModel.totalStudents);
      expect(convertedModel.lastAttendanceDate, classModel.lastAttendanceDate);
    });

    test('StudentModel correctly initializes and converts to/from map', () {
      // Create a student model
      final studentModel = StudentModel(
        id: 1,
        classId: 1,
        name: 'John Doe',
        rollNo: '101',
        parentContact: '1234567890',
      );

      // Convert to map
      final map = studentModel.toMap();

      // Convert back from map
      final convertedModel = StudentModel.fromMap(map);

      // Check if the model is correctly converted
      expect(convertedModel.id, studentModel.id);
      expect(convertedModel.classId, studentModel.classId);
      expect(convertedModel.name, studentModel.name);
      expect(convertedModel.rollNo, studentModel.rollNo);
      expect(convertedModel.parentContact, studentModel.parentContact);
    });

    test('AttendanceModel correctly initializes and converts to/from map', () {
      // Create an attendance model
      final attendanceModel = AttendanceModel(
        id: 1,
        studentId: 1,
        recordId: 1,
        status: AttendanceStatus.present,
      );

      // Convert to map
      final map = attendanceModel.toMap();

      // Convert back from map
      final convertedModel = AttendanceModel.fromMap(map);

      // Check if the model is correctly converted
      expect(convertedModel.id, attendanceModel.id);
      expect(convertedModel.studentId, attendanceModel.studentId);
      expect(convertedModel.recordId, attendanceModel.recordId);
      expect(convertedModel.status, attendanceModel.status);
    });

    test('AttendanceRecordModel correctly initializes and calculates values', () {
      // Create an attendance record model
      final recordModel = AttendanceRecordModel(
        id: 1,
        classId: 1,
        date: '2023-05-01',
        time: '10:00',
        presentCount: 25,
        absentCount: 3,
        lateCount: 2,
      );

      // Check calculated values
      expect(recordModel.totalStudents, 30);
      expect(recordModel.attendancePercentage, (25 / 30) * 100);
    });

    test('AttendanceStatus extension provides correct labels', () {
      expect(AttendanceStatus.present.label, 'Present');
      expect(AttendanceStatus.absent.label, 'Absent');
      expect(AttendanceStatus.late.label, 'Late');
    });
  });
}