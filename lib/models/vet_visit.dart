/// Represents a visit to a veterinarian.
/// Records the date reason and which pet was seen.
class VetVisit {
  /// Unique identifier for this vet visit.
  final String id;

  /// ID of the pet that visited the vet.
  final String petId;

  /// Date when the visit occurred.
  final DateTime date;

  /// Reason for the visit such as Checkup Vaccination or Injury.
  final String reason;

  VetVisit({
    required this.id,
    required this.petId,
    required this.date,
    required this.reason,
  });

  /// Converts this vet visit to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'date': date.toIso8601String(),
    'reason': reason,
  };

  /// Creates a VetVisit from a JSON map.
  factory VetVisit.fromJson(Map<String, dynamic> json) => VetVisit(
    id: json['id'],
    petId: json['petId'],
    date: DateTime.parse(json['date']),
    reason: json['reason'],
  );
}