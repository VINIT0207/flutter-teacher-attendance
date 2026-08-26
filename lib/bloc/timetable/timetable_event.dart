import 'package:equatable/equatable.dart';
import '../../models/timetable_model.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimetableForDay extends TimetableEvent {
  final int dayOfWeek; // 1 = Mon ... 7 = Sun

  const LoadTimetableForDay(this.dayOfWeek);

  @override
  List<Object?> get props => [dayOfWeek];
}

class LoadAllTimetable extends TimetableEvent {}

class AddTimetableSlot extends TimetableEvent {
  final TimetableModel slot;

  const AddTimetableSlot(this.slot);

  @override
  List<Object?> get props => [slot];
}

class UpdateTimetableSlotEvent extends TimetableEvent {
  final TimetableModel slot;

  const UpdateTimetableSlotEvent(this.slot);

  @override
  List<Object?> get props => [slot];
}

class DeleteTimetableSlotEvent extends TimetableEvent {
  final int id;
  final int dayOfWeek;

  const DeleteTimetableSlotEvent(this.id, this.dayOfWeek);

  @override
  List<Object?> get props => [id, dayOfWeek];
}
