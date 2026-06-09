// ignore_for_file: unused_import

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/attendance_model.dart';
import '../../models/attendance_record_model.dart';
import '../../models/student_model.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final Database database;
  late final DatabaseHelper _dbHelper;

  AttendanceBloc(this.database) : super(AttendanceInitial()) {
    _dbHelper = DatabaseHelper(database);
    
    on<LoadAttendanceSession>(_onLoadAttendanceSession);
    on<MarkAttendance>(_onMarkAttendance);
    on<SubmitAttendance>(_onSubmitAttendance);
    on<LoadAttendanceRecords>(_onLoadAttendanceRecords);
    on<DeleteAttendanceRecord>(_onDeleteAttendanceRecord);
    on<LoadStudentPerformance>(_onLoadStudentPerformance);
    on<LoadClassPerformance>(_onLoadClassPerformance);
  }

  Future<void> _onLoadAttendanceSession(
    LoadAttendanceSession event, 
    Emitter<AttendanceState> emit
  ) async {
    try {
      emit(AttendanceLoading());
      
      final students = await _dbHelper.getStudents(event.classId);
      if (students.isEmpty) {
        emit(const AttendanceError('No students found in this class'));
        return;
      }
      
      emit(AttendanceSessionReady(
        classId: event.classId,
        students: students,
        currentIndex: 0,
        studentStatus: const {},
      ));
    } catch (e) {
      emit(AttendanceError('Failed to load students: ${e.toString()}'));
    }
  }

  void _onMarkAttendance(MarkAttendance event, Emitter<AttendanceState> emit) {
    if (state is AttendanceSessionReady) {
      final currentState = state as AttendanceSessionReady;
      
      // Update the status for the current student
      final updatedStatus = Map<int, AttendanceStatus>.from(currentState.studentStatus);
      updatedStatus[currentState.students[currentState.currentIndex].id!] = event.status;
      
      // Move to next student or complete if this was the last one
      int nextIndex = currentState.currentIndex + 1;
      
      if (nextIndex >= currentState.students.length) {
        // All students have been marked
        emit(AttendanceSessionComplete(
          classId: currentState.classId,
          students: currentState.students,
          studentStatus: updatedStatus,
        ));
      } else {
        // Move to next student
        emit(AttendanceSessionReady(
          classId: currentState.classId,
          students: currentState.students,
          currentIndex: nextIndex,
          studentStatus: updatedStatus,
        ));
      }
    }
  }

  Future<void> _onSubmitAttendance(
    SubmitAttendance event, 
    Emitter<AttendanceState> emit
  ) async {
    print('_onSubmitAttendance called with state: ${state.runtimeType}');
    
    if (state is AttendanceSessionComplete) {
      try {
        // IMPORTANT: Save a reference to the current state BEFORE changing it
        final completeState = state as AttendanceSessionComplete;
        
        // Now it's safe to emit the new state
        emit(AttendanceSubmitting());
        print('AttendanceSubmitting state emitted');
        
        final today = DateTime.now().toIso8601String().split('T')[0];
        final time = DateTime.now().toIso8601String().split('T')[1].substring(0, 5);
        
        print('Processing attendance for date: $today, time: $time');
        
        // Count status
        int presentCount = 0;
        int absentCount = 0;
        int lateCount = 0;
        
        completeState.studentStatus.forEach((studentId, status) {
          print('Student $studentId: ${status.toString()}');
          if (status == AttendanceStatus.present) {
            presentCount++;
          } else if (status == AttendanceStatus.absent) {
            absentCount++;
          } else if (status == AttendanceStatus.late) {
            lateCount++;
          }
        });
        
        print('Counts - Present: $presentCount, Absent: $absentCount, Late: $lateCount');
        
        // Create attendance record
        final recordModel = AttendanceRecordModel(
          classId: completeState.classId,
          date: today,
          time: time,
          presentCount: presentCount,
          absentCount: absentCount,
          lateCount: lateCount,
        );
        
        print('Inserting attendance record...');
        final recordId = await _dbHelper.insertAttendanceRecord(recordModel);
        print('Attendance record created with ID: $recordId');
        
        // Create individual attendance entries
        print('Creating individual attendance entries...');
        for (var entry in completeState.studentStatus.entries) {
          await _dbHelper.insertAttendance(AttendanceModel(
            studentId: entry.key,
            recordId: recordId,
            status: entry.value,
          ));
        }
        
        // Update class last attendance date
        print('Updating class last attendance date...');
        await _dbHelper.updateClassAttendanceDate(completeState.classId, today);
        
        print('Attendance submission successful!');
        emit(AttendanceSubmitSuccess());
      } catch (e) {
        print('Error during attendance submission: ${e.toString()}');
        emit(AttendanceError('Failed to save attendance: ${e.toString()}'));
      }
    } else {
      print('Cannot submit attendance: state is not AttendanceSessionComplete, it is ${state.runtimeType}');
      emit(const AttendanceError('Cannot submit attendance: session not complete'));
    }
  }

  Future<void> _onLoadAttendanceRecords(
    LoadAttendanceRecords event, 
    Emitter<AttendanceState> emit
  ) async {
    try {
      emit(AttendanceLoading());
      
      final records = await _dbHelper.getAttendanceRecords(event.classId);
      emit(AttendanceRecordsLoaded(records));
    } catch (e) {
      emit(AttendanceError('Failed to load attendance records: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAttendanceRecord(
    DeleteAttendanceRecord event, 
    Emitter<AttendanceState> emit
  ) async {
    try {
      emit(AttendanceLoading());
      
      await _dbHelper.deleteAttendanceRecord(event.recordId);
      add(LoadAttendanceRecords(event.classId));
    } catch (e) {
      emit(AttendanceError('Failed to delete attendance record: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStudentPerformance(
    LoadStudentPerformance event, 
    Emitter<AttendanceState> emit
  ) async {
    try {
      emit(AttendanceLoading());
      
      final student = await _dbHelper.getStudent(event.studentId);
      if (student == null) {
        emit(const AttendanceError('Student not found'));
        return;
      }
      
      final performance = await _dbHelper.getStudentPerformance(event.studentId);
      emit(StudentPerformanceLoaded(student, performance));
    } catch (e) {
      emit(AttendanceError('Failed to load student performance: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassPerformance(
    LoadClassPerformance event, 
    Emitter<AttendanceState> emit
  ) async {
    try {
      emit(AttendanceLoading());
      
      final classModel = await _dbHelper.getClass(event.classId);
      if (classModel == null) {
        emit(const AttendanceError('Class not found'));
        return;
      }
      
      final performance = await _dbHelper.getClassPerformance(event.classId);
      emit(ClassPerformanceLoaded(classModel, performance));
    } catch (e) {
      emit(AttendanceError('Failed to load class performance: ${e.toString()}'));
    }
  }
}
