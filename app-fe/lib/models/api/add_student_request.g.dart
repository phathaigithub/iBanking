// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_student_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddStudentRequest _$AddStudentRequestFromJson(Map<String, dynamic> json) =>
    AddStudentRequest(
      studentCode: json['studentCode'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      majorCode: json['majorCode'] as String,
    );

Map<String, dynamic> _$AddStudentRequestToJson(AddStudentRequest instance) =>
    <String, dynamic>{
      'studentCode': instance.studentCode,
      'name': instance.name,
      'age': instance.age,
      'email': instance.email,
      'phone': instance.phone,
      'majorCode': instance.majorCode,
    };
