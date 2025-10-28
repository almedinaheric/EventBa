import 'package:eventba_mobile/models/enums/event_status.dart';
import 'package:eventba_mobile/models/enums/event_type.dart';
import 'package:eventba_mobile/models/image/image_model.dart';
import 'package:eventba_mobile/models/category/category_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String description;
  final String location;
  final String? socialMediaLinks;

  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;

  final int capacity;
  final int currentAttendees;
  final int availableTicketsCount;

  final EventStatus status;
  final EventType type;
  final bool isPublished;
  final bool isFeatured;
  final bool isPaid;

  final CategoryModel category;
  final ImageModel? coverImage;
  final List<ImageModel>? galleryImages;

  final String organizerId;

  Event({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.location,
    this.socialMediaLinks,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.currentAttendees,
    required this.availableTicketsCount,
    required this.status,
    required this.type,
    required this.isPublished,
    required this.isFeatured,
    required this.isPaid,
    required this.category,
    this.coverImage,
    required this.galleryImages,
    required this.organizerId,
  });

  DateTime get fullStartDateTime {
    return DateTime.parse('$startDate$startTime');
  }

  DateTime get fullEndDateTime {
    return DateTime.parse('$endDate$endTime');
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
