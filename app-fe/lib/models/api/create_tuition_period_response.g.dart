// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tuition_period_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTuitionPeriodResponse _$CreateTuitionPeriodResponseFromJson(
  Map<String, dynamic> json,
) => CreateTuitionPeriodResponse(
  semester: json['semester'] as String,
  majorCode: json['majorCode'] as String,
  tuitions: (json['tuitions'] as List<dynamic>)
      .map((e) => TuitionInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateTuitionPeriodResponseToJson(
  CreateTuitionPeriodResponse instance,
) => <String, dynamic>{
  'semester': instance.semester,
  'majorCode': instance.majorCode,
  'tuitions': instance.tuitions,
};

TuitionInfo _$TuitionInfoFromJson(Map<String, dynamic> json) => TuitionInfo(
  tuitionCode: json['tuitionCode'] as String,
  studentCode: json['studentCode'] as String,
  name: json['name'] as String,
  major: json['major'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
);

Map<String, dynamic> _$TuitionInfoToJson(TuitionInfo instance) =>
    <String, dynamic>{
      'tuitionCode': instance.tuitionCode,
      'studentCode': instance.studentCode,
      'name': instance.name,
      'major': instance.major,
      'amount': instance.amount,
      'status': instance.status,
    };
