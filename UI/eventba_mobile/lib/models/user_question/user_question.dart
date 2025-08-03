import 'package:json_annotation/json_annotation.dart';

part 'user_question.g.dart';

@JsonSerializable()
class UserQuestion {
  final String id;
  final String question;
  final String? answer;
  final String userId;
  final String receiverId;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final String userName;
  final String receiverName;

  UserQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.userId,
    required this.receiverId,
    required this.createdAt,
    this.answeredAt,
    required this.userName,
    required this.receiverName,
  });

  factory UserQuestion.fromJson(Map<String, dynamic> json) =>
      _$UserQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuestionToJson(this);
}
