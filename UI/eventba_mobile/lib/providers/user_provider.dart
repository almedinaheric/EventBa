import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user/user.dart';
import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<bool> forgotPassword(String email) async {
    var url = "${baseUrl}User/forgot-password";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};

    var requestBody = {"email": email};

    var jsonRequest = jsonEncode(requestBody);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      try {
        var errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('errors')) {
          var errors = errorData['errors'];
          if (errors is Map) {
            var errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            throw Exception(errorMessages.join(', '));
          }
        }
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message'].toString());
        }
      } catch (e) {
        if (e is Exception) rethrow;
      }
      throw Exception("Failed to send reset code. Please try again.");
    }
  }

  Future<User> getProfile() async {
    var url = "${baseUrl}User/profile";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);

        var user = fromJson(data);
        return user;
      } else {
        throw Exception("Unknown error in a GET request");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> followUser(String userId) async {
    var url = "${baseUrl}User/$userId/follow";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Unknown error in a POST request");
    }
  }

  Future<bool> unfollowUser(String userId) async {
    var url = "${baseUrl}User/$userId/unfollow";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Unknown error in a POST request");
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    var url = "${baseUrl}User/change-password";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({
      "currentPassword": currentPassword,
      "newPassword": newPassword,
    });

    var response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Password change failed");
    }
  }

  Future<bool> validateResetCode(String email, String code) async {
    var url = "${baseUrl}User/validate-reset-code";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};

    var requestBody = {"email": email, "code": code};

    var jsonRequest = jsonEncode(requestBody);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data['valid'] == true;
    } else {
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    var url = "${baseUrl}User/reset-password";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};

    var requestBody = {
      "email": email,
      "code": code,
      "newPassword": newPassword,
    };

    var jsonRequest = jsonEncode(requestBody);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Password reset failed");
    }
  }

  Future<bool> logout() async {
    var url = "${baseUrl}User/logout";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.post(uri, headers: headers);
      if (isValidResponse(response)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void clearUser() {}
}
