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

    print('Payment intent request: $body');
    var response = await http.post(uri, headers: headers, body: body);
    print('Payment intent response status: ${response.statusCode}');
    print('Payment intent response body: ${response.body}');

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error'] ??
            errorData['message'] ??
            'Failed to create payment intent';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception(
          "Failed to create payment intent: ${response.statusCode} - ${response.body}",
        );
      }
    }
  }
}
