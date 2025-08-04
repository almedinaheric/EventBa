import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification/notification.dart';
import 'base_provider.dart';

class NotificationProvider extends BaseProvider<Notification> {
  NotificationProvider() : super("Notification");

  @override
  Notification fromJson(data) {
    return Notification.fromJson(data);
  }

  Future<List<Notification>> getMyNotifications({dynamic filter}) async {
    var url = "${baseUrl}Notification/my-notifications";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Notification> notifications = [];
      for (var item in data) {
        notifications.add(fromJson(item));
      }
      return notifications;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<int> getUnreadCount() async {
    var url = "${baseUrl}Notification/unread-count";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return int.parse(response.body.toString());
    } else {
      throw Exception("Failed to fetch unread notification count");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    var url = "${baseUrl}Notification/$notificationId/mark-as-read";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Unknown error in a POST request");
    }
  }

  Future<void> markAllAsRead() async {
    var url = "${baseUrl}Notification/mark-all-as-read";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Unknown error in a POST request");
    }
  }
}
