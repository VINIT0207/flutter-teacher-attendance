import 'package:equatable/equatable.dart';

import '../../models/class_model.dart';
import '../../models/student_model.dart';

abstract class ClassState extends Equatable {
  const ClassState();

  @override
  List<Object?> get props => [];
}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassesLoaded extends ClassState {
  final List<ClassModel> classes;

  const ClassesLoaded(this.classes);

  @override
  List<Object?> get props => [classes];
}

class ClassDetailsLoaded extends ClassState {
  final ClassModel classModel;
  final List<StudentModel> students;

  const ClassDetailsLoaded(this.classModel, this.students);

  @override
  List<Object?> get props => [classModel, students];
}

class ClassError extends ClassState {
  final String message;

  const ClassError(this.message);

  @override
  List<Object?> get props => [message];
}
