import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vet_visit.dart';

/// Manages veterinary visit records for the current user's pets.
/// Stores visit history including dates, notes and clinic information.
class VetProvider extends ChangeNotifier {
  List<VetVisit> _visits = [];
  String? _currentUserId;

  /// Returns the list of vet visits, sorted newest first.
  List<VetVisit> get visits => _visits;

  /// Sets the current user id and loads that user's vet visit data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadVisits();
  }

  /// Loads vet visits from SharedPreferences for the current user.
  Future<void> _loadVisits() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'vet_visits_$_currentUserId';
    final String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      List<dynamic> list = jsonDecode(jsonStr);
      _visits = list.map((e) => VetVisit.fromJson(e)).toList();
      _visits.sort((a, b) => b.date.compareTo(a.date));
    } else {
      _visits = [];
    }
    notifyListeners();
  }

  /// Saves the current vet visit list to SharedPreferences.
  Future<void> _saveVisits() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'vet_visits_$_currentUserId';
    final String encoded = jsonEncode(_visits.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new vet visit record at the beginning of the list.
  Future<void> addVisit(VetVisit visit) async {
    _visits.insert(0, visit);
    await _saveVisits();
    notifyListeners();
  }

  /// Deletes a vet visit record by its id.
  Future<void> deleteVisit(String id) async {
    _visits.removeWhere((v) => v.id == id);
    await _saveVisits();
    notifyListeners();
  }
}