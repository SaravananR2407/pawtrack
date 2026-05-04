/// Represents a push or in-app notification.
/// Used to schedule reminders for vet visits medication grooming and feeding.
class Notification {
  /// Unique identifier for this notification.
  final String id;

  /// Title of the notification.
  final String title;

  /// Body text of the notification.
  final String body;

  /// Scheduled time for the notification to appear.
  final DateTime scheduledTime;

  /// Whether the notification has already been delivered.
  bool isDelivered;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.isDelivered = false,
  });

  /// Converts this notification to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledTime': scheduledTime.toIso8601String(),
    'isDelivered': isDelivered,
  };

  /// Creates a Notification from a JSON map.
  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    scheduledTime: DateTime.parse(json['scheduledTime']),
    isDelivered: json['isDelivered'],
  );
}