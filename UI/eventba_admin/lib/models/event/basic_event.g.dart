// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicEvent _$BasicEventFromJson(Map<String, dynamic> json) => BasicEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: $enumDecode(_$EventStatusEnumMap, json['status']),
      coverImage: json['coverImage'] == null
          ? null
          : ImageModel.fromJson(json['coverImage'] as Map<String, dynamic>),
      isPaid: json['isPaid'] as bool? ?? false,
    );

Map<String, dynamic> _$BasicEventToJson(BasicEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'status': _$EventStatusEnumMap[instance.status]!,
      'coverImage': instance.coverImage,
      'isPaid': instance.isPaid,
    };

const _$EventStatusEnumMap = {
  EventStatus.Upcoming: 'Upcoming',
  EventStatus.Past: 'Past',
  EventStatus.Cancelled: 'Cancelled',
};
