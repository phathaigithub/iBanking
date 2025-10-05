// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuition_inquiry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuitionInquiryResponse _$TuitionInquiryResponseFromJson(
  Map<String, dynamic> json,
) => TuitionInquiryResponse(
  student: StudentInfo.fromJson(json['student'] as Map<String, dynamic>),
  tuitions: (json['tuitions'] as List<dynamic>)
      .map((e) => TuitionInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TuitionInquiryResponseToJson(
  TuitionInquiryResponse instance,
) => <String, dynamic>{
  'student': instance.student,
  'tuitions': instance.tuitions,
};

StudentInfo _$StudentInfoFromJson(Map<String, dynamic> json) => StudentInfo(
  studentCode: json['studentCode'] as String,
  name: json['name'] as String,
  majorCode: json['majorCode'] as String,
  majorName: json['majorName'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$StudentInfoToJson(StudentInfo instance) =>
    <String, dynamic>{
      'studentCode': instance.studentCode,
      'name': instance.name,
      'majorCode': instance.majorCode,
      'majorName': instance.majorName,
      'email': instance.email,
    };

TuitionInfo _$TuitionInfoFromJson(Map<String, dynamic> json) => TuitionInfo(
  tuitionId: json['tuitionId'] as String,
  semester: json['semester'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  dueDate: json['dueDate'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$TuitionInfoToJson(TuitionInfo instance) =>
    <String, dynamic>{
      'tuitionId': instance.tuitionId,
      'semester': instance.semester,
      'amount': instance.amount,
      'status': instance.status,
      'dueDate': instance.dueDate,
      'createdAt': instance.createdAt,
    };
