class ClassModel {
  final int? id;
  final String name;
  final String subject;
  final String year;
  final int totalStudents;
  final String? lastAttendanceDate;
  
  ClassModel({
    this.id,
    required this.name,
    required this.subject,
    required this.year,
    this.totalStudents = 0,
    this.lastAttendanceDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'year': year,
      'totalStudents': totalStudents,
      'lastAttendanceDate': lastAttendanceDate,
    };
  }
  
  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      year: map['year'],
      totalStudents: map['totalStudents'],
      lastAttendanceDate: map['lastAttendanceDate'],
    );
  }
  
  ClassModel copyWith({
    int? id,
    String? name,
    String? subject,
    String? year,
    int? totalStudents,
    String? lastAttendanceDate,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      year: year ?? this.year,
      totalStudents: totalStudents ?? this.totalStudents,
      lastAttendanceDate: lastAttendanceDate ?? this.lastAttendanceDate,
    );
  }
}
