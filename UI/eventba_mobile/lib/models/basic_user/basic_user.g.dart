// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicUser _$BasicUserFromJson(Map<String, dynamic> json) => BasicUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profileImage: json['profileImage'] == null
          ? null
          : ImageModel.fromJson(json['profileImage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BasicUserToJson(BasicUser instance) => <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'profileImage': instance.profileImage?.toJson(),
    };
