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

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String ticketId,
    required String eventId,
    required int quantity,
  }) async {
    var url = "${baseUrl}Payment/create-payment-intent";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({
      'amount': amount,
      'currency': currency,
      'ticketId': ticketId,
      'eventId': eventId,
      'quantity': quantity,
    });

    var response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create payment intent");
    }
  }
}
