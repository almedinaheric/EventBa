import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageHelpers {
  static Widget getImage(
    String? image, {
    double height = 40,
    double width = 40,
    BoxFit fit = BoxFit.cover,
  }) {
    if (image == null || image.isEmpty) {
      return Image.asset(
        "assets/images/default_event_cover_image.png",
        height: height,
        width: width,
        fit: fit,
      );
    }

    try {
      
      String base64String = image;
      if (image.startsWith('data:image')) {
        base64String = image.split(',').last;
      }

      return Image.memory(
        base64Decode(base64String),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/default_event_cover_image.png",
            height: height,
            width: width,
            fit: fit,
          );
        },
      );
    } catch (e) {
      return Image.asset(
        "assets/images/default_event_cover_image.png",
        height: height,
        width: width,
        fit: fit,
      );
    }
  }

  static Widget getProfileImage(
    String? image, {
    double height = 40,
    double width = 40,
  }) {
    if (image == null || image.isEmpty) {
      return Image.asset(
        "assets/images/profile_placeholder.png",
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }

    try {
      
      String base64String = image;
      if (image.startsWith('data:image')) {
        base64String = image.split(',').last;
      }

      return Image.memory(
        base64Decode(base64String),
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/profile_placeholder.png",
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
        },
      );
    } catch (e) {
      
      return Image.asset(
        "assets/images/profile_placeholder.png",
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }
  }

  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  static String getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
