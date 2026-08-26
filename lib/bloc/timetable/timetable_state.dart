import 'package:equatable/equatable.dart';
import '../../models/timetable_model.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();

  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableLoaded extends TimetableState {
  final int selectedDay;
  final List<TimetableModel> slots;
  final List<TimetableModel> allSlots;

  const TimetableLoaded({
    required this.selectedDay,
    required this.slots,
    this.allSlots = const [],
  });

  @override
  List<Object?> get props => [selectedDay, slots, allSlots];
}

class TimetableError extends TimetableState {
  final String message;

  const TimetableError(this.message);

  @override
  List<Object?> get props => [message];
}
