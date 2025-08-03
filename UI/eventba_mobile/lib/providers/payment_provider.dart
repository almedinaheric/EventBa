import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment/payment.dart';
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("Payment");

  @override
  Payment fromJson(data) {
    return Payment.fromJson(data);
  }

  Future<List<Payment>> getMyPayments({dynamic filter}) async {
    var url = "${baseUrl}Payment/my-payments";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Payment> payments = [];
      for (var item in data) {
        payments.add(fromJson(item));
      }
      return payments;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
