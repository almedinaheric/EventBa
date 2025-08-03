import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket/ticket.dart';
import '../models/ticket_purchase/ticket_purchase.dart';
import 'base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("Ticket");

  @override
  Ticket fromJson(data) {
    return Ticket.fromJson(data);
  }

  TicketPurchase ticketPurchaseFromJson(data) {
    return TicketPurchase.fromJson(data);
  }

  Future<List<TicketPurchase>> getUserTickets({dynamic filter}) async {
    var url = "${baseUrl}Ticket/my-tickets";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<TicketPurchase> tickets = [];
      for (var item in data) {
        tickets.add(ticketPurchaseFromJson(item));
      }
      return tickets;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<TicketPurchase>> getUpcomingTickets({dynamic filter}) async {
    var url = "${baseUrl}Ticket/upcoming";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<TicketPurchase> tickets = [];
      for (var item in data) {
        tickets.add(ticketPurchaseFromJson(item));
      }
      return tickets;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<TicketPurchase>> getPastTickets({dynamic filter}) async {
    var url = "${baseUrl}Ticket/past";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<TicketPurchase> tickets = [];
      for (var item in data) {
        tickets.add(ticketPurchaseFromJson(item));
      }
      return tickets;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<Ticket>> getTicketsForEvent(String eventId) async {
    var url = "${baseUrl}Ticket/event/$eventId";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<Ticket> tickets = [];
      for (var item in data) {
        tickets.add(fromJson(item));
      }
      return tickets;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
