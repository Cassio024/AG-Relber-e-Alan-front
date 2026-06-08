// lib/models/event_model.dart
class Event {
  final String id;
  final String userId;
  final String eventName;
  final String venue;
  final DateTime dateTime;
  final double value;
  final String status;
  final String description;

  Event({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.venue,
    required this.dateTime,
    this.value = 0.0,
    this.status = 'reserva',
    this.description = '',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      userId: json['userId'],
      eventName: json['eventName'],
      venue: json['venue'],
      dateTime: DateTime.parse(json['dateTime']),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
  status: json['status'] ?? 'reserva',
      description: json['description'] ?? '',
    );
  }
}
