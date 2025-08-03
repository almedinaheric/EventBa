import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String? description;
  final int eventCount;

  CategoryModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.description,
    required this.eventCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
