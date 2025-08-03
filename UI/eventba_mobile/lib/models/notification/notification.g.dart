// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  userId: json['userId'] as String?,
  eventId: json['eventId'] as String?,
  isSystemNotification: json['isSystemNotification'] as bool,
  title: json['title'] as String,
  content: json['content'] as String,
  isImportant: json['isImportant'] as bool,
  status: $enumDecode(_$NotificationStatusEnumMap, json['status']),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'eventId': instance.eventId,
      'isSystemNotification': instance.isSystemNotification,
      'title': instance.title,
      'content': instance.content,
      'isImportant': instance.isImportant,
      'status': _$NotificationStatusEnumMap[instance.status]!,
    };

const _$NotificationStatusEnumMap = {
  NotificationStatus.Sent: 'Sent',
  NotificationStatus.Read: 'Read',
  NotificationStatus.Archived: 'Archived',
};
