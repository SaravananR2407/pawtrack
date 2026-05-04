import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/vet_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';
import '../models/vet_visit.dart';

/// Screen for managing veterinary visit records.
/// Allows adding new visits with reason and date, and deleting existing entries.
class VetVisitsScreen extends StatefulWidget {
  const VetVisitsScreen({super.key});

  @override
  State<VetVisitsScreen> createState() => _VetVisitsScreenState();
}

class _VetVisitsScreenState extends State<VetVisitsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPetId;
  String? _reason;
  DateTime? _date;

  /// Predefined list of common reasons for vet visits.
  final List<String> _reasons = ['Checkup', 'Vaccination', 'Injury', 'Surgery', 'Dental', 'Lab Test', 'Emergency'];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vetProvider = Provider.of<VetProvider>(context, listen: false);
    vetProvider.setUserId(userProvider.currentUser!.id);
  }

  /// Validates and adds a new vet visit record.
  Future<void> _addVisit() async {
    if (_formKey.currentState!.validate() && _selectedPetId != null && _reason != null && _date != null) {
      final visit = VetVisit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPetId!,
        date: _date!,
        reason: _reason!,
      );
      final provider = Provider.of<VetProvider>(context, listen: false);
      await provider.addVisit(visit);
      if (mounted) {
        setState(() {});
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vetProvider = Provider.of<VetProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final List<Pet> pets = petProvider.pets;
    final visits = vetProvider.visits;

    // Only show visits where the pet still exists
    final validVisits = visits.where((v) => pets.any((p) => p.id == v.petId)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pets),
        child: const Icon(Icons.add),
      ),
      body: validVisits.isEmpty
          ? const Center(child: Text('No vet visits recorded. Tap + to add.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validVisits.length,
              itemBuilder: (_, i) {
                final v = validVisits[i];
                final pet = pets.firstWhere((p) => p.id == v.petId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(v.reason),
                    subtitle: Text('${pet.emoji} ${pet.name} · ${DateFormat('MMM d, yyyy').format(v.date)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger),
                      onPressed: () => vetProvider.deleteVisit(v.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a dialog form to add a new vet visit.
  void _showAddDialog(BuildContext context, List<Pet> pets) {
    _selectedPetId = null;
    _reason = null;
    _date = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Vet Visit'),
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
                decoration: const InputDecoration(labelText: 'Reason'),
                items: _reasons.map<DropdownMenuItem<String>>((String r) => DropdownMenuItem<String>(
                  value: r,
                  child: Text(r),
                )).toList(),
                onChanged: (String? v) => setState(() => _reason = v),
                validator: (v) => v == null ? 'Select reason' : null,
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
          ElevatedButton(onPressed: _addVisit, child: const Text('Save')),
        ],
      ),
    );
  }
}