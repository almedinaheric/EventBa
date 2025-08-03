import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event/event.dart';
import '../models/event/basic_event.dart';
import 'base_provider.dart';

class EventProvider extends BaseProvider<Event> {
  EventProvider() : super("Event");

  @override
  Event fromJson(data) {
    return Event.fromJson(data);
  }

  BasicEvent basicEventFromJson(data) {
    return BasicEvent.fromJson(data);
  }

  Future<List<Event>> getMyEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/my-events";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    print("🔍 [getMyEvents] Making GET request to: $url");
    print("🪪 [getMyEvents] Headers: $headers");

    var response = await http.get(uri, headers: headers);

    print("📥 [getMyEvents] Response status: ${response.statusCode}");
    print("📦 [getMyEvents] Response body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];

      try {
        for (var item in data) {
          print("🧩 [getMyEvents] Decoding event: $item");
          events.add(fromJson(item));
        }
      } catch (e) {
        print("❌ [getMyEvents] Failed to parse one of the events: $e");
        rethrow;
      }

      print("✅ [getMyEvents] Parsed ${events.length} events successfully");
      return events;
    } else {
      throw Exception(
        "❗ [getMyEvents] Unknown error in a GET request. Status code: ${response.statusCode}",
      );
    }
  }

  Future<List<BasicEvent>> getRecommendedEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/recommended";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<BasicEvent> events = [];
      for (var item in data) {
        events.add(basicEventFromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<BasicEvent>> getPublicEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/public";

    var uri = Uri.parse(url);
    print("URI EVENTS: $uri");

    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<BasicEvent> events = [];
      for (var item in data) {
        events.add(basicEventFromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<BasicEvent>> getPrivateEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/private";

    var uri = Uri.parse(url);
    var headers = createHeaders();


    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<BasicEvent> events = [];
      for (var item in data) {
        events.add(basicEventFromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<BasicEvent>> getEventsByCategory(
    String categoryId, {
    dynamic filter,
  }) async {
    var url = "${baseUrl}Event/category/$categoryId";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<BasicEvent> events = [];
      for (var item in data) {
        events.add(basicEventFromJson(item));
      }
      return events;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<BasicEvent>> getUserFavoriteEvents({dynamic filter}) async {
    var url = "${baseUrl}Event/favorites";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<BasicEvent> events = [];
      for (var item in data) {
        events.add(basicEventFromJson(item));
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
