// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      profileImage: json['profileImage'] == null
          ? null
          : ImageModel.fromJson(json['profileImage'] as Map<String, dynamic>),
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => BasicUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => BasicUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      favoriteEvents: (json['favoriteEvents'] as List<dynamic>?)
              ?.map((e) => BasicEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'email': instance.email,
      'bio': instance.bio,
      'phoneNumber': instance.phoneNumber,
      'role': instance.role.toJson(),
      'profileImage': instance.profileImage?.toJson(),
      'interests': instance.interests.map((e) => e.toJson()).toList(),
      'followers': instance.followers.map((e) => e.toJson()).toList(),
      'following': instance.following.map((e) => e.toJson()).toList(),
      'favoriteEvents': instance.favoriteEvents.map((e) => e.toJson()).toList(),
    };
