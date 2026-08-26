import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _settingsKey = 'classtrack_settings';

  SettingsCubit({bool autoLoad = true}) : super(const SettingsInitial()) {
    if (autoLoad) {
      loadSettings();
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_settingsKey);

      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final model = SettingsModel.fromMap(map);
        emit(SettingsLoaded(model));
      } else {
        emit(SettingsLoaded(state.settings));
      }
    } catch (_) {
      emit(SettingsLoaded(state.settings));
    }
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    emit(SettingsLoaded(newSettings));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(newSettings.toMap()));
    } catch (_) {}
  }

  Future<void> updateTeacherProfile({
    String? title,
    String? gender,
    required String name,
    String? institutionType,
    required String institute,
    required String email,
  }) async {
    final updated = state.settings.copyWith(
      teacherTitle: title ?? state.settings.teacherTitle,
      teacherGender: gender ?? state.settings.teacherGender,
      teacherName: name,
      institutionType: institutionType ?? state.settings.institutionType,
      instituteName: institute,
      teacherEmail: email,
    );
    await updateSettings(updated);
  }

  Future<void> updateDefaulterThreshold(double threshold) async {
    final updated = state.settings.copyWith(defaulterThreshold: threshold);
    await updateSettings(updated);
  }

  Future<void> updateReminderPreferences({
    required bool enable,
    required int leadMinutes,
    required bool vibration,
  }) async {
    final updated = state.settings.copyWith(
      enableLectureReminders: enable,
      reminderLeadMinutes: leadMinutes,
      enableVibration: vibration,
    );
    await updateSettings(updated);
  }

  Future<void> updateDefaultAttendanceStatus(bool presentByDefault) async {
    final updated =
        state.settings.copyWith(defaultAttendancePresent: presentByDefault);
    await updateSettings(updated);
  }

  Future<void> updateAttendanceFrequency(String frequency) async {
    final updated = state.settings.copyWith(attendanceFrequency: frequency);
    await updateSettings(updated);
  }

  Future<void> completeOnboarding() async {
    final updated = state.settings.copyWith(hasCompletedOnboarding: true);
    await updateSettings(updated);
  }

  Future<void> completeInteractiveTour() async {
    final updated = state.settings.copyWith(hasSeenInteractiveTour: true);
    await updateSettings(updated);
  }

  Future<void> resetInteractiveTour() async {
    final updated = state.settings.copyWith(hasSeenInteractiveTour: false);
    await updateSettings(updated);
  }
}
