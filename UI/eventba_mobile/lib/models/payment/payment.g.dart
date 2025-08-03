// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  ticketPurchaseId: json['ticketPurchaseId'] as String,
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String,
  paymentStatus: json['paymentStatus'] as String,
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  transactionId: json['transactionId'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'ticketPurchaseId': instance.ticketPurchaseId,
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'paymentStatus': instance.paymentStatus,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'transactionId': instance.transactionId,
};
