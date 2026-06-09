class AttendanceRecordModel {
  final int? id;
  final int classId;
  final String date;
  final String time;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  
  AttendanceRecordModel({
    this.id,
    required this.classId,
    required this.date,
    required this.time,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'date': date,
      'time': time,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'lateCount': lateCount,
    };
  }
  
  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: map['id'],
      classId: map['classId'],
      date: map['date'],
      time: map['time'],
      presentCount: map['presentCount'],
      absentCount: map['absentCount'],
      lateCount: map['lateCount'],
    );
  }
  
  // Get total students
  int get totalStudents => presentCount + absentCount + lateCount;
  
  // Calculate attendance percentage
  double get attendancePercentage => 
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;

  get attendances => null;
}
