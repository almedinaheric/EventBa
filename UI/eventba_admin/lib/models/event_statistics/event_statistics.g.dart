// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventStatistics _$EventStatisticsFromJson(Map<String, dynamic> json) =>
    EventStatistics(
      eventId: json['eventId'] as String,
      totalTicketsSold: (json['totalTicketsSold'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      currentAttendees: (json['currentAttendees'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
    );

Map<String, dynamic> _$EventStatisticsToJson(EventStatistics instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'totalTicketsSold': instance.totalTicketsSold,
      'totalRevenue': instance.totalRevenue,
      'currentAttendees': instance.currentAttendees,
      'averageRating': instance.averageRating,
    };
