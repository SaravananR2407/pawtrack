import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reminder.dart';

/// Manages reminders such as vet visits, medication, grooming and feeding.
/// Stores data locally using SharedPreferences for the current user.
class ReminderProvider extends ChangeNotifier {
  List<Reminder> _reminders = [];
  String? _currentUserId;

  /// Returns the list of all reminders.
  List<Reminder> get reminders => _reminders;

  /// Sets the current user id and loads that user's reminder data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadReminders();
  }

  /// Loads reminders from SharedPreferences.
  Future<void> _loadReminders() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'reminders_$_currentUserId';
    final String? remindersJson = prefs.getString(key);
    if (remindersJson != null) {
      List<dynamic> list = jsonDecode(remindersJson);
      _reminders = list.map((e) => Reminder.fromJson(e)).toList();
    } else {
      _reminders = [];
    }
    notifyListeners();
  }

  /// Saves the current reminder list to SharedPreferences.
  Future<void> _saveReminders() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'reminders_$_currentUserId';
    final String encoded = jsonEncode(_reminders.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new reminder.
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    _saveReminders();
    notifyListeners();
  }

  /// Updates an existing reminder by id.
  void updateReminder(Reminder reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      _saveReminders();
      notifyListeners();
    }
  }

  /// Deletes a reminder by its id.
  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    _saveReminders();
    notifyListeners();
  }
}