// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserQuestion _$UserQuestionFromJson(Map<String, dynamic> json) => UserQuestion(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String?,
  userId: json['userId'] as String,
  receiverId: json['receiverId'] as String,
  eventId: json['eventId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  answeredAt: json['answeredAt'] == null
      ? null
      : DateTime.parse(json['answeredAt'] as String),
  userName: json['userFullName'] as String?,
  receiverName: json['receiverFullName'] as String?,
);

Map<String, dynamic> _$UserQuestionToJson(UserQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'userId': instance.userId,
      'receiverId': instance.receiverId,
      'eventId': instance.eventId,
      'createdAt': instance.createdAt.toIso8601String(),
      'answeredAt': instance.answeredAt?.toIso8601String(),
      'userFullName': instance.userName,
      'receiverFullName': instance.receiverName,
    };
