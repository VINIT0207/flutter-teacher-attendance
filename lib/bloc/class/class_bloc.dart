// ignore_for_file: unused_import

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import 'class_event.dart';
import 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final Database database;
  late final DatabaseHelper _dbHelper;

  ClassBloc(this.database) : super(ClassInitial()) {
    _dbHelper = DatabaseHelper(database);
    
    on<LoadClasses>(_onLoadClasses);
    on<CreateClass>(_onCreateClass);
    on<UpdateClass>(_onUpdateClass);
    on<DeleteClass>(_onDeleteClass);
    on<LoadClassDetails>(_onLoadClassDetails);
    on<AddStudent>(_onAddStudent);
    on<AddStudents>(_onAddStudents);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
  }

  Future<void> _onLoadClasses(LoadClasses event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      // Always fetch fresh data from the database
      final classes = await _dbHelper.getClasses();
      
      emit(ClassesLoaded(classes));
    } catch (e) {
      emit(ClassError('Failed to load classes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateClass(CreateClass event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      final classId = await _dbHelper.insertClass(event.classModel);
      final newClass = event.classModel.copyWith(id: classId);
      
      if (event.students.isNotEmpty) {
        final studentsWithClassId = event.students
            .map((student) => student.copyWith(classId: classId))
            .toList();
        await _dbHelper.insertStudents(studentsWithClassId);
        
        // Update totalStudents count
        final count = await _dbHelper.getStudentCount(classId);
        await _dbHelper.updateClass(newClass.copyWith(totalStudents: count));
      }
      
      add(LoadClasses());
    } catch (e) {
      emit(ClassError('Failed to create class: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateClass(UpdateClass event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      await _dbHelper.updateClass(event.classModel);
      add(LoadClasses());
    } catch (e) {
      emit(ClassError('Failed to update class: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteClass(DeleteClass event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      await _dbHelper.deleteClass(event.classId);
      add(LoadClasses());
    } catch (e) {
      emit(ClassError('Failed to delete class: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassDetails(LoadClassDetails event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      // Always fetch fresh data from the database
      final classModel = await _dbHelper.getClass(event.classId);
      if (classModel == null) {
        emit(const ClassError('Class not found'));
        return;
      }
      
      final students = await _dbHelper.getStudents(event.classId);
      emit(ClassDetailsLoaded(classModel, students));
    } catch (e) {
      emit(ClassError('Failed to load class details: ${e.toString()}'));
    }
  }

  Future<void> _onAddStudent(AddStudent event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      await _dbHelper.insertStudent(event.student);
      
      // Update class totalStudents count
      final count = await _dbHelper.getStudentCount(event.student.classId);
      final classModel = await _dbHelper.getClass(event.student.classId);
      if (classModel != null) {
        await _dbHelper.updateClass(classModel.copyWith(totalStudents: count));
      }
      
      add(LoadClassDetails(event.student.classId));
    } catch (e) {
      emit(ClassError('Failed to add student: ${e.toString()}'));
    }
  }

  Future<void> _onAddStudents(AddStudents event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      await _dbHelper.insertStudents(event.students);
      
      // Update class totalStudents count
      if (event.students.isNotEmpty) {
        final classId = event.students.first.classId;
        final count = await _dbHelper.getStudentCount(classId);
        final classModel = await _dbHelper.getClass(classId);
        if (classModel != null) {
          await _dbHelper.updateClass(classModel.copyWith(totalStudents: count));
        }
        
        add(LoadClassDetails(classId));
      }
    } catch (e) {
      emit(ClassError('Failed to add students: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStudent(UpdateStudent event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      await _dbHelper.updateStudent(event.student);
      add(LoadClassDetails(event.student.classId));
    } catch (e) {
      emit(ClassError('Failed to update student: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteStudent(DeleteStudent event, Emitter<ClassState> emit) async {
    try {
      emit(ClassLoading());
      
      final student = await _dbHelper.getStudent(event.studentId);
      if (student == null) {
        emit(const ClassError('Student not found'));
        return;
      }
      
      await _dbHelper.deleteStudent(event.studentId);
      
      // Update class totalStudents count
      final count = await _dbHelper.getStudentCount(student.classId);
      final classModel = await _dbHelper.getClass(student.classId);
      if (classModel != null) {
        await _dbHelper.updateClass(classModel.copyWith(totalStudents: count));
      }
      
      add(LoadClassDetails(student.classId));
    } catch (e) {
      emit(ClassError('Failed to delete student: ${e.toString()}'));
    }
  }
}