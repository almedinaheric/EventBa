import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_purchase/ticket_purchase.dart';
import 'base_provider.dart';

class TicketPurchaseProvider extends BaseProvider<TicketPurchase> {
  TicketPurchaseProvider() : super("TicketPurchase");

  @override
  TicketPurchase fromJson(data) {
    return TicketPurchase.fromJson(data);
  }

  Future<List<TicketPurchase>> getMyPurchases({dynamic filter}) async {
    var url = "${baseUrl}TicketPurchase/my-purchases";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<TicketPurchase> purchases = [];
      for (var item in data) {
        purchases.add(fromJson(item));
      }
      return purchases;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
