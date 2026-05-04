/// Represents an application user.
/// Stores authentication credentials and profile information.
class User {
  /// Unique identifier for this user.
  final String id;

  /// Display name of the user.
  final String name;

  /// Email address used for login and identification.
  final String email;

  /// Password for authentication. Stored as plain text in this example.
  final String password;

  /// Optional file path to the user's profile image.
  final String? profileImagePath;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImagePath,
  });

  /// Converts this user to a JSON map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'profileImagePath': profileImagePath,
  };

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    profileImagePath: json['profileImagePath'],
  );
}