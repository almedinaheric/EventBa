import 'dart:convert';
import 'package:eventba_admin/models/ticket/ticket.dart';
import 'package:eventba_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("Ticket");

  @override
  Ticket fromJson(data) {
    return Ticket.fromJson(data);
  }

  // Get tickets for a specific event
  Future<List<Ticket>> getTicketsForEvent(String eventId) async {
    var url = "${baseUrl}Ticket/event/$eventId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => fromJson(item)).toList();
      }
      return [];
    } else {
      throw Exception("Failed to load tickets for event");
    }
  }

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

  Future<void> deleteTicket(String ticketId) async {
    var url = "${baseUrl}Ticket/$ticketId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Failed to delete ticket");
    }
  }

  Future<void> deleteAllTicketsForEvent(String eventId) async {
    try {
      final tickets = await getTicketsForEvent(eventId);
      for (var ticket in tickets) {
        await deleteTicket(ticket.id);
      }
    } catch (e) {
      throw Exception("Failed to delete tickets for event");
    }
  }
}
