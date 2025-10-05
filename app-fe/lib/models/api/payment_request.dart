import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  final int userId;
  final String tuitionCode;
  final double amount;

  PaymentRequest({
    required this.userId,
    required this.tuitionCode,
    required this.amount,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
