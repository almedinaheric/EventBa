// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  eventId: json['eventId'] as String,
  ticketType: json['ticketType'] as String,
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  quantityAvailable: (json['quantityAvailable'] as num).toInt(),
  quantitySold: (json['quantitySold'] as num).toInt(),
  saleStartDate: DateTime.parse(json['saleStartDate'] as String),
  saleEndDate: DateTime.parse(json['saleEndDate'] as String),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'eventId': instance.eventId,
  'ticketType': instance.ticketType,
  'price': instance.price,
  'quantity': instance.quantity,
  'quantityAvailable': instance.quantityAvailable,
  'quantitySold': instance.quantitySold,
  'saleStartDate': instance.saleStartDate.toIso8601String(),
  'saleEndDate': instance.saleEndDate.toIso8601String(),
};
