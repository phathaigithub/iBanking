// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDetail _$StudentDetailFromJson(Map<String, dynamic> json) =>
    StudentDetail(
      id: (json['id'] as num).toInt(),
      studentCode: json['studentCode'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      majorCode: json['majorCode'] as String,
      majorName: json['majorName'] as String,
    );

Map<String, dynamic> _$StudentDetailToJson(StudentDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentCode': instance.studentCode,
      'name': instance.name,
      'age': instance.age,
      'email': instance.email,
      'phone': instance.phone,
      'majorCode': instance.majorCode,
      'majorName': instance.majorName,
    };
