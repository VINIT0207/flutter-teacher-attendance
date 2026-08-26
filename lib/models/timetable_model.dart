class TimetableModel {
  final int? id;
  final int classId;
  final String className;
  final String subject;
  final int dayOfWeek; // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  final String startTime; // "HH:mm" (24-hour format)
  final String endTime; // "HH:mm"
  final String roomNumber;

  const TimetableModel({
    this.id,
    required this.classId,
    required this.className,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String get shortDayName {
    switch (dayOfWeek) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String get formattedTimeSlot {
    return '$startTime - $endTime';
  }

  TimetableModel copyWith({
    int? id,
    int? classId,
    String? className,
    String? subject,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? roomNumber,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      id: map['id'] as int?,
      classId: map['classId'] as int,
      className: map['className'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      dayOfWeek: map['dayOfWeek'] as int? ?? 1,
      startTime: map['startTime'] as String? ?? '09:00',
      endTime: map['endTime'] as String? ?? '10:00',
      roomNumber: map['roomNumber'] as String? ?? '',
    );
  }
}
