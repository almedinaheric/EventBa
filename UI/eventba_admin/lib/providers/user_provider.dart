import 'dart:convert';

import 'package:eventba_admin/models/user/user.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  User? _user;
  User? get user => _user;

  Future<User> getProfile() async {
    var url = "${baseUrl}User/profile/admin";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);
      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);

        _user = fromJson(data);
        notifyListeners();
        return _user!;
      } else {
        throw Exception("Unknown error in a GET request");
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<User> getUserById(String userId) async {
    var url = "${baseUrl}User/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to load user details");
    }
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Map<String, String> createHeadersWithoutAuth() {
    return {"Content-Type": "application/json"};
  }

  Future<bool> forgotPassword(String email) async {
    var url = "${baseUrl}User/forgot-password";
    var uri = Uri.parse(url);
    var headers = createHeadersWithoutAuth();

    var requestBody = {"email": email};

    var jsonRequest = jsonEncode(requestBody);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      try {
        var errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message'].toString());
        }
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
      } catch (e) {
        if (e is Exception) rethrow;
      }
      throw Exception("Failed to send reset code. Please try again.");
    }
  }

  Future<bool> validateResetCode(String email, String code) async {
    var url = "${baseUrl}User/validate-reset-code";
    var uri = Uri.parse(url);
    var headers = createHeadersWithoutAuth();

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
    var headers = createHeadersWithoutAuth();

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
}
