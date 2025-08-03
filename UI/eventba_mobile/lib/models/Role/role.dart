import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;

  Role({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
