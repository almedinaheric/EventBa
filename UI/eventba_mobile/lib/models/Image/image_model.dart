import 'package:json_annotation/json_annotation.dart';

part 'image_model.g.dart';

@JsonSerializable()
class ImageModel {
  final String id;
  final String data;
  final String contentType;
  final String? userId;
  final String? eventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ImageModel({
    required this.id,
    required this.data,
    required this.contentType,
    this.userId,
    this.eventId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
