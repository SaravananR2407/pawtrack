import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/onboarding_screen.dart';

// Theme
import 'theme/app_theme.dart';

// Providers 
import 'providers/user_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/vaccine_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/weight_provider.dart';
import 'providers/vet_provider.dart';

/// Entry point of the application.
void main() async {
  // Ensures that Flutter framework is fully bound (required for async operations).
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with a MultiProvider to provide all application state
  runApp(
    MultiProvider(
      providers: [
        // Core user data provider
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Pet management provider (list of pets, selected pet and etc.)
        ChangeNotifierProvider(create: (_) => PetProvider()),

        // Reminders or notifications for health tasks
        ChangeNotifierProvider(create: (_) => ReminderProvider()),

        // Physical activity tracking
        ChangeNotifierProvider(create: (_) => ActivityProvider()),

        // Vaccination records and scheduling
        ChangeNotifierProvider(create: (_) => VaccineProvider()),

        // Medication logs and reminders
        ChangeNotifierProvider(create: (_) => MedicationProvider()),

        // Weight history tracking
        ChangeNotifierProvider(create: (_) => WeightProvider()),

        // Veterinary clinic / appointment management
        ChangeNotifierProvider(create: (_) => VetProvider()),
      ],
      child: const PawTrackApp(),
    ),
  );
}

/// Root widget of the application.
class PawTrackApp extends StatelessWidget {
  const PawTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawTrack',
      debugShowCheckedModeBanner: false, // Hides the debug banner in the corner

      // Custom light theme defined in AppTheme
      theme: AppTheme.lightTheme,

      // Start with the onboarding screen for first-time user experience
      home: const OnboardingScreen(),
    );
  }
}