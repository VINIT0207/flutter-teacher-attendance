import 'package:equatable/equatable.dart';

import '../../models/class_model.dart';
import '../../models/student_model.dart';

abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object?> get props => [];
}

class LoadClasses extends ClassEvent {}

class CreateClass extends ClassEvent {
  final ClassModel classModel;
  final List<StudentModel> students;

  const CreateClass(this.classModel, [this.students = const []]);

  @override
  List<Object?> get props => [classModel, students];
}

class UpdateClass extends ClassEvent {
  final ClassModel classModel;

  const UpdateClass(this.classModel);

  @override
  List<Object?> get props => [classModel];
}

class DeleteClass extends ClassEvent {
  final int classId;

  const DeleteClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadClassDetails extends ClassEvent {
  final int classId;

  const LoadClassDetails(this.classId);

  @override
  List<Object?> get props => [classId];
}

class AddStudent extends ClassEvent {
  final StudentModel student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class AddStudents extends ClassEvent {
  final List<StudentModel> students;

  const AddStudents(this.students);

  @override
  List<Object?> get props => [students];
}

class UpdateStudent extends ClassEvent {
  final StudentModel student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends ClassEvent {
  final int studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}
