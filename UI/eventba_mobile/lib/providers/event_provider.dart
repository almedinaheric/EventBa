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
    final queryParams = <String, String>{};
    if (filter != null && filter is Map) {
      filter.forEach((key, value) {
        queryParams[key.toString()] = value.toString();
      });
    }
    var uri = queryParams.isEmpty
        ? Uri.parse(url)
        : Uri.parse(url).replace(queryParameters: queryParams);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Event> events = [];
      try {
        for (var item in data) {
          events.add(fromJson(item));
        }
      } catch (e) {
        rethrow;
      }
      return events;
    } else {
      throw Exception(
        "[getMyEvents] Unknown error in a GET request. Status code: ${response.statusCode}",
      );
    }
  }

  Future<List<BasicEvent>> getEventsByOrganizer(
    String organizerId, {
    bool? isUpcoming,
  }) async {
    var url = "${baseUrl}Event/organizer/$organizerId";
    final queryParams = <String, String>{};
    if (isUpcoming != null) {
      queryParams['isUpcoming'] = isUpcoming.toString();
    }
    var uri = queryParams.isEmpty
        ? Uri.parse(url)
        : Uri.parse(url).replace(queryParameters: queryParams);
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

  Future<List<BasicEvent>> getRecommendedEvents() async {
    var url = "${baseUrl}Event/recommended";
    var uri = Uri.parse(url).replace(queryParameters: {'isPublished': 'true'});
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

  Future<List<BasicEvent>> getPublicEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
    var url = "${baseUrl}Event/public";
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

  Future<List<BasicEvent>> getPrivateEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
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
    final queryParams = <String, String>{};
    if (filter != null && filter is Map) {
      filter.forEach((key, value) {
        queryParams[key.toString()] = value.toString();
      });
    }
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
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
    var uri = Uri.parse(url).replace(queryParameters: {'isPublished': 'true'});
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

  Future<void> toggleFavoriteEvent(String eventId) async {
    var url = "${baseUrl}Event/$eventId/favorite-toggle";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Failed to toggle favorite event");
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

  Future<List<BasicEvent>> searchEvents(String searchTerm) async {
    try {
      final result = await get(
        filter: {'SearchTerm': searchTerm, 'isPublished': true},
      );
      return result.result.map((e) => BasicEvent.fromJson(e.toJson())).toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  Future<void> deleteEvent(String id) async {
    var url = "${baseUrl}Event/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Unknown error in a DELETE request");
    }
  }
}
