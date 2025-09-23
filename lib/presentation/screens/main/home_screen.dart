import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/tip_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/motivational_tip_card.dart';
import '../../widgets/animated_loading.dart';
import '../../../core/constants/motivational_messages.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<RoutineProvider>().loadData();
          await context.read<TipProvider>().loadTips();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Consumer<RoutineProvider>(
                builder: (context, routineProvider, child) {
                  if (routineProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ProgressCard(
                    completedTasks: routineProvider.completedTasksToday,
                    totalTasks: routineProvider.totalTasksToday,
                    progress: routineProvider.progressPercentage,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Today's Tip
              Text(
                AppStrings.todaysTip,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Consumer<TipProvider>(
                builder: (context, tipProvider, child) {
                  if (tipProvider.isLoading || tipProvider.dailyTip == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: AnimatedLoading(
                            message: 'Günün tavsiyesi yükleniyor...',
                          ),
                        ),
                      ),
                    );
                  }

                  return MotivationalTipCard(
                    tip: tipProvider.dailyTip!,
                    onRefresh: () => tipProvider.refreshDailyTip(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Today's Tasks
              Text(
                AppStrings.dailyRoutine,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Consumer<RoutineProvider>(
                builder: (context, routineProvider, child) {
                  if (routineProvider.isLoading) {
                    return const Center(
                      child: AnimatedLoading(
                        message: 'Rutinlerin yükleniyor...',
                      ),
                    );
                  }

                  if (routineProvider.todayTasks.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.noTasksToday,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: routineProvider.todayTasks
                        .map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskCard(
                                task: task,
                                onCompleted: (isCompleted) {
                                  routineProvider.markTaskCompleted(
                                    task.id!,
                                    isCompleted,
                                  );
                                },
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın!';
    } else if (hour < 17) {
      return 'İyi öğleden sonralar!';
    } else {
      return 'İyi akşamlar!';
    }
  }
}
