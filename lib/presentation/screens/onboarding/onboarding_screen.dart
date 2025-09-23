import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import 'goal_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.track_changes,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.person_pin,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.notifications_active,
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipToGoalSelection,
                    child: const Text(AppStrings.skip),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: page.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: page.color.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 60,
                                  color: page.color,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: page.color,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _skipToGoalSelection
                      : _nextPage,
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? AppStrings.getStarted
                        : AppStrings.next,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToGoalSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GoalSelectionScreen(),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
