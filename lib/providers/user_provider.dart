import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

/// Manages user authentication, registration and profile data.
/// Handles persistence of registered users and the currently logged-in user.
class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _registeredUsers = [];

  /// Returns the currently logged-in user or null if none.
  User? get currentUser => _currentUser;

  /// Returns true if a user is currently logged in.
  bool get isLoggedIn => _currentUser != null;

  UserProvider() {
    _loadUsers();
    _loadCurrentUser();
  }

  /// Loads the list of all registered users from SharedPreferences.
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('registeredUsers');
    if (usersJson != null) {
      List<dynamic> list = jsonDecode(usersJson);
      _registeredUsers = list.map((e) => User.fromJson(e)).toList();
    }
  }

  /// Saves the list of all registered users to SharedPreferences.
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_registeredUsers.map((e) => e.toJson()).toList());
    await prefs.setString('registeredUsers', encoded);
  }

  /// Loads the currently logged-in user from SharedPreferences.
  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  /// Saves the currently logged-in user to SharedPreferences.
  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
    } else {
      await prefs.remove('currentUser');
    }
  }

  /// Checks if a user with the given email already exists.
  bool _emailExists(String email) {
    return _registeredUsers.any((user) => user.email == email);
  }

  /// Registers a new user with name, email and password.
  /// Returns true if registration succeeded, false if email already exists.
  Future<bool> register(String name, String email, String password) async {
    if (_emailExists(email)) return false;
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
      profileImagePath: null,
    );
    _registeredUsers.add(newUser);
    await _saveUsers();
    _currentUser = newUser;
    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  /// Logs in an existing user with email and password.
  /// Returns true if credentials are correct, false otherwise.
  Future<bool> login(String email, String password) async {
    try {
      final user = _registeredUsers.firstWhere((u) => u.email == email);
      if (user.password != password) return false;
      _currentUser = user;
      await _saveCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Updates the current user's profile, optionally changing name or profile image.
  Future<void> updateProfile({String? name, String? profileImagePath}) async {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        password: _currentUser!.password,
        profileImagePath: profileImagePath ?? _currentUser!.profileImagePath,
      );
      final index = _registeredUsers.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        _registeredUsers[index] = _currentUser!;
        await _saveUsers();
      }
      await _saveCurrentUser();
      notifyListeners();
    }
  }

  /// Logs out the current user, clearing session data.
  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }
}