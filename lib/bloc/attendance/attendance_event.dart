import 'package:equatable/equatable.dart';
import '../../models/attendance_model.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceSession extends AttendanceEvent {
  final int classId;

  const LoadAttendanceSession(this.classId);

  @override
  List<Object?> get props => [classId];
}

class MarkAttendance extends AttendanceEvent {
  final AttendanceStatus status;

  const MarkAttendance(this.status, int studentId);

  @override
  List<Object?> get props => [status];
}

class SubmitAttendance extends AttendanceEvent {}

class LoadAttendanceRecords extends AttendanceEvent {
  final int classId;

  const LoadAttendanceRecords(this.classId);

  @override
  List<Object?> get props => [classId];
}

class DeleteAttendanceRecord extends AttendanceEvent {
  final int recordId;
  final int classId;

  const DeleteAttendanceRecord(this.recordId, this.classId);

  @override
  List<Object?> get props => [recordId, classId];
}

class LoadStudentPerformance extends AttendanceEvent {
  final int studentId;

  const LoadStudentPerformance(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadClassPerformance extends AttendanceEvent {
  final int classId;

  const LoadClassPerformance(this.classId);

  @override
  List<Object?> get props => [classId];
}
