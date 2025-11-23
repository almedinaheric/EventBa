import 'package:json_annotation/json_annotation.dart';

part 'user_question.g.dart';

@JsonSerializable()
class UserQuestion {
  final String id;
  final String userId;
  final String receiverId;
  final String question;
  final String? answer;
  final bool isQuestionForAdmin;
  final bool isAnswered;
  final String askedAt;
  final String? answeredAt;
  final String createdAt;
  final String updatedAt;
  final String? userEmail;
  final String? userFullName;

  UserQuestion({
    required this.id,
    required this.userId,
    required this.receiverId,
    required this.question,
    this.answer,
    required this.isQuestionForAdmin,
    required this.isAnswered,
    required this.askedAt,
    this.answeredAt,
    required this.createdAt,
    required this.updatedAt,
    this.userEmail,
    this.userFullName,
  });

  factory UserQuestion.fromJson(Map<String, dynamic> json) =>
      _$UserQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuestionToJson(this);
}
