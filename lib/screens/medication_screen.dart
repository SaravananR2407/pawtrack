import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/medication_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../models/medication.dart';
import '../models/pet.dart';

/// Screen that displays and manages medications for all pets.
/// Allows adding new medications and deleting existing ones.
class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPetId;
  String? _selectedMed;
  String? _dosage;
  DateTime? _time;

  // Predefined list of common pet medications
  final List<String> _medications = [
    'Heartgard', 'NexGard', 'Frontline', 'Revolution', 'Simparica', 'Bravecto',
    'Amoxicillin', 'Cephalexin', 'Prednisone', 'Metronidazole'
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final medProvider = Provider.of<MedicationProvider>(context, listen: false);
    medProvider.setUserId(userProvider.currentUser!.id);
  }

  /// Adds a new medication entry after validating the form.
  Future<void> _addMedication() async {
    if (_formKey.currentState!.validate() && _selectedPetId != null && _selectedMed != null && _dosage != null && _time != null) {
      final med = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPetId!,
        name: _selectedMed!,
        dosage: _dosage!,
        time: _time!,
        taken: false,
      );
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      await provider.addMedication(med);
      if (mounted) {
        setState(() {});
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medProvider = Provider.of<MedicationProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final List<Pet> pets = petProvider.pets;
    final meds = medProvider.medications;

    // Only show medications where the pet still exists
    final validMeds = meds.where((m) => pets.any((p) => p.id == m.petId)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pets),
        child: const Icon(Icons.add),
      ),
      body: validMeds.isEmpty
          ? const Center(child: Text('No medications recorded. Tap + to add.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validMeds.length,
              itemBuilder: (_, i) {
                final m = validMeds[i];
                final pet = pets.firstWhere((p) => p.id == m.petId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${m.name} (${m.dosage})'),
                    subtitle: Text('${pet.emoji} ${pet.name} · ${DateFormat('h:mm a').format(m.time)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger),
                      onPressed: () => medProvider.deleteMedication(m.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a dialog form to add a new medication.
  void _showAddDialog(BuildContext context, List<Pet> pets) {
    _selectedPetId = null;
    _selectedMed = null;
    _dosage = null;
    _time = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Medication'),
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Medication'),
                items: _medications.map<DropdownMenuItem<String>>((String m) => DropdownMenuItem<String>(
                  value: m,
                  child: Text(m),
                )).toList(),
                onChanged: (String? v) => setState(() => _selectedMed = v),
                validator: (v) => v == null ? 'Select medication' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dosage (e.g., 1 tablet)'),
                onChanged: (v) => _dosage = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              ListTile(
                title: const Text('Scheduled time'),
                subtitle: Text(DateFormat('h:mm a').format(_time!)),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time != null && mounted) {
                    setState(() => _time = DateTime(0, 0, 0, time.hour, time.minute));
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addMedication, child: const Text('Save')),
        ],
      ),
    );
  }
}