import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';

/// Screen for adding a new pet or editing an existing one.
/// Uses a form to collect pet details such as name breed age weight gender and emoji.
class AddEditPetScreen extends StatefulWidget {
  /// The pet to edit. If null the screen is in add mode.
  final Pet? pet;
  const AddEditPetScreen({super.key, this.pet});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _genderController;

  String _selectedEmoji = '🐶';

  /// List of available emoji options with labels for Dog Cat Rabbit etc.
  final List<Map<String, String>> _emojiOptions = [
    {'emoji': '🐶', 'label': 'Dog'},
    {'emoji': '🐱', 'label': 'Cat'},
    {'emoji': '🐰', 'label': 'Rabbit'},
    {'emoji': '🐹', 'label': 'Hamster'},
    {'emoji': '🐦', 'label': 'Bird'},
    {'emoji': '🐟', 'label': 'Fish'},
    {'emoji': '🐢', 'label': 'Turtle'},
  ];

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _ageController = TextEditingController(text: pet?.ageYears.toString() ?? '');
    _weightController = TextEditingController(text: pet?.weightKg.toString() ?? '');
    _genderController = TextEditingController(text: pet?.gender ?? '');
    _selectedEmoji = pet?.emoji ?? '🐶';
  }

  /// Validates the form and saves the pet (add or update) using PetProvider.
  void _save() {
    if (_formKey.currentState!.validate()) {
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        breed: _breedController.text,
        ageYears: int.parse(_ageController.text),
        weightKg: double.parse(_weightController.text),
        gender: _genderController.text,
        emoji: _selectedEmoji,
      );
      if (widget.pet == null) {
        petProvider.addPet(pet);
      } else {
        petProvider.updatePet(pet);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Custom app bar with back button and title
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: AppTheme.primary,
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                Text(isEditing ? 'Edit Pet' : 'Add Pet', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLabel('Pet'),
                    // Emoji selection grid
                    Wrap(
                      spacing: 12,
                      children: _emojiOptions.map((e) {
                        final isSelected = _selectedEmoji == e['emoji'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = e['emoji']!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryLight : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Text(e['emoji']!, style: const TextStyle(fontSize: 32)),
                                Text(e['label']!, style: GoogleFonts.quicksand(fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Name'),
                    TextFormField(controller: _nameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildLabel('Breed (optional)'),
                    TextFormField(controller: _breedController),
                    const SizedBox(height: 16),
                    _buildLabel('Age (years)'),
                    TextFormField(controller: _ageController, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildLabel('Weight (kg)'),
                    TextFormField(controller: _weightController, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildLabel('Gender'),
                    TextFormField(controller: _genderController),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _save, child: Text(isEditing ? 'Update Pet' : 'Add Pet')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build a section label with consistent styling.
  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)));
}