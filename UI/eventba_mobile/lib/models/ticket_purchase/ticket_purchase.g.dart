// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketPurchase _$TicketPurchaseFromJson(Map<String, dynamic> json) =>
    TicketPurchase(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      qrVerificationHash: json['qrVerificationHash'] as String,
      qrData: json['qrData'] as String,
      qrCodeImage: TicketPurchase._qrCodeImageFromJson(json['qrCodeImage']),
      ticketCode: json['ticketCode'] as String,
      isUsed: json['isUsed'] as bool,
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
      isValid: json['isValid'] as bool,
      invalidatedAt: json['invalidatedAt'] == null
          ? null
          : DateTime.parse(json['invalidatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TicketPurchaseToJson(TicketPurchase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticketId': instance.ticketId,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'qrVerificationHash': instance.qrVerificationHash,
      'qrData': instance.qrData,
      'qrCodeImage': TicketPurchase._qrCodeImageToJson(instance.qrCodeImage),
      'ticketCode': instance.ticketCode,
      'isUsed': instance.isUsed,
      'usedAt': instance.usedAt?.toIso8601String(),
      'isValid': instance.isValid,
      'invalidatedAt': instance.invalidatedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
