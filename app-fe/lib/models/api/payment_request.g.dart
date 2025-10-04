// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      userId: (json['userId'] as num).toInt(),
      tuitionCode: json['tuitionCode'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tuitionCode': instance.tuitionCode,
      'amount': instance.amount,
    };
