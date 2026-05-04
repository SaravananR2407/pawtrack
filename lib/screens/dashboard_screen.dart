import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/pet.dart';
import '../models/activity_entry.dart';
import 'schedule_screen.dart';
import 'create_reminder_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'add_edit_pet_screen.dart';
import 'care_screen.dart';

/// Main dashboard screen showing pet overview health stats daily activities and reminders.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;
  int _selectedPetIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data for the logged-in user after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        petProvider.setUserId(userProvider.currentUser!.id);
        reminderProvider.setUserId(userProvider.currentUser!.id);
        activityProvider.setUserId(userProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final pets = petProvider.pets;
    final selectedPet = pets.isNotEmpty ? pets[_selectedPetIndex % pets.length] : null;

    // Filter reminders that are due today for the selected pet
    final todayReminders = (selectedPet != null)
        ? reminderProvider.reminders.where((r) {
            final now = DateTime.now();
            return r.petId == selectedPet.id &&
                r.dateTime.year == now.year &&
                r.dateTime.month == now.month &&
                r.dateTime.day == now.day;
          }).toList()
        : [];

    final lastMeal = (selectedPet != null) ? activityProvider.getLastMealForPet(selectedPet.id) : null;
    final lastWater = (selectedPet != null) ? activityProvider.getLastWaterForPet(selectedPet.id) : null;
    final isHealthy = (selectedPet != null) ? activityProvider.isPetHealthyToday(selectedPet.id) : false;
    final healthStatus = isHealthy ? 'Healthy' : 'Needs attention';
    final lastMealText = (lastMeal != null) ? DateFormat('h:mm a').format(lastMeal) : 'Not logged';
    final lastWaterText = (lastWater != null) ? DateFormat('h:mm a').format(lastWater) : 'Not logged';

    final petActivities = (selectedPet != null)
        ? activityProvider.entries.where((e) => e.petId == selectedPet.id).toList()
        : [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Gradient header with greeting and notification button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning,',
                        style: GoogleFonts.quicksand(fontSize: 12, color: Colors.white.withAlpha(204))),
                    Text(userProvider.currentUser?.name ?? 'Pet Lover',
                        style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: Colors.white.withAlpha(38), shape: BoxShape.circle),
                    child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const SectionTitle('My Pets'),
                // Horizontal scrollable list of pets with add button
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pets.length + 1,
                    itemBuilder: (_, i) {
                      if (i == pets.length) {
                        return _AddPetButton(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPetScreen()));
                            setState(() {});
                          },
                        );
                      }
                      final pet = pets[i];
                      final selected = i == _selectedPetIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPetIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _petBgColor(i),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 2.5),
                                    ),
                                    child: Center(child: Text(pet.emoji, style: const TextStyle(fontSize: 24))),
                                  ),
                                  // Edit icon overlay allows editing pet from the dashboard
                                  Positioned(
                                    right: -4,
                                    bottom: -4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditPetScreen(pet: pet),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(pet.name,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryDark)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SectionTitle('Health Overview'),
                if (selectedPet != null) ...[
                  // Two rows of health metrics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _HealthCard(label: 'Status', value: healthStatus, icon: Icons.favorite, color: isHealthy ? AppTheme.primary : AppTheme.danger)),
                        const SizedBox(width: 12),
                        Expanded(child: _HealthCard(label: 'Weight', value: '${selectedPet.weightKg} kg', icon: Icons.monitor_weight, color: AppTheme.warning)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _HealthCard(label: 'Last meal', value: lastMealText, icon: Icons.restaurant, color: AppTheme.accent)),
                        const SizedBox(width: 12),
                        Expanded(child: _HealthCard(label: 'Water', value: lastWaterText, icon: Icons.water_drop, color: AppTheme.primaryDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _WeightAdviceCard(pet: selectedPet),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Select a pet to see health overview')),
                  ),
                const SizedBox(height: 16),
                const SectionTitle('Daily Activity Diary'),
                if (selectedPet != null) ...[
                  _ActivityLogger(petId: selectedPet.id),
                  const SizedBox(height: 8),
                  if (petActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('No activities yet. Use the button above.'),
                    )
                  else
                    Column(
                      children: petActivities.map((entry) => _ActivityEntryItem(entry: entry)).toList(),
                    ),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Select a pet to log activities')),
                  ),
                const SizedBox(height: 16),
                const SectionTitle("Today's Reminders"),
                if (selectedPet != null)
                  if (todayReminders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('No reminders for today', style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  else
                    ...todayReminders.map((r) => ReminderCard(reminder: r))
                else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Select a pet to see reminders')),
                  ),
                // Button to add a new reminder
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: GestureDetector(
                    onTap: () async {
                      if (selectedPet == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a pet first')));
                        return;
                      }
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReminderScreen()));
                      setState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.muted, width: 1.5),
                      ),
                      child: Center(
                        child: Text('＋  Add New Reminder',
                            style: GoogleFonts.quicksand(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CareScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else {
            setState(() => _selectedNavIndex = index);
          }
        },
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.cardBg,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety_outlined), label: 'Care'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  /// Returns a background color for the pet avatar based on index.
  Color _petBgColor(int index) {
    const colors = [Color(0xFFE1F5EE), Color(0xFFFBEAF0), Color(0xFFFAEEDA)];
    return colors[index % colors.length];
  }
}

/// Button widget to add a new pet from the dashboard.
class _AddPetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.muted, width: 2),
              ),
              child: const Center(child: Text('＋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 4),
            Text('Add', style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Small card displaying a health metric such as status or weight.
class _HealthCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _HealthCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.quicksand(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card that provides weight advice based on ideal weight range for the pet type.
class _WeightAdviceCard extends StatelessWidget {
  final Pet pet;
  const _WeightAdviceCard({required this.pet});

  /// Returns the ideal weight range minimum and maximum for the pet's emoji type.
  (double min, double max) _idealRange() {
    switch (pet.emoji) {
      case '🐶': return (10.0, 20.0);
      case '🐱': return (3.0, 5.0);
      case '🐰': return (1.5, 2.5);
      case '🐹': return (0.02, 0.15);
      case '🐦': return (0.025, 0.12);
      case '🐢': return (0.5, 2.0);
      default: return (1.0, 10.0);
    }
  }

  /// Generates advice text based on current weight and previous weight change.
  String getAdvice() {
    final weight = pet.weightKg;
    final (min, max) = _idealRange();
    String advice = '';
    if (weight < min) {
      advice = '⚠️ Underweight: Increase food portions gradually and consult vet if no improvement.';
    } else if (weight > max) {
      advice = '⚠️ Overweight: Reduce calories, increase exercise, avoid high-fat treats.';
    } else {
      advice = '✅ Weight is within ideal range. Keep up the good care!';
    }
    if (pet.previousWeightKg != null && pet.lastWeightUpdate != null) {
      final difference = weight - pet.previousWeightKg!;
      if (difference.abs() > 0.2) {
        if (difference > 0) {
          advice += '\n📈 Weight increased by ${difference.toStringAsFixed(1)} kg since ${DateFormat('MMM d').format(pet.lastWeightUpdate!)}. Monitor diet.';
        } else {
          advice += '\n📉 Weight decreased by ${(-difference).toStringAsFixed(1)} kg since ${DateFormat('MMM d').format(pet.lastWeightUpdate!)}. Ensure adequate nutrition.';
        }
      }
    }
    return advice;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Weight Advice', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(getAdvice(), style: GoogleFonts.quicksand(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Widget that allows logging a meal water or exercise activity for a pet.
class _ActivityLogger extends StatefulWidget {
  final String petId;
  const _ActivityLogger({required this.petId});

  @override
  State<_ActivityLogger> createState() => _ActivityLoggerState();
}

class _ActivityLoggerState extends State<_ActivityLogger> {
  String _selectedType = 'Meal';
  TimeOfDay _selectedTime = TimeOfDay.now();

  /// Saves the activity entry to the ActivityProvider.
  Future<void> _save() async {
    final entry = ActivityEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: widget.petId,
      dateTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      type: _selectedType,
    );
    await Provider.of<ActivityProvider>(context, listen: false).addEntry(entry);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Meal', child: Text('🍽️ Meal')),
                    DropdownMenuItem(value: 'Water', child: Text('💧 Water')),
                    DropdownMenuItem(value: 'Exercise', child: Text('🏃 Exercise')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(context: context, initialTime: _selectedTime);
                    if (time != null) setState(() => _selectedTime = time);
                  },
                  child: Text(DateFormat('h:mm a').format(DateTime(0, 0, 0, _selectedTime.hour, _selectedTime.minute))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
              child: const Text('Log Activity'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single activity entry displayed in the activity diary list.
class _ActivityEntryItem extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityEntryItem({required this.entry});

  String get _icon {
    switch (entry.type) {
      case 'Meal': return '🍽️';
      case 'Water': return '💧';
      case 'Exercise': return '🏃';
      default: return '📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(_icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.type, style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)),
                Text(DateFormat('h:mm a').format(entry.dateTime), style: GoogleFonts.quicksand(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: AppTheme.danger),
            onPressed: () => Provider.of<ActivityProvider>(context, listen: false).deleteEntry(entry.id),
          ),
        ],
      ),
    );
  }
}