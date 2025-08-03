import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final String id;
  final String userId;
  final String ticketPurchaseId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime paymentDate;
  final String? transactionId;

  Payment({
    required this.id,
    required this.userId,
    required this.ticketPurchaseId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.transactionId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
