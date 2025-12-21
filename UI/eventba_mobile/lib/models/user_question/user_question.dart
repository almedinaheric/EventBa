import 'package:json_annotation/json_annotation.dart';

part 'user_question.g.dart';

@JsonSerializable()
class UserQuestion {
  final String id;
  final String question;
  final String? answer;
  final String userId;
  final String receiverId;
  final String? eventId;
  final DateTime createdAt;
  final DateTime? answeredAt;
  @JsonKey(name: 'userFullName')
  final String? userName;
  @JsonKey(name: 'receiverFullName')
  final String? receiverName;

  UserQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.userId,
    required this.receiverId,
    this.eventId,
    required this.createdAt,
    this.answeredAt,
    this.userName,
    this.receiverName,
  });

  factory UserQuestion.fromJson(Map<String, dynamic> json) =>
      _$UserQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuestionToJson(this);
}
