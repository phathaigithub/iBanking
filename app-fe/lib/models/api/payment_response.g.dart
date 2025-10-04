// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      tuitionCode: json['tuitionCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      otpExpiredAt: json['otpExpiredAt'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tuitionCode': instance.tuitionCode,
      'amount': instance.amount,
      'status': instance.status,
      'otpExpiredAt': instance.otpExpiredAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
