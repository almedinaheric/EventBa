// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserQuestion _$UserQuestionFromJson(Map<String, dynamic> json) => UserQuestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      receiverId: json['receiverId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      isQuestionForAdmin: json['isQuestionForAdmin'] as bool,
      isAnswered: json['isAnswered'] as bool,
      askedAt: json['askedAt'] as String,
      answeredAt: json['answeredAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      userEmail: json['userEmail'] as String?,
      userFullName: json['userFullName'] as String?,
    );

Map<String, dynamic> _$UserQuestionToJson(UserQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'receiverId': instance.receiverId,
      'question': instance.question,
      'answer': instance.answer,
      'isQuestionForAdmin': instance.isQuestionForAdmin,
      'isAnswered': instance.isAnswered,
      'askedAt': instance.askedAt,
      'answeredAt': instance.answeredAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'userEmail': instance.userEmail,
      'userFullName': instance.userFullName,
    };
