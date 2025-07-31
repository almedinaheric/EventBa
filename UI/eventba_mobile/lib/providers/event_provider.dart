import 'package:eventba_mobile/models/event/basic_event.dart';
import 'base_provider.dart';

class EventProvider extends BaseProvider<BasicEvent> {
  EventProvider() : super("Event");

  @override
  BasicEvent fromJson(data) {
    return BasicEvent.fromJson(data);
  }
}
