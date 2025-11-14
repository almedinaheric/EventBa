import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event/event.dart';
import 'base_provider.dart';

class EventProvider extends BaseProvider<Event> {
  EventProvider() : super("Event");

  @override
  Event fromJson(data) {
    return Event.fromJson(data);
  }

  Future<List<Event>> getMyEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/my-events";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];
      for (var item in data) {
        events.add(fromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<Event>> getRecommendedEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/recommended";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];
      for (var item in data) {
        events.add(fromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<Event>> getPublicEvents() async {
    var url = "${baseUrl}Event/public";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];
      for (var item in data) {
        events.add(fromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<Event>> getPrivateEvents() async {
    var url = "${baseUrl}Event/private";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];
      for (var item in data) {
        events.add(fromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<Map<String, dynamic>> getEventStatistics(String eventId) async {
    var url = "${baseUrl}Event/$eventId/statistics";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
