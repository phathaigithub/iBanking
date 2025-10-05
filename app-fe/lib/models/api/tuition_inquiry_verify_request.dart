import 'package:json_annotation/json_annotation.dart';

part 'tuition_inquiry_verify_request.g.dart';

@JsonSerializable()
class TuitionInquiryVerifyRequest {
  final String studentCode;
  final String otpCode;

  TuitionInquiryVerifyRequest({
    required this.studentCode,
    required this.otpCode,
  });

  factory TuitionInquiryVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$TuitionInquiryVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionInquiryVerifyRequestToJson(this);
}
