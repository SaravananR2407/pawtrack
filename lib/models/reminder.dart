/// Defines the type of reminder.
/// Options are medication vetVisit grooming feeding and other.
enum ReminderType { medication, vetVisit, grooming, feeding, other }

/// Defines the current status of a reminder.
/// Upcoming means not yet due. Due means should happen today.
/// Overdue means past due date. Done means completed.
enum ReminderStatus { upcoming, due, overdue, done }

/// Represents a scheduled reminder for a pet.
/// Includes title type date time frequency notes and current status.
class Reminder {
  /// Unique identifier for this reminder.
  final String id;

  /// ID of the pet this reminder belongs to.
  final String petId;

  /// Name of the pet for display purposes.
  final String petName;

  /// Emoji representing the pet.
  final String petEmoji;

  /// Title or description of the reminder.
  final String title;

  /// Type of reminder such as medication or vet visit.
  final ReminderType type;

  /// Date and time when the reminder is scheduled.
  final DateTime dateTime;

  /// How often the reminder repeats e.g., daily weekly monthly.
  final String frequency;

  /// Optional additional notes about the reminder.
  final String? notes;

  /// Current status of the reminder.
  final ReminderStatus status;

  const Reminder({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petEmoji,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.frequency,
    this.notes,
    required this.status,
  });

  /// Returns an emoji that represents the reminder type.
  /// Medication shows 💊, vet visit shows 🏥, grooming shows 🪮,
  /// feeding shows 🥕, and other shows 📝.
  String get typeEmoji {
    switch (type) {
      case ReminderType.medication: return '💊';
      case ReminderType.vetVisit: return '🏥';
      case ReminderType.grooming: return '🪮';
      case ReminderType.feeding: return '🥕';
      case ReminderType.other: return '📝';
    }
  }

  /// Converts this reminder to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'petName': petName,
    'petEmoji': petEmoji,
    'title': title,
    'type': type.index,
    'dateTime': dateTime.toIso8601String(),
    'frequency': frequency,
    'notes': notes,
    'status': status.index,
  };

  /// Creates a Reminder from a JSON map.
  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    petId: json['petId'],
    petName: json['petName'],
    petEmoji: json['petEmoji'],
    title: json['title'],
    type: ReminderType.values[json['type']],
    dateTime: DateTime.parse(json['dateTime']),
    frequency: json['frequency'],
    notes: json['notes'],
    status: ReminderStatus.values[json['status']],
  );
}