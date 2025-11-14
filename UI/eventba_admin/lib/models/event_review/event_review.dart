import 'package:json_annotation/json_annotation.dart';
import '../user/basic_user.dart';

part 'event_review.g.dart';

@JsonSerializable()
class EventReview {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String eventId;
  final String userId;
  final int rating;
  final String? comment;
  final BasicUser? user;

  EventReview({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.eventId,
    required this.userId,
    required this.rating,
    this.comment,
    this.user,
  });

  factory EventReview.fromJson(Map<String, dynamic> json) =>
      _$EventReviewFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewToJson(this);
}
