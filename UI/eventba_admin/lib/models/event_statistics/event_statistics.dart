import 'package:json_annotation/json_annotation.dart';

part 'event_statistics.g.dart';

@JsonSerializable()
class EventStatistics {
  final String eventId;
  final int totalTicketsSold;
  final double totalRevenue;
  final int currentAttendees;
  final double averageRating;

  EventStatistics({
    required this.eventId,
    required this.totalTicketsSold,
    required this.totalRevenue,
    required this.currentAttendees,
    required this.averageRating,
  });

  factory EventStatistics.fromJson(Map<String, dynamic> json) =>
      _$EventStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$EventStatisticsToJson(this);
}
