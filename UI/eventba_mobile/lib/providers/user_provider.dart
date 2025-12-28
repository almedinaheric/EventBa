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

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Forgot password request failed");
    }
  }

  Future<User> getProfile() async {
    var url = "${baseUrl}User/profile";
    print("Making GET request to: $url");

    var uri = Uri.parse(url);
    var headers = createHeaders();
    print("Request headers: $headers");

    try {
      var response = await http.get(uri, headers: headers);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        print("Decoded JSON data: $data");

        var user = fromJson(data);
        print("Mapped user object: $user");
        return user;
      } else {
        print("Invalid response received.");
        throw Exception("Unknown error in a GET request");
      }
    } catch (e) {
      print("Exception occurred during getProfile(): $e");
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
      print("Error during logout: $e");
      return false;
    }
  }

  void clearUser() {
    
  }
}
