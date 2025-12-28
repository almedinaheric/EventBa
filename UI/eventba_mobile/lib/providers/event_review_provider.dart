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

  Future<EventReview> createReview({
    required String eventId,
    required int rating,
    required String comment,
  }) async {
    var url = "${baseUrl}EventReview";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var requestBody = jsonEncode({
      'eventId': eventId,
      'rating': rating,
      'comment': comment,
    });

    var response = await http.post(uri, headers: headers, body: requestBody);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create review");
    }
  }

  Future<EventReview?> getUserReviewForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final allReviews = await getReviewsForEvent(eventId);
      try {
        final userReview = allReviews.firstWhere(
          (review) => review.userId == userId,
        );
        return userReview;
      } catch (e) {
        
        return null;
      }
    } catch (e) {
      print("Error fetching user review: $e");
      return null;
    }
  }
}
