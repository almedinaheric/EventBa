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
  @JsonKey(fromJson: _coverImageFromJson, toJson: _coverImageToJson)
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

  factory BasicEvent.fromJson(Map<String, dynamic> json) {
    return BasicEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      location: json['location'] as String,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.Upcoming,
      ),
      coverImage: _coverImageFromJson(json['coverImage']),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startDate': startDate,
    'endDate': endDate,
    'location': location,
    'status': status.name,
    'coverImage': _coverImageToJson(coverImage),
    'isPaid': isPaid,
  };

  
  static ImageModel? _coverImageFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      
      return ImageModel(
        id: '',
        data: json,
        contentType: 'image/jpeg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    if (json is Map<String, dynamic>) {
      
      return ImageModel.fromJson(json);
    }
    return null;
  }

  static dynamic _coverImageToJson(ImageModel? image) {
    if (image == null) return null;
    return image.data; 
  }
}
