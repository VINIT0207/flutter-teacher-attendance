class StudentModel {
  final int? id;
  final int classId;
  final String name;
  final String rollNo;
  final String parentContact;
  
  StudentModel({
    this.id,
    required this.classId,
    required this.name,
    required this.rollNo,
    required this.parentContact,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'rollNo': rollNo,
      'parentContact': parentContact,
    };
  }
  
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'],
      classId: map['classId'],
      name: map['name'],
      rollNo: map['rollNo'],
      parentContact: map['parentContact'],
    );
  }
  
  StudentModel copyWith({
    int? id,
    int? classId,
    String? name,
    String? rollNo,
    String? parentContact,
  }) {
    return StudentModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      parentContact: parentContact ?? this.parentContact,
    );
  }
}
