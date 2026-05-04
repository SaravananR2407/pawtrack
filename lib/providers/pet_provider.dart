import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet.dart';

/// Manages the list of pets for the current user.
/// Handles CRUD operations and tracks weight changes.
class PetProvider extends ChangeNotifier {
  List<Pet> _pets = [];
  String? _currentUserId;

  /// Returns the list of all pets.
  List<Pet> get pets => _pets;

  /// Sets the current user id and loads that user's pet data.
  void setUserId(String userId) {
    _currentUserId = userId;
    _loadPets();
  }

  /// Loads pets from SharedPreferences.
  Future<void> _loadPets() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'pets_$_currentUserId';
    final String? petsJson = prefs.getString(key);
    if (petsJson != null) {
      List<dynamic> list = jsonDecode(petsJson);
      _pets = list.map((e) => Pet.fromJson(e)).toList();
    } else {
      _pets = [];
    }
    notifyListeners();
  }

  /// Saves the current pet list to SharedPreferences.
  Future<void> _savePets() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'pets_$_currentUserId';
    final String encoded = jsonEncode(_pets.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Adds a new pet.
  void addPet(Pet pet) {
    _pets.add(pet);
    _savePets();
    notifyListeners();
  }

  /// Updates an existing pet and tracks weight changes automatically.
  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      // If weight changed store previous weight and date
      final oldWeight = _pets[index].weightKg;
      if (oldWeight != pet.weightKg) {
        pet.previousWeightKg = oldWeight;
        pet.lastWeightUpdate = DateTime.now();
      } else {
        // Keep previous values
        pet.previousWeightKg = _pets[index].previousWeightKg;
        pet.lastWeightUpdate = _pets[index].lastWeightUpdate;
      }
      _pets[index] = pet;
      _savePets();
      notifyListeners();
    }
  }

  /// Deletes a pet by its id.
  void deletePet(String id) {
    _pets.removeWhere((p) => p.id == id);
    _savePets();
    notifyListeners();
  }
}