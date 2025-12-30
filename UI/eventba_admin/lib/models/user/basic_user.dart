import 'package:json_annotation/json_annotation.dart';

part 'basic_user.g.dart';

@JsonSerializable()
class BasicUser {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? fullName;

  BasicUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.fullName,
  });

  factory BasicUser.fromJson(Map<String, dynamic> json) =>
      _$BasicUserFromJson(json);

  Map<String, dynamic> toJson() => _$BasicUserToJson(this);
}
