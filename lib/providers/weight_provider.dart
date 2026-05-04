import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weight_entry.dart';

/// Manages weight tracking entries for the current user's pets.
/// Stores historical weight data for growth monitoring.
class WeightProvider extends ChangeNotifier {
  List<WeightEntry> _entries = [];
  String? _currentUserId;

  /// Returns the list of weight entries, sorted newest first.
  List<WeightEntry> get entries => _entries;

  /// Sets the current user id and loads that user's weight data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadEntries();
  }

  /// Loads weight entries from SharedPreferences for the current user.
  Future<void> _loadEntries() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'weights_$_currentUserId';
    final String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      List<dynamic> list = jsonDecode(jsonStr);
      _entries = list.map((e) => WeightEntry.fromJson(e)).toList();
      _entries.sort((a, b) => b.date.compareTo(a.date));
    } else {
      _entries = [];
    }
    notifyListeners();
  }

  /// Saves the current weight entry list to SharedPreferences.
  Future<void> _saveEntries() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'weights_$_currentUserId';
    final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new weight entry at the beginning of the list.
  Future<void> addEntry(WeightEntry entry) async {
    _entries.insert(0, entry);
    await _saveEntries();
    notifyListeners();
  }

  /// Deletes a weight entry by its id.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }
}