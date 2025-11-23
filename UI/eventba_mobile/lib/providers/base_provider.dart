import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:eventba_mobile/models/meta/meta.dart';
import 'package:eventba_mobile/models/search_result.dart';
import 'package:eventba_mobile/utils/authorization.dart';
import 'package:eventba_mobile/utils/string_helpers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;

    // Get base URL from environment variable if provided, otherwise use platform-specific default
    final envBaseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "",
    );

    if (envBaseUrl.isNotEmpty) {
      _baseUrl = envBaseUrl;
    } else {
      // Platform-specific defaults:
      // - Android emulator: use 10.0.2.2 to access host machine's localhost
      // - iOS simulator: use localhost (works fine)
      // - Web: use localhost
      // - Physical devices: use your local network IP (e.g., 192.168.0.34)
      if (kIsWeb) {
        _baseUrl = "http://localhost:5187/";
      } else if (Platform.isAndroid) {
        // For Android emulator, use 10.0.2.2 to access host machine
        // For physical Android device, you may need to use your local network IP
        _baseUrl = "http://10.0.2.2:5187/";
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost
        _baseUrl = "http://localhost:5187/";
      } else {
        // Default fallback
        _baseUrl = "http://localhost:5187/";
      }
    }
  }

  String get baseUrl => _baseUrl!;

  Future<SearchResult<T>> get({dynamic filter, bool authorized = true}) async {
    var url = "$_baseUrl$_endpoint";
    if (filter != null) {
      var queryString = StringHelpers.getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = authorized
        ? createHeaders()
        : {"Content-Type": "application/json"};

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<T>();
      result.meta = Meta.fromJson(data['meta']);

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> getById(String id, {bool authorized = true}) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = authorized
        ? createHeaders()
        : {"Content-Type": "application/json"};
    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request, {bool authorized = true}) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = authorized
        ? createHeaders()
        : {"Content-Type": "application/json"};

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(String id, [dynamic request, bool authorized = true]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = authorized
        ? createHeaders()
        : {"Content-Type": "application/json"};

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> delete(String id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    print(uri);

    var response = await http.delete(uri, headers: headers);

    print(response.body);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error in a DELETE request");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      print(response.body);
      throw Exception("Something bad happened please try again");
    }
  }

  Map<String, String> createHeaders() {
    String email = Authorization.email ?? "";
    String password = Authorization.password ?? "";

    String basicAuth = "Basic ${base64Encode(utf8.encode('$email:$password'))}";

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }
}
