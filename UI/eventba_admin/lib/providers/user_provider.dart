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

        _user = fromJson(data);
        print("Mapped user object: $_user");
        notifyListeners();
        return _user!;
      } else {
        print("Invalid response received.");
        throw Exception("Unknown error in a GET request");
      }
    } catch (e) {
      print("Exception occurred during getProfile(): $e");
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
}
