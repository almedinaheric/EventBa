// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      location: json['location'] as String,
      status: $enumDecode(_$EventStatusEnumMap, json['status']),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      isActive: json['isActive'] as bool,
      isPaid: json['isPaid'] as bool,
      coverImage: json['coverImage'] as String?,
      organizer: BasicUser.fromJson(json['organizer'] as Map<String, dynamic>),
      category:
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      galleryImages: (json['galleryImages'] as List<dynamic>)
          .map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'location': instance.location,
      'status': _$EventStatusEnumMap[instance.status]!,
      'type': _$EventTypeEnumMap[instance.type]!,
      'isActive': instance.isActive,
      'isPaid': instance.isPaid,
      'coverImage': instance.coverImage,
      'organizer': instance.organizer,
      'category': instance.category,
      'galleryImages': instance.galleryImages,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
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
