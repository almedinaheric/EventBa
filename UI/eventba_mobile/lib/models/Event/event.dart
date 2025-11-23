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
  @JsonKey(fromJson: _coverImageFromJson)
  final ImageModel? coverImage;
  @JsonKey(fromJson: _galleryImagesFromJson)
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

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      socialMediaLinks: json['socialMediaLinks'] as String?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      capacity: (json['capacity'] as num).toInt(),
      currentAttendees: (json['currentAttendees'] as num).toInt(),
      availableTicketsCount: (json['availableTicketsCount'] as num).toInt(),
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.Upcoming,
      ),
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.Public,
      ),
      isPublished: json['isPublished'] as bool,
      isFeatured: json['isFeatured'] as bool,
      isPaid: json['isPaid'] as bool,
      category: CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      coverImage: _coverImageFromJson(json['coverImage']),
      galleryImages: _galleryImagesFromJson(json['galleryImages']),
      organizerId: json['organizerId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'title': title,
    'description': description,
    'location': location,
    'socialMediaLinks': socialMediaLinks,
    'startDate': startDate,
    'endDate': endDate,
    'startTime': startTime,
    'endTime': endTime,
    'capacity': capacity,
    'currentAttendees': currentAttendees,
    'availableTicketsCount': availableTicketsCount,
    'status': status.name,
    'type': type.name,
    'isPublished': isPublished,
    'isFeatured': isFeatured,
    'isPaid': isPaid,
    'category': category.toJson(),
    'coverImage': coverImage?.data,
    'galleryImages': galleryImages?.map((e) => e.data).toList(),
    'organizerId': organizerId,
  };

  // Custom converter: handle string (data URI) format from backend
  static ImageModel? _coverImageFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      // Backend returns string as data URI, convert to ImageModel
      return ImageModel(
        id: '',
        data: json,
        contentType: 'image/jpeg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    if (json is Map<String, dynamic>) {
      // If it's already an object, parse it normally
      return ImageModel.fromJson(json);
    }
    return null;
  }

  // Custom converter: handle list of strings (data URIs) from backend
  static List<ImageModel>? _galleryImagesFromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((item) {
            if (item is String) {
              // Backend returns string as data URI, convert to ImageModel
              return ImageModel(
                id: '',
                data: item,
                contentType: 'image/jpeg',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }
            if (item is Map<String, dynamic>) {
              // If it's already an object, parse it normally
              return ImageModel.fromJson(item);
            }
            return null;
          })
          .whereType<ImageModel>()
          .toList();
    }
    return null;
  }
}
