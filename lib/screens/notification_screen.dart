import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/reminder_provider.dart';
import '../widgets/common_widgets.dart';

/// Screen that displays all upcoming reminders as a list of notification cards.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = Provider.of<ReminderProvider>(context).reminders;
    // Filter only reminders that have a date time in the future
    final upcoming = reminders.where((r) => r.dateTime.isAfter(DateTime.now())).toList();
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
                Text('Notifications', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: upcoming.isEmpty
                ? const Center(child: Text('No upcoming reminders'))
                : ListView.builder(
                    itemCount: upcoming.length,
                    itemBuilder: (_, i) => ReminderCard(reminder: upcoming[i]),
                  ),
          ),
        ],
      ),
    );
  }
}