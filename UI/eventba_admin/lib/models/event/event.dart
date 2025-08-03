import 'package:json_annotation/json_annotation.dart';
import '../enums/event_status.dart';
import '../enums/event_type.dart';
import '../image/image_model.dart';
import '../user/basic_user.dart';
import '../category/category_model.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String location;
  final EventStatus status;
  final EventType type;
  final bool isActive;
  final String? coverImage;
  final BasicUser organizer;
  final CategoryModel category;
  final List<ImageModel> galleryImages;
  final double? averageRating;
  final int? reviewCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
    required this.type,
    required this.isActive,
    this.coverImage,
    required this.organizer,
    required this.category,
    required this.galleryImages,
    this.averageRating,
    this.reviewCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
