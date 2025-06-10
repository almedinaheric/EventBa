import 'package:json_annotation/json_annotation.dart';

part 'image_model.g.dart';

@JsonSerializable()
class ImageModel {
  final String? id;
  final String? data;
  final String? contentType;
  final String? userId;
  final String? eventId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ImageModel({
    this.id,
    this.data,
    this.contentType,
    this.userId,
    this.eventId,
    this.createdAt,
    this.updatedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
