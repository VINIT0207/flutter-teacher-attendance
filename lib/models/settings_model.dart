class SettingsModel {
  final String teacherTitle; // 'Professor', 'Sir', 'Miss', 'Dr.', 'Mr.', 'Ms.'
  final String teacherGender; // 'Male', 'Female', 'Other', 'Unspecified'
  final String teacherName;
  final String institutionType; // 'University', 'College', 'School', 'Institute'
  final String instituteName;
  final String teacherEmail;
  final String attendanceFrequency; // 'daily' (Full-Day / School), 'lecture' (Per Lecture / College)
  final double defaulterThreshold; // e.g. 75.0
  final bool
      defaultAttendancePresent; // true = Default all present, false = unmarked
  final bool enableLectureReminders;
  final int reminderLeadMinutes; // 5, 10, 15, 30
  final bool enableVibration;
  final bool hasCompletedOnboarding;
  final bool hasSeenInteractiveTour;

  const SettingsModel({
    this.teacherTitle = 'Professor',
    this.teacherGender = 'Unspecified',
    this.teacherName = 'Professor',
    this.institutionType = 'University',
    this.instituteName = 'Department of Science',
    this.teacherEmail = '',
    this.attendanceFrequency = 'lecture',
    this.defaulterThreshold = 75.0,
    this.defaultAttendancePresent = true,
    this.enableLectureReminders = true,
    this.reminderLeadMinutes = 10,
    this.enableVibration = true,
    this.hasCompletedOnboarding = false,
    this.hasSeenInteractiveTour = false,
  });

  /// Returns true if full-day single roll call mode is active (default for schools)
  bool get isDailyAttendanceMode {
    final freq = attendanceFrequency.trim().toUpperCase();
    if (freq == 'FULL_DAY' || freq == 'DAILY') return true;
    if (freq == 'PERIOD_WISE' || freq == 'LECTURE') return false;
    return institutionType.trim().toLowerCase() == 'school';
  }

  /// Formatted short salutation for welcoming on dashboard, e.g. "Sir Alex", "Miss Priya", "Professor Smith"
  String get formattedSalutation {
    final cleanName = teacherName.trim();
    if (cleanName.isEmpty || cleanName.toLowerCase() == 'professor') {
      return teacherTitle;
    }
    final firstName = cleanName.split(' ').first;
    if (teacherTitle == 'Sir' || teacherTitle == 'Miss') {
      return '$teacherTitle $firstName';
    }
    if (cleanName.startsWith(teacherTitle)) {
      return cleanName;
    }
    return '$teacherTitle $cleanName';
  }

  /// Full title with full name for reports, parent notices, etc., e.g. "Sir Alex Smith", "Miss Priya Patel"
  String get fullTeacherTitle {
    final cleanName = teacherName.trim();
    if (cleanName.isEmpty) return teacherTitle;
    if (cleanName.startsWith(teacherTitle)) return cleanName;
    return '$teacherTitle $cleanName';
  }

  /// Full institutional signature for parent notices and report exports
  String get fullInstitutionalSignature {
    final inst = instituteName.trim();
    if (inst.isEmpty) return fullTeacherTitle;
    return '$fullTeacherTitle ($inst)';
  }

  SettingsModel copyWith({
    String? teacherTitle,
    String? teacherGender,
    String? teacherName,
    String? institutionType,
    String? instituteName,
    String? teacherEmail,
    String? attendanceFrequency,
    double? defaulterThreshold,
    bool? defaultAttendancePresent,
    bool? enableLectureReminders,
    int? reminderLeadMinutes,
    bool? enableVibration,
    bool? hasCompletedOnboarding,
    bool? hasSeenInteractiveTour,
  }) {
    return SettingsModel(
      teacherTitle: teacherTitle ?? this.teacherTitle,
      teacherGender: teacherGender ?? this.teacherGender,
      teacherName: teacherName ?? this.teacherName,
      institutionType: institutionType ?? this.institutionType,
      instituteName: instituteName ?? this.instituteName,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      attendanceFrequency: attendanceFrequency ?? this.attendanceFrequency,
      defaulterThreshold: defaulterThreshold ?? this.defaulterThreshold,
      defaultAttendancePresent:
          defaultAttendancePresent ?? this.defaultAttendancePresent,
      enableLectureReminders:
          enableLectureReminders ?? this.enableLectureReminders,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      enableVibration: enableVibration ?? this.enableVibration,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasSeenInteractiveTour:
          hasSeenInteractiveTour ?? this.hasSeenInteractiveTour,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherTitle': teacherTitle,
      'teacherGender': teacherGender,
      'teacherName': teacherName,
      'institutionType': institutionType,
      'instituteName': instituteName,
      'teacherEmail': teacherEmail,
      'attendanceFrequency': attendanceFrequency,
      'defaulterThreshold': defaulterThreshold,
      'defaultAttendancePresent': defaultAttendancePresent ? 1 : 0,
      'enableLectureReminders': enableLectureReminders ? 1 : 0,
      'reminderLeadMinutes': reminderLeadMinutes,
      'enableVibration': enableVibration ? 1 : 0,
      'hasCompletedOnboarding': hasCompletedOnboarding ? 1 : 0,
      'hasSeenInteractiveTour': hasSeenInteractiveTour ? 1 : 0,
    };
  }

  static bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val == null) return fallback;
    if (val is bool) return val;
    if (val is num) return val == 1;
    if (val is String) return val.toLowerCase() == 'true' || val == '1';
    return fallback;
  }

  static double _parseDouble(dynamic val, [double fallback = 75.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  static int _parseInt(dynamic val, [int fallback = 10]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    final instType = map['institutionType'] as String? ?? 'University';
    final rawFreq = map['attendanceFrequency'] as String?;
    String freq;
    if (rawFreq != null && rawFreq.isNotEmpty) {
      final upper = rawFreq.trim().toUpperCase();
      if (upper == 'FULL_DAY' || upper == 'DAILY') {
        freq = 'FULL_DAY';
      } else {
        freq = 'PERIOD_WISE';
      }
    } else {
      freq = instType.trim().toLowerCase() == 'school'
          ? 'FULL_DAY'
          : 'PERIOD_WISE';
    }

    return SettingsModel(
      teacherTitle: map['teacherTitle'] as String? ?? 'Professor',
      teacherGender: map['teacherGender'] as String? ?? 'Unspecified',
      teacherName: map['teacherName'] as String? ?? 'Professor',
      institutionType: instType,
      instituteName: map['instituteName'] as String? ?? 'Department of Science',
      teacherEmail: map['teacherEmail'] as String? ?? '',
      attendanceFrequency: freq,
      defaulterThreshold: _parseDouble(map['defaulterThreshold'], 75.0),
      defaultAttendancePresent:
          _parseBool(map['defaultAttendancePresent'], true),
      enableLectureReminders:
          _parseBool(map['enableLectureReminders'], true),
      reminderLeadMinutes: _parseInt(map['reminderLeadMinutes'], 10),
      enableVibration: _parseBool(map['enableVibration'], true),
      hasCompletedOnboarding:
          _parseBool(map['hasCompletedOnboarding'], false),
      hasSeenInteractiveTour:
          _parseBool(map['hasSeenInteractiveTour'], false),
    );
  }
}
