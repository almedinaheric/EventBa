import 'package:eventba_admin/models/basic_user/basic_user.dart';
import 'package:eventba_admin/models/category/category_model.dart';
import 'package:eventba_admin/models/event/basic_event.dart';
import 'package:eventba_admin/models/image/image_model.dart';
import 'package:eventba_admin/models/role/role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  String firstName;
  String lastName;
  String fullName;
  String email;
  String? bio;
  String? phoneNumber;
  Role role;
  ImageModel? profileImage;
  List<CategoryModel> interests;
  List<BasicUser> followers;
  List<BasicUser> following;
  List<BasicEvent> favoriteEvents;

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
    this.interests = const [],
    this.followers = const [],
    this.following = const [],
    this.favoriteEvents = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
