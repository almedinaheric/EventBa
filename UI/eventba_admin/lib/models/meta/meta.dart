import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
  @JsonKey(name: 'totalCount')
  final int? totalCount;

  @JsonKey(name: 'pageNumber')
  final int pageNumber;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  @JsonKey(name: 'hasPrevious')
  final bool hasPrevious;

  @JsonKey(name: 'hasNext')
  final bool hasNext;

  Meta({
    this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
