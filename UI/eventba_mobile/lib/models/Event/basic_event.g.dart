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
  location: json['location'] as String,
  status: $enumDecode(_$EventStatusEnumMap, json['status']),
  coverImage: BasicEvent._coverImageFromJson(json['coverImage']),
  isPaid: json['isPaid'] as bool? ?? false,
);

Map<String, dynamic> _$BasicEventToJson(BasicEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'location': instance.location,
      'status': _$EventStatusEnumMap[instance.status]!,
      'coverImage': BasicEvent._coverImageToJson(instance.coverImage),
      'isPaid': instance.isPaid,
    };

const _$EventStatusEnumMap = {
  EventStatus.Upcoming: 'Upcoming',
  EventStatus.Past: 'Past',
  EventStatus.Cancelled: 'Cancelled',
};
