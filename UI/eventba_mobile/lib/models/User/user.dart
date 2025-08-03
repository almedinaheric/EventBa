import 'package:json_annotation/json_annotation.dart';
import '../basic_user/basic_user.dart';
import '../category/category_model.dart';
import '../role/role.dart';
import '../image/image_model.dart';
import '../event/basic_event.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? bio;
  final String? phoneNumber;
  final Role role;
  final ImageModel? profileImage;
  final List<CategoryModel> interests;
  final List<BasicUser> followers;
  final List<BasicUser> following;
  final List<BasicEvent> favoriteEvents;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.bio,
    this.phoneNumber,
    required this.role,
    this.profileImage,
    required this.interests,
    required this.followers,
    required this.following,
    required this.favoriteEvents,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
