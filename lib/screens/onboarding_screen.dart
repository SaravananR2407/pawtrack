import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

/// Onboarding screen shown on first launch.
/// Introduces the app features with three slides and a skip button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// List of pages content with emoji title description background color and illustration emojis.
  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      emoji: '🐾',
      title: 'Meet PawTrack',
      description:
          'Your all-in-one companion for keeping your pets happy, healthy, and on schedule.',
      bgColor: Color(0xFFE1F5EE),
      illustrationEmojis: ['🐶', '🐱', '🐰'],
    ),
    _OnboardPage(
      emoji: '💊',
      title: 'Track Health & Meds',
      description:
          'Log vaccinations, medications, and vet visits. Get smart reminders before anything is due.',
      bgColor: Color(0xFFFAEEDA),
      illustrationEmojis: ['📅', '💊', '🔔'],
    ),
    _OnboardPage(
      emoji: '📊',
      title: 'Smart Dashboard',
      description:
          'See all your pets at a glance. Weight trends, vet visits, and daily care in one place.',
      bgColor: Color(0xFFFBEAF0),
      illustrationEmojis: ['📊', '⭐', '📈'],
    ),
  ];

  /// Moves to the next page or goes to login if on the last page.
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  /// Navigates to the login screen and replaces the onboarding stack.
  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button aligned to the right
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text('Skip',
                    style: GoogleFonts.quicksand(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // Page view with onboarding slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardPageWidget(page: _pages[i]),
              ),
            ),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Next or Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Next →',
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Data model for a single onboarding page.
class _OnboardPage {
  final String emoji;
  final String title;
  final String description;
  final Color bgColor;
  final List<String> illustrationEmojis;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.illustrationEmojis,
  });
}

/// Widget that displays a single onboarding page.
class _OnboardPageWidget extends StatelessWidget {
  final _OnboardPage page;

  const _OnboardPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular background with main emoji and smaller illustrative emojis
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: page.bgColor,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(page.emoji, style: const TextStyle(fontSize: 56)),
                Positioned(
                  bottom: 24,
                  left: 20,
                  child: Text(page.illustrationEmojis[0],
                      style: const TextStyle(fontSize: 24)),
                ),
                Positioned(
                  bottom: 20,
                  right: 18,
                  child: Text(page.illustrationEmojis[1],
                      style: const TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: AppTheme.primaryDark,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}