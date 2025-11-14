import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String eventId;
  final String ticketType;
  final double price;
  final int quantity;
  final int quantityAvailable;
  final int quantitySold;
  final DateTime saleStartDate;
  final DateTime saleEndDate;

  Ticket({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.eventId,
    required this.ticketType,
    required this.price,
    required this.quantity,
    required this.quantityAvailable,
    required this.quantitySold,
    required this.saleStartDate,
    required this.saleEndDate,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
