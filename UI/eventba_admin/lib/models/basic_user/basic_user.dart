import 'package:eventba_admin/models/image/image_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'basic_user.g.dart';

@JsonSerializable(explicitToJson: true)
class BasicUser {
  String id;
  String fullName;
  ImageModel? profileImage;

  BasicUser({required this.id, required this.fullName, this.profileImage});

  factory BasicUser.fromJson(Map<String, dynamic> json) =>
      _$BasicUserFromJson(json);
  Map<String, dynamic> toJson() => _$BasicUserToJson(this);
}
