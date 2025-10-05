import 'package:json_annotation/json_annotation.dart';

part 'payment_response.g.dart';

@JsonSerializable()
class PaymentResponse {
  final int id;
  final int userId;
  final String tuitionCode;
  final double amount;
  final String status;
  final String otpExpiredAt;
  final String createdAt;
  final String updatedAt;

  PaymentResponse({
    required this.id,
    required this.userId,
    required this.tuitionCode,
    required this.amount,
    required this.status,
    required this.otpExpiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);

  bool get isPendingOtp => status == 'PENDING_OTP';
  bool get isSuccess => status == 'SUCCESS';

  DateTime get otpExpiry => DateTime.parse(otpExpiredAt);
}
