// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuition_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuitionResponse _$TuitionResponseFromJson(Map<String, dynamic> json) =>
    TuitionResponse(
      tuitionCode: json['tuitionCode'] as String,
      studentCode: json['studentCode'] as String,
      semester: json['semester'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$TuitionResponseToJson(TuitionResponse instance) =>
    <String, dynamic>{
      'tuitionCode': instance.tuitionCode,
      'studentCode': instance.studentCode,
      'semester': instance.semester,
      'amount': instance.amount,
      'status': instance.status,
    };
