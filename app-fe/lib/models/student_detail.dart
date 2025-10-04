import 'package:json_annotation/json_annotation.dart';

part 'student_detail.g.dart';

@JsonSerializable()
class StudentDetail {
  final int id;
  final String studentCode;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String majorCode;
  final String majorName;

  StudentDetail({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.majorCode,
    required this.majorName,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) =>
      _$StudentDetailFromJson(json);

  Map<String, dynamic> toJson() => _$StudentDetailToJson(this);
}
