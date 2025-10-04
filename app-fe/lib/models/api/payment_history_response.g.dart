// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentHistoryResponse _$PaymentHistoryResponseFromJson(
  Map<String, dynamic> json,
) => PaymentHistoryResponse(
  id: (json['id'] as num).toInt(),
  paymentId: (json['paymentId'] as num).toInt(),
  tuitionCode: json['tuitionCode'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  message: json['message'] as String,
  createdAt: json['createdAt'] as String,
  tuitionAmount: (json['tuitionAmount'] as num).toDouble(),
  semester: json['semester'] as String,
);

Map<String, dynamic> _$PaymentHistoryResponseToJson(
  PaymentHistoryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'paymentId': instance.paymentId,
  'tuitionCode': instance.tuitionCode,
  'amount': instance.amount,
  'status': instance.status,
  'message': instance.message,
  'createdAt': instance.createdAt,
  'tuitionAmount': instance.tuitionAmount,
  'semester': instance.semester,
};
