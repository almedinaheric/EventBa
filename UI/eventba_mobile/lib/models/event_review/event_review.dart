import 'package:json_annotation/json_annotation.dart';

part 'event_review.g.dart';

@JsonSerializable()
class EventReview {
  final String id;
  final String eventId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String userName;
  final String eventTitle;

  EventReview({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    required this.eventTitle,
  });

  factory EventReview.fromJson(Map<String, dynamic> json) =>
      _$EventReviewFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewToJson(this);
}
