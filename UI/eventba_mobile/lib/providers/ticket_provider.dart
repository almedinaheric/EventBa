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

  // Create a new ticket
  Future<Ticket> createTicket(Map<String, dynamic> ticketData) async {
    var url = "${baseUrl}Ticket";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(ticketData);

    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create ticket");
    }
  }

  // Update an existing ticket
  Future<Ticket> updateTicket(
    String ticketId,
    Map<String, dynamic> ticketData,
  ) async {
    var url = "${baseUrl}Ticket/$ticketId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(ticketData);

    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to update ticket");
    }
  }

  // Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    var url = "${baseUrl}Ticket/$ticketId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Failed to delete ticket");
    }
  }

  // Delete all tickets for an event
  Future<void> deleteAllTicketsForEvent(String eventId) async {
    try {
      final tickets = await getTicketsForEvent(eventId);
      for (var ticket in tickets) {
        await deleteTicket(ticket.id);
      }
    } catch (e) {
      print("Error deleting tickets: $e");
      throw Exception("Failed to delete tickets for event");
    }
  }

  // Validate a ticket by ticket code
  Future<void> validateTicket(String eventId, String ticketCode) async {
    var url = "${baseUrl}TicketPurchase/validate/$eventId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode({'ticketCode': ticketCode});

    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (!isValidResponse(response)) {
      var errorBody = jsonDecode(response.body);
      var errorMessage = errorBody['message'] ?? 'Failed to validate ticket';
      throw Exception(errorMessage);
    }
  }
}
