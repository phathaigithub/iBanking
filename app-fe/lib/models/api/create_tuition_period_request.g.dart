// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tuition_period_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTuitionPeriodRequest _$CreateTuitionPeriodRequestFromJson(
  Map<String, dynamic> json,
) => CreateTuitionPeriodRequest(
  semester: json['semester'] as String,
  majorCode: json['majorCode'] as String,
  amount: (json['amount'] as num).toDouble(),
  dueDate: json['dueDate'] as String,
);

Map<String, dynamic> _$CreateTuitionPeriodRequestToJson(
  CreateTuitionPeriodRequest instance,
) => <String, dynamic>{
  'semester': instance.semester,
  'majorCode': instance.majorCode,
  'amount': instance.amount,
  'dueDate': instance.dueDate,
};
