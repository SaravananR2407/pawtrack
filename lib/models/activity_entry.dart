/// Records a single activity for a pet.
/// Activity types include Meal Water and Exercise.
class ActivityEntry {
  /// Unique identifier for this activity entry.
  final String id;

  /// ID of the pet this activity belongs to.
  final String petId;

  /// Date and time when the activity occurred.
  final DateTime dateTime;

  /// Type of activity. Allowed values are Meal Water or Exercise.
  final String type;

  ActivityEntry({
    required this.id,
    required this.petId,
    required this.dateTime,
    required this.type,
  });

  /// Converts this activity entry to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'dateTime': dateTime.toIso8601String(),
    'type': type,
  };

  /// Creates an ActivityEntry from a JSON map.
  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: json['id'],
    petId: json['petId'],
    dateTime: DateTime.parse(json['dateTime']),
    type: json['type'],
  );
}