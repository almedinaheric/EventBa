// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventReview _$EventReviewFromJson(Map<String, dynamic> json) => EventReview(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      user: json['user'] == null
          ? null
          : BasicUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventReviewToJson(EventReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'user': instance.user,
    };
