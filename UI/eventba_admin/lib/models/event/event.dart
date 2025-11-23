import 'package:json_annotation/json_annotation.dart';
import '../enums/event_status.dart';
import '../enums/event_type.dart';
import '../category/category_model.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String location;
  final int capacity;
  final int currentAttendees;
  final int availableTicketsCount;
  final EventStatus status;
  final EventType type;
  final bool isPublished;
  final bool isPaid;
  final String? coverImage;
  final String organizerId;
  final CategoryModel? category;
  final List<String>? galleryImages;
  final double? averageRating;
  final int? reviewCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.capacity,
    required this.currentAttendees,
    required this.availableTicketsCount,
    required this.status,
    required this.type,
    required this.isPublished,
    required this.isPaid,
    this.coverImage,
    required this.organizerId,
    this.category,
    this.galleryImages,
    this.averageRating,
    this.reviewCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
