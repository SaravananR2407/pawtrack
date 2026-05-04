import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/reminder.dart';

/// Converts a DateTime object into a TimeOfDay object.
/// This helper is used by ReminderCard to display only the hour and minute.
TimeOfDay _timeOfDayFromDateTime(DateTime dateTime) {
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

/// A small coloured badge for status labels like "Healthy" "Due" or "Overdue".
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  /// Creates a green badge for positive statuses like "Done" or "Healthy".
  factory StatusBadge.green(String label) => StatusBadge(
        label: label,
        bgColor: AppTheme.primaryLight,
        textColor: AppTheme.primaryDark,
      );

  /// Creates a yellow warning badge for statuses like "Due".
  factory StatusBadge.warning(String label) => StatusBadge(
        label: label,
        bgColor: const Color(0xFFFAEEDA),
        textColor: const Color(0xFF854F0B),
      );

  /// Creates a red danger badge for statuses like "Overdue".
  factory StatusBadge.danger(String label) => StatusBadge(
        label: label,
        bgColor: const Color(0xFFFCEBEB),
        textColor: const Color(0xFFA32D2D),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

/// A card that displays a single statistic on the dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor = AppTheme.darkGreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a single reminder item inside a list.
/// Shows the reminder title, pet name, time, an emoji icon and a status badge.
class ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  /// Returns the appropriate status badge based on the reminder's status.
  StatusBadge get _badge {
    switch (reminder.status) {
      case ReminderStatus.due:
        return StatusBadge.warning('Due');
      case ReminderStatus.overdue:
        return StatusBadge.danger('Overdue');
      case ReminderStatus.done:
        return StatusBadge.green('Done');
      case ReminderStatus.upcoming:
        return StatusBadge.green('Today');
    }
  }

  /// Returns the background colour for the emoji icon based on reminder type.
  Color get _iconBg {
    switch (reminder.type) {
      case ReminderType.medication:
        return AppTheme.primaryLight;
      case ReminderType.vetVisit:
        return const Color(0xFFFCEBEB);
      case ReminderType.grooming:
        return const Color(0xFFFBEAF0);
      case ReminderType.feeding:
        return const Color(0xFFFAEEDA);
      case ReminderType.other:
        return const Color(0xFFF1EFE8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                reminder.typeEmoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                  ),
                ),
                Text(
                  '${reminder.petEmoji} ${reminder.petName} · '
                  '${_timeOfDayFromDateTime(reminder.dateTime).format(context)}',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _badge,
        ],
      ),
    );
  }
}

/// A section title used to label parts of the screen like "My Pets" or "Today's Reminders".
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A progress bar that shows a health metric like vaccination completeness.
/// The value should be between 0.0 and 1.0.
class HealthProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const HealthProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppTheme.primaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}