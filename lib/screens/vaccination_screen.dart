import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/vaccine_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';
import '../models/vaccine.dart';

/// Maps each species to a list of recommended vaccines with their core status.
/// Keys are Dog Cat Rabbit Bird etc. Values are lists of vaccine name and type.
final Map<String, List<Map<String, String>>> vaccineTypes = {
  'Dog': [
    {'name': 'Rabies', 'type': 'Core'},
    {'name': 'DHPP', 'type': 'Core'},
    {'name': 'Bordetella', 'type': 'Optional'},
    {'name': 'Leptospirosis', 'type': 'Core'},
    {'name': 'Lyme', 'type': 'Optional'},
    {'name': 'Canine Influenza', 'type': 'Optional'},
  ],
  'Cat': [
    {'name': 'Rabies', 'type': 'Core'},
    {'name': 'FVRCP', 'type': 'Core'},
    {'name': 'FeLV', 'type': 'Core'},
    {'name': 'FIP', 'type': 'Optional'},
    {'name': 'Chlamydia', 'type': 'Optional'},
  ],
  'Rabbit': [
    {'name': 'RHDV', 'type': 'Core'},
    {'name': 'Myxomatosis', 'type': 'Core'},
  ],
  'Bird': [
    {'name': 'Polyomavirus', 'type': 'Core'},
    {'name': 'Poxvirus', 'type': 'Optional'},
  ],
};

/// Converts a pet emoji to a species name string for vaccine lookup.
String _getSpeciesFromEmoji(String emoji) {
  switch (emoji) {
    case '🐶': return 'Dog';
    case '🐱': return 'Cat';
    case '🐰': return 'Rabbit';
    case '🐹': return 'Hamster';
    case '🐦': return 'Bird';
    case '🐟': return 'Fish';
    case '🐢': return 'Turtle';
    default: return 'Other';
  }
}

/// Screen for managing pet vaccination records.
/// Allows adding new vaccines and deleting existing entries.
class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPetId;
  String? _selectedVaccine;
  DateTime? _dateTaken;
  DateTime? _nextDue;

  /// Returns the list of available vaccine names for the currently selected pet.
  List<String> get _availableVaccines {
    if (_selectedPetId == null) return [];
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((p) => p.id == _selectedPetId);
    final species = _getSpeciesFromEmoji(pet.emoji);
    final vaccines = vaccineTypes[species] ?? [];
    return vaccines.map((v) => v['name']!).toList();
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vaccineProvider = Provider.of<VaccineProvider>(context, listen: false);
    vaccineProvider.setUserId(userProvider.currentUser!.id);
  }

  /// Validates and adds a new vaccine record.
  Future<void> _addVaccine() async {
    if (_formKey.currentState!.validate() && _selectedPetId != null && _dateTaken != null && _nextDue != null) {
      final vaccine = Vaccine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPetId!,
        name: _selectedVaccine!,
        dateTaken: _dateTaken!,
        nextDue: _nextDue!,
      );
      final provider = Provider.of<VaccineProvider>(context, listen: false);
      await provider.addVaccine(vaccine);
      if (mounted) {
        setState(() {});
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaccineProvider = Provider.of<VaccineProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final List<Pet> pets = petProvider.pets;
    final vaccines = vaccineProvider.vaccines;

    // Only show vaccines where the pet still exists
    final validVaccines = vaccines.where((v) => pets.any((p) => p.id == v.petId)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pets),
        child: const Icon(Icons.add),
      ),
      body: validVaccines.isEmpty
          ? const Center(child: Text('No vaccine records yet. Tap + to add.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validVaccines.length,
              itemBuilder: (_, i) {
                final v = validVaccines[i];
                final pet = pets.firstWhere((p) => p.id == v.petId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${v.name}  ·  ${pet.emoji} ${pet.name}'),
                    subtitle: Text('Taken: ${DateFormat('MMM d, yyyy').format(v.dateTaken)}  |  Next: ${DateFormat('MMM d, yyyy').format(v.nextDue)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger),
                      onPressed: () => vaccineProvider.deleteVaccine(v.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a dialog form to add a new vaccine record.
  void _showAddDialog(BuildContext context, List<Pet> pets) {
    _selectedPetId = null;
    _selectedVaccine = null;
    _dateTaken = DateTime.now();
    _nextDue = DateTime.now().add(const Duration(days: 365));
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Vaccination'),
        content: Form(
          key: _formKey,
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: pets.map<DropdownMenuItem<String>>((Pet pet) => DropdownMenuItem<String>(
                    value: pet.id,
                    child: Text('${pet.emoji} ${pet.name}'),
                  )).toList(),
                  onChanged: (String? v) {
                    setState(() => _selectedPetId = v);
                    setDialogState(() {});
                  },
                  validator: (v) => v == null ? 'Select pet' : null,
                ),
                if (_selectedPetId != null)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Vaccine'),
                    items: _availableVaccines.map<DropdownMenuItem<String>>((String v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v),
                    )).toList(),
                    onChanged: (String? v) => setState(() => _selectedVaccine = v),
                    validator: (v) => v == null ? 'Select vaccine' : null,
                  ),
                ListTile(
                  title: const Text('Date taken'),
                  subtitle: Text(_dateTaken == null ? 'Select date' : DateFormat('MMM d, yyyy').format(_dateTaken!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && mounted) setState(() => _dateTaken = date);
                  },
                ),
                ListTile(
                  title: const Text('Next due date'),
                  subtitle: Text(_nextDue == null ? 'Select date' : DateFormat('MMM d, yyyy').format(_nextDue!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 1095)),
                    );
                    if (date != null && mounted) setState(() => _nextDue = date);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addVaccine, child: const Text('Save')),
        ],
      ),
    );
  }
}