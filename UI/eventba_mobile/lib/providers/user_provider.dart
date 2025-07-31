import 'dart:convert';

import 'package:eventba_mobile/models/user/user.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  User? _user;
  User? get user => _user;

  Future<User> getProfile() async {
    try {
      final uri = Uri.parse(baseUrl).resolve('User/profile');
      final headers = createHeaders();
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _user!;
      } else {
        throw Exception("Failed to load user profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in getProfile: $e");
      rethrow;
    }
  }

  Future<User> register(Map<String, dynamic> request) async {
    try {
      final user = await insert(request);
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      print("Exception in register: $e");
      rethrow;
    }
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
