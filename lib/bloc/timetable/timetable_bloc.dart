import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final Database database;
  late final DatabaseHelper _dbHelper;
  final NotificationService _notificationService = NotificationService();

  TimetableBloc(this.database) : super(TimetableInitial()) {
    _dbHelper = DatabaseHelper(database);

    on<LoadTimetableForDay>(_onLoadTimetableForDay);
    on<LoadAllTimetable>(_onLoadAllTimetable);
    on<AddTimetableSlot>(_onAddTimetableSlot);
    on<UpdateTimetableSlotEvent>(_onUpdateTimetableSlot);
    on<DeleteTimetableSlotEvent>(_onDeleteTimetableSlot);
  }

  Future<void> _onLoadTimetableForDay(
    LoadTimetableForDay event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      emit(TimetableLoading());
      final slots = await _dbHelper.getTimetableSlotsByDay(event.dayOfWeek);
      final allSlots = await _dbHelper.getAllTimetableSlots();
      emit(TimetableLoaded(
        selectedDay: event.dayOfWeek,
        slots: slots,
        allSlots: allSlots,
      ));
    } catch (e) {
      emit(TimetableError('Failed to load timetable: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllTimetable(
    LoadAllTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      emit(TimetableLoading());
      final today = DateTime.now().weekday; // 1 = Mon ... 7 = Sun
      final slots = await _dbHelper.getTimetableSlotsByDay(today);
      final allSlots = await _dbHelper.getAllTimetableSlots();
      emit(TimetableLoaded(
        selectedDay: today,
        slots: slots,
        allSlots: allSlots,
      ));
    } catch (e) {
      emit(TimetableError('Failed to load timetable: ${e.toString()}'));
    }
  }

  Future<void> _onAddTimetableSlot(
    AddTimetableSlot event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      emit(TimetableLoading());
      final id = await _dbHelper.insertTimetableSlot(event.slot);
      final savedSlot = event.slot.copyWith(id: id);

      // Trigger lecture reminder notification setup
      await _notificationService.scheduleLectureReminder(
        slot: savedSlot,
        leadMinutes: 10,
      );

      final slots =
          await _dbHelper.getTimetableSlotsByDay(event.slot.dayOfWeek);
      final allSlots = await _dbHelper.getAllTimetableSlots();
      emit(TimetableLoaded(
        selectedDay: event.slot.dayOfWeek,
        slots: slots,
        allSlots: allSlots,
      ));
    } catch (e) {
      emit(TimetableError('Failed to add lecture slot: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTimetableSlot(
    UpdateTimetableSlotEvent event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      emit(TimetableLoading());
      await _dbHelper.updateTimetableSlot(event.slot);

      final slots =
          await _dbHelper.getTimetableSlotsByDay(event.slot.dayOfWeek);
      final allSlots = await _dbHelper.getAllTimetableSlots();
      emit(TimetableLoaded(
        selectedDay: event.slot.dayOfWeek,
        slots: slots,
        allSlots: allSlots,
      ));
    } catch (e) {
      emit(TimetableError('Failed to update lecture slot: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTimetableSlot(
    DeleteTimetableSlotEvent event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      emit(TimetableLoading());
      await _dbHelper.deleteTimetableSlot(event.id);

      final slots = await _dbHelper.getTimetableSlotsByDay(event.dayOfWeek);
      final allSlots = await _dbHelper.getAllTimetableSlots();
      emit(TimetableLoaded(
        selectedDay: event.dayOfWeek,
        slots: slots,
        allSlots: allSlots,
      ));
    } catch (e) {
      emit(TimetableError('Failed to delete lecture slot: ${e.toString()}'));
    }
  }
}
