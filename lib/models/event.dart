
import '../interfaces/events.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final Iterable<EventType> types;
  DateTime startDate;
  DateTime endDate;
  EventStatus status=EventStatus.proposed;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.types,
    required this.startDate,
    required this.endDate
  });
}
