import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vaccine.dart';

/// Manages vaccine records for the current user's pets.
/// Stores and retrieves vaccine data using SharedPreferences.
class VaccineProvider extends ChangeNotifier {
  List<Vaccine> _vaccines = [];
  String? _currentUserId;

  /// Returns the list of all vaccine records.
  List<Vaccine> get vaccines => _vaccines;

  /// Sets the current user id and loads that user's vaccine data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadVaccines();
  }

  /// Loads vaccines from SharedPreferences for the current user.
  Future<void> _loadVaccines() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'vaccines_$_currentUserId';
    final String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      List<dynamic> list = jsonDecode(jsonStr);
      _vaccines = list.map((e) => Vaccine.fromJson(e)).toList();
    } else {
      _vaccines = [];
    }
    notifyListeners();
  }

  /// Saves the current vaccine list to SharedPreferences.
  Future<void> _saveVaccines() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'vaccines_$_currentUserId';
    final String encoded = jsonEncode(_vaccines.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new vaccine record.
  Future<void> addVaccine(Vaccine vaccine) async {
    _vaccines.add(vaccine);
    await _saveVaccines();
    notifyListeners();
  }

  /// Deletes a vaccine record by its id.
  Future<void> deleteVaccine(String id) async {
    _vaccines.removeWhere((v) => v.id == id);
    await _saveVaccines();
    notifyListeners();
  }
}