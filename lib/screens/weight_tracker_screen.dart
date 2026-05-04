import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/weight_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../models/weight_entry.dart';
import '../models/pet.dart';

/// Screen for tracking pet weight over time.
/// Allows adding weight entries and deleting them.
class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPetId;
  double? _weight;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final weightProvider = Provider.of<WeightProvider>(context, listen: false);
    weightProvider.setUserId(userProvider.currentUser!.id);
  }

  /// Validates and adds a new weight entry.
  Future<void> _addEntry() async {
    if (_formKey.currentState!.validate() && _selectedPetId != null && _weight != null && _date != null) {
      final entry = WeightEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPetId!,
        date: _date!,
        weightKg: _weight!,
      );
      final provider = Provider.of<WeightProvider>(context, listen: false);
      await provider.addEntry(entry);
      if (mounted) {
        setState(() {});
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightProvider = Provider.of<WeightProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final List<Pet> pets = petProvider.pets;
    final entries = weightProvider.entries;

    // Only show entries where the pet still exists
    final validEntries = entries.where((e) => pets.any((p) => p.id == e.petId)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pets),
        child: const Icon(Icons.add),
      ),
      body: validEntries.isEmpty
          ? const Center(child: Text('No weight entries yet. Tap + to add.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validEntries.length,
              itemBuilder: (_, i) {
                final e = validEntries[i];
                final pet = pets.firstWhere((p) => p.id == e.petId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${e.weightKg} kg'),
                    subtitle: Text('${pet.emoji} ${pet.name} · ${DateFormat('MMM d, yyyy').format(e.date)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger),
                      onPressed: () => weightProvider.deleteEntry(e.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a dialog form to add a new weight entry.
  void _showAddDialog(BuildContext context, List<Pet> pets) {
    _selectedPetId = null;
    _weight = null;
    _date = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Weight Entry'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Pet'),
                items: pets.map<DropdownMenuItem<String>>((Pet pet) => DropdownMenuItem<String>(
                  value: pet.id,
                  child: Text('${pet.emoji} ${pet.name}'),
                )).toList(),
                onChanged: (String? v) => setState(() => _selectedPetId = v),
                validator: (v) => v == null ? 'Select pet' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _weight = double.tryParse(v),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_date!)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && mounted) setState(() => _date = date);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addEntry, child: const Text('Save')),
        ],
      ),
    );
  }
}