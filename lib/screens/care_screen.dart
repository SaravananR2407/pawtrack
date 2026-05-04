import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import 'vaccination_screen.dart';
import 'medication_screen.dart';
import 'vet_visits_screen.dart';

/// Screen that aggregates all pet care features.
/// Contains three tabs including Vaccinations, Medications and Vet Visits.
class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with three tabs
    _tabController = TabController(length: 3, vsync: this);
    // After first frame set the user id for the pet provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        petProvider.setUserId(userProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Custom app bar with back button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: AppTheme.primary,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                Text('Pet Care', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          // Tab bar for switching between care categories
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Vaccines'),
              Tab(text: 'Medications'),
              Tab(text: 'Vet Visits'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                VaccinationScreen(),
                MedicationScreen(),
                VetVisitsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}