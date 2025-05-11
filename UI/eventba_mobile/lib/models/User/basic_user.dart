import 'package:eventba_mobile/models/Image/image_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'basic_user.g.dart';

@JsonSerializable()
class BasicUser {
  String id;
  String name;
  ImageModel? profileImage;

  BasicUser({required this.id, required this.name, this.profileImage});

  factory BasicUser.fromJson(Map<String, dynamic> json) =>
      _$BasicUserFromJson(json);
  Map<String, dynamic> toJson() => _$BasicUserToJson(this);
}
