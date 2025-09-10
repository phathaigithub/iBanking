class Student {
  final String studentId; // Mã số sinh viên 8 ký tự (52200001, 52200002...)
  final String fullName;

  Student({required this.studentId, required this.fullName});

  Student copyWith({String? studentId, String? fullName}) {
    return Student(
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
    );
  }

  Map<String, dynamic> toJson() {
    return {'studentId': studentId, 'fullName': fullName};
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(studentId: json['studentId'], fullName: json['fullName']);
  }
}
