/// Represents a vaccine administered to a pet.
/// Tracks the vaccine name and dates for taken and next due.
class Vaccine {
  /// Unique identifier for this vaccine record.
  final String id;

  /// ID of the pet that received the vaccine.
  final String petId;

  /// Name of the vaccine.
  final String name;

  /// Date when the vaccine was administered.
  final DateTime dateTaken;

  /// Date when the next dose is due.
  final DateTime nextDue;

  Vaccine({
    required this.id,
    required this.petId,
    required this.name,
    required this.dateTaken,
    required this.nextDue,
  });

  /// Converts this vaccine record to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'name': name,
    'dateTaken': dateTaken.toIso8601String(),
    'nextDue': nextDue.toIso8601String(),
  };

  /// Creates a Vaccine from a JSON map.
  factory Vaccine.fromJson(Map<String, dynamic> json) => Vaccine(
    id: json['id'],
    petId: json['petId'],
    name: json['name'],
    dateTaken: DateTime.parse(json['dateTaken']),
    nextDue: DateTime.parse(json['nextDue']),
  );
}