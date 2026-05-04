import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/activity_entry.dart';

/// Manages pet activity entries such as meals and water intake.
/// Stores data locally using SharedPreferences scoped to the current user.
class ActivityProvider extends ChangeNotifier {
  List<ActivityEntry> _entries = [];
  String? _currentUserId;

  /// Returns the list of activity entries sorted newest first.
  List<ActivityEntry> get entries => _entries;

  /// Associates the provider with a specific user and loads that user's data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadEntries();
  }

  /// Loads activity entries from SharedPreferences for the current user.
  Future<void> _loadEntries() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'activities_$_currentUserId';
    final String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      List<dynamic> list = jsonDecode(jsonStr);
      _entries = list.map((e) => ActivityEntry.fromJson(e)).toList();
      _entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } else {
      _entries = [];
    }
    notifyListeners();
  }

  /// Saves the current list of entries to SharedPreferences.
  Future<void> _saveEntries() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'activities_$_currentUserId';
    final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new activity entry at the beginning of the list.
  Future<void> addEntry(ActivityEntry entry) async {
    _entries.insert(0, entry);
    await _saveEntries();
    notifyListeners();
  }

  /// Removes an activity entry by its unique id.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }

  /// Returns the most recent meal time for a given pet, or null if none exists.
  DateTime? getLastMealForPet(String petId) {
    final meals = _entries.where((e) => e.petId == petId && e.type == 'Meal').toList();
    return meals.isNotEmpty ? meals.first.dateTime : null;
  }

  /// Returns the most recent water intake time for a given pet, or null if none.
  DateTime? getLastWaterForPet(String petId) {
    final waters = _entries.where((e) => e.petId == petId && e.type == 'Water').toList();
    return waters.isNotEmpty ? waters.first.dateTime : null;
  }

  /// Checks whether a pet has had both a meal and water today.
  /// Returns true only if both events occurred on the current calendar day.
  bool isPetHealthyToday(String petId) {
    final today = DateTime.now();
    final lastMeal = getLastMealForPet(petId);
    if (lastMeal == null || lastMeal.day != today.day) return false;
    final lastWater = getLastWaterForPet(petId);
    if (lastWater == null || lastWater.day != today.day) return false;
    return true;
  }
}