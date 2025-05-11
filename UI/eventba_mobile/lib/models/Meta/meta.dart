import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart'; // Reference to generated file

@JsonSerializable()
class Meta {
  int count;
  int currentPage;
  int totalPages;
  bool hasPrevious;
  bool hasNext;

  Meta(this.count, this.currentPage, this.totalPages, this.hasPrevious,
      this.hasNext);

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
