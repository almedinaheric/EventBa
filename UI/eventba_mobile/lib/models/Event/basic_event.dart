import 'package:eventba_mobile/models/enums/event_status.dart';
import 'package:eventba_mobile/models/image/image_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'basic_event.g.dart';

@JsonSerializable()
class BasicEvent {
  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String location;
  final EventStatus status;
  final ImageModel? coverImage;
  final bool isPaid;

  BasicEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
    this.coverImage,
    this.isPaid = false,
  });

  factory BasicEvent.fromJson(Map<String, dynamic> json) =>
      _$BasicEventFromJson(json);

  Map<String, dynamic> toJson() => _$BasicEventToJson(this);
}
