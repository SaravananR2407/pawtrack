/// Represents a medication scheduled for a pet.
/// Tracks the medication name dosage scheduled time and taken status.
class Medication {
  /// Unique identifier for this medication.
  final String id;

  /// ID of the pet this medication is for.
  final String petId;

  /// Name of the medication.
  final String name;

  /// Dosage information such as 5mg or 1 tablet.
  final String dosage;

  /// Scheduled time for administering the medication.
  final DateTime time;

  /// Whether the medication has been marked as taken.
  bool taken;

  Medication({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.time,
    this.taken = false,
  });

  /// Converts this medication to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'name': name,
    'dosage': dosage,
    'time': time.toIso8601String(),
    'taken': taken,
  };

  /// Creates a Medication from a JSON map.
  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    petId: json['petId'],
    name: json['name'],
    dosage: json['dosage'],
    time: DateTime.parse(json['time']),
    taken: json['taken'],
  );
}