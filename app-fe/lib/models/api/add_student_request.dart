import 'package:json_annotation/json_annotation.dart';

part 'add_student_request.g.dart';

@JsonSerializable()
class AddStudentRequest {
  final String studentCode;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String majorCode;

  AddStudentRequest({
    required this.studentCode,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.majorCode,
  });

  factory AddStudentRequest.fromJson(Map<String, dynamic> json) =>
      _$AddStudentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddStudentRequestToJson(this);
}
