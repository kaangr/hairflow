import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../main/main_navigation_screen.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Title
              Text(
                AppStrings.selectGoalTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppStrings.selectGoalSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 48),

              // Goal Options
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.hairGoals.length,
                  itemBuilder: (context, index) {
                    final goal = AppConstants.hairGoals[index];
                    final isSelected = _selectedGoal == goal;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: isSelected ? 4 : 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedGoal = goal;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getGoalIcon(index),
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedGoal != null ? _completeOnboarding : null,
                  child: const Text(AppStrings.continueText),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(int index) {
    switch (index) {
      case 0:
        return Icons.block; // Saç dökülmesini durdurmak
      case 1:
        return Icons.trending_up; // Yeni saç çıkarmak
      case 2:
        return Icons.auto_awesome; // Saç kalitesini artırmak
      case 3:
        return Icons.health_and_safety; // Genel saç sağlığını korumak
      default:
        return Icons.flag;
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedGoal == null) return;

    final userPrefsProvider = context.read<UserPreferencesProvider>();
    
    try {
      // Update user goal
      await userPrefsProvider.updateGoal(_selectedGoal!);
      
      // Mark onboarding as completed
      await userPrefsProvider.completeOnboarding();

      if (mounted) {
        // Navigate to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
