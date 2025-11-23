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

  Future<List<Notification>> getSystemNotifications() async {
    var url = "${baseUrl}Notification/system-notifications";
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
      throw Exception("Failed to load system notifications");
    }
  }
}
