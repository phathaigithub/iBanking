// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  status: (json['status'] as num).toInt(),
  errorCode: json['errorCode'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'status': instance.status,
  'errorCode': instance.errorCode,
  'message': instance.message,
};
