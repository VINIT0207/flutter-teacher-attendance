enum AttendanceStatus { present, absent, late }

class AttendanceModel {
  final int? id;
  final int studentId;
  final int recordId;
  final AttendanceStatus status;
  
  AttendanceModel({
    this.id,
    required this.studentId,
    required this.recordId,
    required this.status,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'recordId': recordId,
      'status': status.index,
    };
  }
  
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      studentId: map['studentId'],
      recordId: map['recordId'],
      status: AttendanceStatus.values[map['status']],
    );
  }
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
}
