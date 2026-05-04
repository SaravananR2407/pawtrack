/// Represents a pet owned by the user.
/// Stores basic information and tracks weight changes over time.
class Pet {
  /// Unique identifier for this pet.
  final String id;

  /// Name of the pet.
  final String name;

  /// Breed of the pet.
  final String breed;

  /// Age of the pet in years.
  final int ageYears;

  /// Current weight of the pet in kilograms.
  double weightKg;

  /// Gender of the pet. Expected values Male or Female.
  final String gender;

  /// Emoji representing the pet (e.g. 🐕 🐈).
  final String emoji;

  /// Previously recorded weight in kilograms. Used to show weight change.
  double? previousWeightKg;

  /// Date and time when the current weight was last updated.
  DateTime? lastWeightUpdate;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.gender,
    required this.emoji,
    this.previousWeightKg,
    this.lastWeightUpdate,
  });

  /// Converts this pet to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'breed': breed,
    'ageYears': ageYears,
    'weightKg': weightKg,
    'gender': gender,
    'emoji': emoji,
    'previousWeightKg': previousWeightKg,
    'lastWeightUpdate': lastWeightUpdate?.toIso8601String(),
  };

  /// Creates a Pet from a JSON map.
  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'],
    name: json['name'],
    breed: json['breed'],
    ageYears: json['ageYears'],
    weightKg: json['weightKg'],
    gender: json['gender'],
    emoji: json['emoji'],
    previousWeightKg: json['previousWeightKg'],
    lastWeightUpdate: json['lastWeightUpdate'] != null ? DateTime.parse(json['lastWeightUpdate']) : null,
  );
}