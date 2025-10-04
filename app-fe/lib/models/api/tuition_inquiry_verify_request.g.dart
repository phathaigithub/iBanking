// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuition_inquiry_verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuitionInquiryVerifyRequest _$TuitionInquiryVerifyRequestFromJson(
  Map<String, dynamic> json,
) => TuitionInquiryVerifyRequest(
  studentCode: json['studentCode'] as String,
  otpCode: json['otpCode'] as String,
);

Map<String, dynamic> _$TuitionInquiryVerifyRequestToJson(
  TuitionInquiryVerifyRequest instance,
) => <String, dynamic>{
  'studentCode': instance.studentCode,
  'otpCode': instance.otpCode,
};
