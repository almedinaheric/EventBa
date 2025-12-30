// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicUser _$BasicUserFromJson(Map<String, dynamic> json) => BasicUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$BasicUserToJson(BasicUser instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'fullName': instance.fullName,
    };
