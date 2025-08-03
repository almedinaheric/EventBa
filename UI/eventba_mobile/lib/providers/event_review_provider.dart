import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_review/event_review.dart';
import 'base_provider.dart';

class EventReviewProvider extends BaseProvider<EventReview> {
  EventReviewProvider() : super("EventReview");

  @override
  EventReview fromJson(data) {
    return EventReview.fromJson(data);
  }

  Future<List<EventReview>> getReviewsForEvent(String eventId) async {
    var url = "${baseUrl}EventReview/event/$eventId";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<EventReview> reviews = [];
      for (var item in data) {
        reviews.add(fromJson(item));
      }
      return reviews;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<double> getAverageRatingForEvent(String eventId) async {
    var url = "${baseUrl}EventReview/event/$eventId/average-rating";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data['averageRating'].toDouble();
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
