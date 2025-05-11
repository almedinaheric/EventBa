import 'package:eventba_mobile/models/Category/category_model.dart';
import 'package:eventba_mobile/models/Event/basic_event.dart';
import 'package:eventba_mobile/models/Image/image_model.dart';
import 'package:eventba_mobile/models/Role/role.dart';
import 'package:eventba_mobile/models/User/basic_user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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
  List<CategoryModel>? interests;
  List<BasicUser>? followers;
  List<BasicUser>? following;
  List<BasicEvent>? favoriteEvents;

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
    this.interests,
    this.followers,
    this.following,
    this.favoriteEvents,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
