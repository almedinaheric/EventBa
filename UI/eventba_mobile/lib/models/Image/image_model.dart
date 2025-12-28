import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'image_model.g.dart';

@JsonSerializable()
class ImageModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'data', fromJson: _dataFromJson, toJson: _dataToJson)
  final String? data;

  @JsonKey(name: 'contentType', includeIfNull: false)
  final String? contentType;

  @JsonKey(name: 'userId')
  final String? userId;

  @JsonKey(name: 'eventId')
  final String? eventId;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
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

  
  
  static String? _dataFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      
      return value;
    }
    if (value is List) {
      
      try {
        final bytes = List<int>.from(value);
        return base64Encode(bytes);
      } catch (e) {
        return null;
      }
    }
    return value.toString();
  }

  static dynamic _dataToJson(String? value) => value;
}
