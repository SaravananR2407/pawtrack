import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import 'create_reminder_screen.dart';

/// Screen showing a calendar-like schedule of reminders.
/// Displays reminders for a selected date plus upcoming reminders list.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  /// Generates a list of days surrounding the current date for the horizontal date picker.
  List<DateTime> get _weekDays {
    final now = DateTime.now();
    return List.generate(8, (i) => now.subtract(const Duration(days: 3)).add(Duration(days: i)));
  }

  /// Navigates to the create/edit reminder screen, optionally with an existing reminder.
  Future<void> _navigateToCreateReminder(Reminder? reminder) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateReminderScreen(existingReminder: reminder)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          final allReminders = reminderProvider.reminders;
          // Reminders for the selected date
          final selectedDateReminders = allReminders.where((r) {
            return r.dateTime.year == _selectedDate.year &&
                r.dateTime.month == _selectedDate.month &&
                r.dateTime.day == _selectedDate.day;
          }).toList();
          // Reminders more than one day in the future
          final upcomingReminders = allReminders.where((r) {
            return r.dateTime.isAfter(DateTime.now().add(const Duration(days: 1)));
          }).toList();

          return Column(
            children: [
              // Custom app bar with add button
              Container(
                padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
                color: AppTheme.primary,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                    ),
                    Text('Schedule',
                        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateReminderScreen()),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              // Horizontal date picker strip
              Container(
                color: AppTheme.cardBg,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _weekDays.length,
                    itemBuilder: (_, i) {
                      final day = _weekDays[i];
                      final isSelected = day.day == _selectedDate.day &&
                          day.month == _selectedDate.month;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(day)[0],
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white.withAlpha(204) : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${day.day}',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppTheme.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // List of reminders
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    // Header for the selected date
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(_selectedDate),
                            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.darkGreen),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${selectedDateReminders.length} events',
                              style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedDateReminders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Text('🐾', style: TextStyle(fontSize: 36)),
                              SizedBox(height: 8),
                              Text('No events on this day',
                                  style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...selectedDateReminders.map((r) => _EventItem(
                            reminder: r,
                            onTap: () => _navigateToCreateReminder(r),
                          )),
                    // Upcoming reminders section
                    if (upcomingReminders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text('Upcoming',
                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.darkGreen)),
                      ),
                      ...upcomingReminders.map((r) => _EventItem(
                            reminder: r,
                            onTap: () => _navigateToCreateReminder(r),
                          )),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Single event item displayed in the schedule list.
class _EventItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;

  const _EventItem({required this.reminder, required this.onTap});

  /// Returns a color dot based on the reminder type.
  Color get _dotColor {
    switch (reminder.type) {
      case ReminderType.medication: return AppTheme.warning;
      case ReminderType.vetVisit: return AppTheme.danger;
      case ReminderType.grooming: return const Color(0xFFD4537E);
      case ReminderType.feeding: return AppTheme.primary;
      case ReminderType.other: return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = reminder.dateTime.isAfter(DateTime.now().add(const Duration(days: 1)));
    final timeLabel = isUpcoming
        ? DateFormat('MMM d').format(reminder.dateTime)
        : DateFormat('h:mm a').format(reminder.dateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Text(timeLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${reminder.typeEmoji} ${reminder.title}',
                      style: GoogleFonts.quicksand(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.darkGreen)),
                  Text(
                    '${reminder.petEmoji} ${reminder.petName}${reminder.notes != null ? ' · ${reminder.notes}' : ''}',
                    style: GoogleFonts.quicksand(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}