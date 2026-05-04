/// Represents a weight measurement for a pet on a specific date.
/// Used to track growth and health over time.
class WeightEntry {
  /// Unique identifier for this weight entry.
  final String id;

  /// ID of the pet this weight belongs to.
  final String petId;

  /// Date when the weight was measured.
  final DateTime date;

  /// Weight in kilograms.
  final double weightKg;

  WeightEntry({
    required this.id,
    required this.petId,
    required this.date,
    required this.weightKg,
  });

  /// Converts this weight entry to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'date': date.toIso8601String(),
    'weightKg': weightKg,
  };

  /// Creates a WeightEntry from a JSON map.
  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    id: json['id'],
    petId: json['petId'],
    date: DateTime.parse(json['date']),
    weightKg: json['weightKg'],
  );
}