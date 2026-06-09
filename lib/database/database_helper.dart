import 'package:sqflite/sqflite.dart';

import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_record_model.dart';

class DatabaseHelper {
  final Database database;

  DatabaseHelper(this.database);

  // Class CRUD operations
  Future<int> insertClass(ClassModel classModel) async {
    return await database.insert('classes', classModel.toMap());
  }
  
  Future<List<ClassModel>> getClasses() async {
    final List<Map<String, dynamic>> maps = await database.query('classes');
    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }
  
  Future<ClassModel?> getClass(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ClassModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> updateClass(ClassModel classModel) async {
    return await database.update(
      'classes',
      classModel.toMap(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }
  
  Future<int> updateClassAttendanceDate(int classId, String date) async {
    return await database.update(
      'classes',
      {'lastAttendanceDate': date},
      where: 'id = ?',
      whereArgs: [classId],
    );
  }
  
  Future<int> deleteClass(int id) async {
    return await database.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Student CRUD operations
  Future<int> insertStudent(StudentModel student) async {
    return await database.insert('students', student.toMap());
  }
  
  Future<List<StudentModel>> getStudents(int classId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'students',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'rollNo ASC',
    );
    
    return List.generate(maps.length, (i) {
      return StudentModel.fromMap(maps[i]);
    });
  }
  
  Future<StudentModel?> getStudent(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> updateStudent(StudentModel student) async {
    return await database.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }
  
  Future<int> deleteStudent(int id) async {
    return await database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> getStudentCount(int classId) async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE classId = ?',
      [classId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  // Attendance Records operations
  Future<int> insertAttendanceRecord(AttendanceRecordModel record) async {
    final id = await database.insert('attendance_records', record.toMap());
    await updateClassAttendanceDate(record.classId, record.date);
    return id;
  }
  
  Future<List<AttendanceRecordModel>> getAttendanceRecords(int classId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'attendance_records',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'date DESC, time DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AttendanceRecordModel.fromMap(maps[i]);
    });
  }
  
  Future<AttendanceRecordModel?> getAttendanceRecord(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'attendance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return AttendanceRecordModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> deleteAttendanceRecord(int id) async {
    return await database.delete(
      'attendance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Attendance operations
  Future<int> insertAttendance(AttendanceModel attendance) async {
    return await database.insert('attendance', attendance.toMap());
  }
  
  Future<List<AttendanceModel>> getAttendanceByRecord(int recordId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'attendance',
      where: 'recordId = ?',
      whereArgs: [recordId],
    );
    
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }
  
  Future<List<AttendanceModel>> getStudentAttendance(int studentId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }
  
  // Get student performance data
  Future<Map<String, dynamic>> getStudentPerformance(int studentId) async {
    final presentResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE studentId = ? AND status = ?',
      [studentId, AttendanceStatus.present.index],
    );
    
    final absentResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE studentId = ? AND status = ?',
      [studentId, AttendanceStatus.absent.index],
    );
    
    final lateResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE studentId = ? AND status = ?',
      [studentId, AttendanceStatus.late.index],
    );
    
    final present = Sqflite.firstIntValue(presentResult) ?? 0;
    final absent = Sqflite.firstIntValue(absentResult) ?? 0;
    final late = Sqflite.firstIntValue(lateResult) ?? 0;
    final total = present + absent + late;
    
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'total': total,
      'percentage': total > 0 ? (present / total * 100).toStringAsFixed(1) : '0'
    };
  }
  
  // Get class performance data
  Future<Map<String, dynamic>> getClassPerformance(int classId) async {
    final records = await getAttendanceRecords(classId);
    final students = await getStudents(classId);
    
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    
    for (var record in records) {
      totalPresent += record.presentCount;
      totalAbsent += record.absentCount;
      totalLate += record.lateCount;
    }
    
    final totalAttendance = totalPresent + totalAbsent + totalLate;
    final avgAttendance = totalAttendance > 0 
        ? (totalPresent / totalAttendance * 100).toStringAsFixed(1) 
        : '0';
    
    // Get attendance chart data
    List<Map<String, dynamic>> chartData = [];
    // Sort records by date
    records.sort((a, b) => a.date.compareTo(b.date));
    // Take the last 7 records for the chart (or all if less than 7)
    final lastRecords = records.length > 7 
        ? records.sublist(records.length - 7) 
        : records;
    
    for (var record in lastRecords) {
      final totalForDay = record.presentCount + record.absentCount + record.lateCount;
      final percentage = totalForDay > 0 
          ? (record.presentCount / totalForDay) * 100 
          : 0.0;
      
      chartData.add({
        'date': record.date,
        'label': 'Day ${chartData.length + 1}',
        'percentage': percentage,
      });
    }
        
    // Get students with attendance below 75%
    List<Map<String, dynamic>> defaulters = [];
    for (var student in students) {
      final perf = await getStudentPerformance(student.id!);
      if (double.parse(perf['percentage']) < 75.0) {
        defaulters.add({
          'student': student,
          'performance': perf,
        });
      }
    }
    
    return {
      'totalClasses': records.length,
      'avgAttendance': avgAttendance,
      'defaulters': defaulters,
      'chartData': chartData,
    };
  }
  
  // Insert multiple students at once (for CSV import)
  Future<void> insertStudents(List<StudentModel> students) async {
    final batch = database.batch();
    for (var student in students) {
      batch.insert('students', student.toMap());
    }
    await batch.commit(noResult: true);
    
    // Update class total students count
    if (students.isNotEmpty) {
      final classId = students.first.classId;
      final count = await getStudentCount(classId);
      final classData = await getClass(classId);
      if (classData != null) {
        await updateClass(classData.copyWith(totalStudents: count));
      }
    }
  }
}
