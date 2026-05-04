import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication.dart';

/// Manages the list of medications for the current user.
/// Supports adding, updating, deleting, and toggling the taken status.
class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  String? _currentUserId;

  /// Returns the list of all medications.
  List<Medication> get medications => _medications;

  /// Sets the current user id and loads that user's medication data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadMedications();
  }

  /// Loads medications from SharedPreferences.
  Future<void> _loadMedications() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'medications_$_currentUserId';
    final String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      List<dynamic> list = jsonDecode(jsonStr);
      _medications = list.map((e) => Medication.fromJson(e)).toList();
    } else {
      _medications = [];
    }
    notifyListeners();
  }

  /// Saves the current medication list to SharedPreferences.
  Future<void> _saveMedications() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'medications_$_currentUserId';
    final String encoded = jsonEncode(_medications.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new medication.
  Future<void> addMedication(Medication med) async {
    _medications.add(med);
    await _saveMedications();
    notifyListeners();
  }

  /// Updates an existing medication by id.
  Future<void> updateMedication(Medication med) async {
    final index = _medications.indexWhere((m) => m.id == med.id);
    if (index != -1) {
      _medications[index] = med;
      await _saveMedications();
      notifyListeners();
    }
  }

  /// Deletes a medication by its id.
  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    await _saveMedications();
    notifyListeners();
  }

  /// Toggles the taken status of a medication.
  Future<void> toggleTaken(String id) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index].taken = !_medications[index].taken;
      await _saveMedications();
      notifyListeners();
    }
  }
}