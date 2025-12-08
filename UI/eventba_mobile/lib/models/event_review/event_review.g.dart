// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventReview _$EventReviewFromJson(Map<String, dynamic> json) => EventReview(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  userId: json['userId'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$EventReviewToJson(EventReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };
