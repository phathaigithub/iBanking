import 'package:json_annotation/json_annotation.dart';

part 'otp_verification_request.g.dart';

@JsonSerializable()
class OtpVerificationRequest {
  final String otpCode;

  OtpVerificationRequest({required this.otpCode});

  factory OtpVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerificationRequestToJson(this);
}
