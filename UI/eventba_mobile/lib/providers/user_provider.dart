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
    var headers = createHeaders();

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

  Future<bool> changePassword(String currentPassword, String newPassword) async {
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
}
