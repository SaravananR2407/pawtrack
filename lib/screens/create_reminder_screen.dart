import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../providers/pet_provider.dart';

/// Screen for creating a new reminder or editing an existing one.
/// Allows selection of reminder type pet date time frequency and optional notes.
class CreateReminderScreen extends StatefulWidget {
  /// If provided the screen will edit this reminder instead of creating a new one.
  final Reminder? existingReminder;
  const CreateReminderScreen({super.key, this.existingReminder});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  ReminderType _selectedType = ReminderType.medication;
  String _selectedPetId = '';
  String _selectedPetName = '';
  String _selectedPetEmoji = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFrequency = 'Once';
  bool _isLoading = false;

  final List<String> _frequencies = ['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      // Populate fields when editing an existing reminder
      final r = widget.existingReminder!;
      _titleController.text = r.title;
      _notesController.text = r.notes ?? '';
      _selectedType = r.type;
      _selectedPetId = r.petId;
      _selectedPetName = r.petName;
      _selectedPetEmoji = r.petEmoji;
      _selectedDate = r.dateTime;
      _selectedTime = TimeOfDay(hour: r.dateTime.hour, minute: r.dateTime.minute);
      _selectedFrequency = r.frequency;
    } else {
      // Default to the first pet when creating a new reminder
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      if (petProvider.pets.isNotEmpty) {
        final firstPet = petProvider.pets.first;
        _selectedPetId = firstPet.id;
        _selectedPetName = firstPet.name;
        _selectedPetEmoji = firstPet.emoji;
      }
    }
  }

  /// Shows a date picker dialog and updates the selected date.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Shows a time picker dialog and updates the selected time.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  /// Validates and saves the reminder add or update to ReminderProvider.
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final reminder = Reminder(
        id: widget.existingReminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPetId,
        petName: _selectedPetName,
        petEmoji: _selectedPetEmoji,
        title: _titleController.text,
        type: _selectedType,
        dateTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        frequency: _selectedFrequency,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        status: _selectedDate.isAfter(DateTime.now()) ? ReminderStatus.upcoming : ReminderStatus.due,
      );
      if (widget.existingReminder == null) {
        reminderProvider.addReminder(reminder);
      } else {
        reminderProvider.updateReminder(reminder);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingReminder == null ? 'Reminder added!' : 'Reminder updated!'),
            backgroundColor: AppTheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Shows a confirmation dialog and deletes the reminder if confirmed.
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed == true) {
      if (mounted) {
        Provider.of<ReminderProvider>(context, listen: false).deleteReminder(widget.existingReminder!.id);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final pets = petProvider.pets;

    // If selected pet was deleted, fallback to first available pet
    if (_selectedPetId.isNotEmpty && !pets.any((p) => p.id == _selectedPetId) && pets.isNotEmpty) {
      final firstPet = pets.first;
      _selectedPetId = firstPet.id;
      _selectedPetName = firstPet.name;
      _selectedPetEmoji = firstPet.emoji;
    }

    // Show error state if no pets exist
    if (pets.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No pets yet!', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Please add a pet before creating reminders.', style: GoogleFonts.quicksand()),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final isEditing = widget.existingReminder != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Custom app bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: AppTheme.primary,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                Text(
                  isEditing ? 'Edit Reminder' : 'Add Reminder',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Reminder Name'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'e.g. Heartworm Tablet'),
                      validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Type'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<ReminderType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(),
                      items: ReminderType.values.map((type) {
                        String label;
                        switch (type) {
                          case ReminderType.medication: label = '💊 Medication'; break;
                          case ReminderType.vetVisit: label = '🏥 Vet Visit'; break;
                          case ReminderType.grooming: label = '🪮 Grooming'; break;
                          case ReminderType.feeding: label = '🥕 Feeding'; break;
                          case ReminderType.other: label = '📝 Other'; break;
                        }
                        return DropdownMenuItem(value: type, child: Text(label));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Pet'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPetId,
                      decoration: const InputDecoration(),
                      items: pets.map((pet) {
                        return DropdownMenuItem(
                          value: pet.id,
                          child: Text('${pet.emoji} ${pet.name}'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        final pet = pets.firstWhere((p) => p.id == v);
                        setState(() {
                          _selectedPetId = pet.id;
                          _selectedPetName = pet.name;
                          _selectedPetEmoji = pet.emoji;
                        });
                      },
                      validator: (v) => v == null ? 'Please select a pet' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.border, width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(_selectedDate),
                                        style: GoogleFonts.quicksand(fontSize: 13, color: AppTheme.darkGreen),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.border, width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_outlined, size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedTime.format(context),
                                        style: GoogleFonts.quicksand(fontSize: 13, color: AppTheme.darkGreen),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Frequency'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFrequency,
                      decoration: const InputDecoration(),
                      items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) => setState(() => _selectedFrequency = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Notes (Optional)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Any special instructions...'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEditing ? 'Update Reminder' : 'Create Reminder'),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: AppTheme.danger),
                        ),
                        child: const Text('Delete Reminder'),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build an uppercase section label.
  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryDark,
        letterSpacing: 0.5,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}