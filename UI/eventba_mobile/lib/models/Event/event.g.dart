// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
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
  status: $enumDecode(_$EventStatusEnumMap, json['status']),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  isPublished: json['isPublished'] as bool,
  isFeatured: json['isFeatured'] as bool,
  isPaid: json['isPaid'] as bool,
  category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
  coverImage: Event._coverImageFromJson(json['coverImage']),
  galleryImages: Event._galleryImagesFromJson(json['galleryImages']),
  organizerId: json['organizerId'] as String,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'socialMediaLinks': instance.socialMediaLinks,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'capacity': instance.capacity,
  'currentAttendees': instance.currentAttendees,
  'availableTicketsCount': instance.availableTicketsCount,
  'status': _$EventStatusEnumMap[instance.status]!,
  'type': _$EventTypeEnumMap[instance.type]!,
  'isPublished': instance.isPublished,
  'isFeatured': instance.isFeatured,
  'isPaid': instance.isPaid,
  'category': instance.category,
  'coverImage': instance.coverImage,
  'galleryImages': instance.galleryImages,
  'organizerId': instance.organizerId,
};

const _$EventStatusEnumMap = {
  EventStatus.Upcoming: 'Upcoming',
  EventStatus.Past: 'Past',
  EventStatus.Cancelled: 'Cancelled',
};

const _$EventTypeEnumMap = {
  EventType.Public: 'Public',
  EventType.Private: 'Private',
};
