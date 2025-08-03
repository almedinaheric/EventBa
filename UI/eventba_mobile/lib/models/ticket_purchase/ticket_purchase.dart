import 'package:json_annotation/json_annotation.dart';

part 'ticket_purchase.g.dart';

@JsonSerializable()
class TicketPurchase {
  final String id;
  final String ticketId;
  final String eventId;
  final String userId;
  final String qrVerificationHash;
  final String qrData;
  final List<int>? qrCodeImage;
  final String ticketCode;
  final bool isUsed;
  final DateTime? usedAt;
  final bool isValid;
  final DateTime? invalidatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketPurchase({
    required this.id,
    required this.ticketId,
    required this.eventId,
    required this.userId,
    required this.qrVerificationHash,
    required this.qrData,
    this.qrCodeImage,
    required this.ticketCode,
    required this.isUsed,
    this.usedAt,
    required this.isValid,
    this.invalidatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketPurchase.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPurchaseToJson(this);
}
