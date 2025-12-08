import 'package:json_annotation/json_annotation.dart';

import '../enums/notification_status.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? eventId;
  final bool isSystemNotification;
  final String title;
  final String content;
  final bool isImportant;
  final NotificationStatus status;

  @JsonKey(ignore: true)
  bool get isRead => status == NotificationStatus.Read;

  Notification({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.eventId,
    required this.isSystemNotification,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.status,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
