import 'package:equatable/equatable.dart';

import '../../models/attendance_model.dart';
import '../../models/attendance_record_model.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSessionReady extends AttendanceState {
  final int classId;
  final List<StudentModel> students;
  final int currentIndex;
  final Map<int, AttendanceStatus> studentStatus;

  const AttendanceSessionReady({
    required this.classId,
    required this.students,
    required this.currentIndex,
    required this.studentStatus,
  });

  @override
  List<Object?> get props => [classId, students, currentIndex, studentStatus];
}

class AttendanceSessionComplete extends AttendanceState {
  final int classId;
  final List<StudentModel> students;
  final Map<int, AttendanceStatus> studentStatus;

  const AttendanceSessionComplete({
    required this.classId,
    required this.students,
    required this.studentStatus,
  });

  @override
  List<Object?> get props => [classId, students, studentStatus];
  
  // Count attendance statistics
  int get presentCount => studentStatus.values
      .where((status) => status == AttendanceStatus.present)
      .length;
      
  int get absentCount => studentStatus.values
      .where((status) => status == AttendanceStatus.absent)
      .length;
      
  int get lateCount => studentStatus.values
      .where((status) => status == AttendanceStatus.late)
      .length;
}

class AttendanceSubmitting extends AttendanceState {}

class AttendanceSubmitSuccess extends AttendanceState {}

class AttendanceRecordsLoaded extends AttendanceState {
  final List<AttendanceRecordModel> records;

  const AttendanceRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class StudentPerformanceLoaded extends AttendanceState {
  final StudentModel student;
  final Map<String, dynamic> performance;

  const StudentPerformanceLoaded(this.student, this.performance);

  @override
  List<Object?> get props => [student, performance];
}

class ClassPerformanceLoaded extends AttendanceState {
  final ClassModel classModel;
  final Map<String, dynamic> performance;

  const ClassPerformanceLoaded(this.classModel, this.performance);

  @override
  List<Object?> get props => [classModel, performance];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
