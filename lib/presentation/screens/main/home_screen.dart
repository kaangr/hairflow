import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/tip_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/task_card.dart';
import '../../widgets/motivational_tip_card.dart';
import '../../widgets/animated_loading.dart';
import '../../widgets/time_planner_calendar.dart';
import '../../widgets/duolingo_style/streak_widget.dart';
import '../../widgets/duolingo_style/xp_progress_bar.dart';
import '../../widgets/duolingo_style/celebration_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late Animation<double> _greetingAnimation;
  
  // Streak hesaplama için dummy değerler (gerçek implementasyonda Firestore'dan gelecek)
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalXP = 0;
  List<bool> _weeklyProgress = [];

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _greetingAnimation = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutCubic,
    );
    
    _greetingController.forward();
    _calculateStreakData();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  void _calculateStreakData() {
    // TODO: Gerçek streak hesaplaması Firestore'dan yapılacak
    // Şimdilik dummy değerler kullanıyoruz
    final provider = context.read<RoutineProvider>();
    final completedToday = provider.completedTasksToday > 0;
    
    _currentStreak = completedToday ? 1 : 0; // Placeholder
    _longestStreak = 5; // Placeholder
    _totalXP = 150; // Placeholder
    
    // Haftalık ilerleme (bugün için)
    final today = DateTime.now().weekday - 1;
    _weeklyProgress = List.generate(7, (i) => i < today || (i == today && completedToday));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<RoutineProvider>().loadData();
          await context.read<TipProvider>().loadTips();
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _calculateStreakData();
          });
        },
        child: CustomScrollView(
          slivers: [
            // Animasyonlu App Bar
            _buildAnimatedAppBar(),
            
            // İçerik
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Streak Widget - Duolingo tarzı
                  Consumer<RoutineProvider>(
                    builder: (context, provider, _) {
                      final isActiveToday = provider.completedTasksToday > 0;
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: StreakWidget(
                                currentStreak: _currentStreak,
                                longestStreak: _longestStreak,
                                isActiveToday: isActiveToday,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Haftalık ilerleme
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: WeeklyStreakIndicator(
                            weeklyProgress: _weeklyProgress,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // XP Progress Bar
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: XPProgressBar(
                            currentXP: _totalXP,
                            levelXP: 200,
                            level: 2,
                            label: 'Saç Bakım Uzmanı',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bugünün İlerlemesi - Yeniden tasarlanmış
                  _buildTodayProgressSection(),
                  
                  const SizedBox(height: 24),

                  // Günün Tavsiyesi
                  _buildSectionHeader('Günün Tavsiyesi', Icons.lightbulb),
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

                  // Saatlik Program
                  _buildSectionHeader('Saatlik Program', Icons.schedule),
                  const SizedBox(height: 12),
                  const Card(
                    child: TimePlannerCalendar(),
                  ),

                  const SizedBox(height: 24),

                  // Bugünün Görevleri
                  _buildSectionHeader('Günlük Rutin', Icons.task_alt),
                  const SizedBox(height: 12),
                  _buildTodayTasksList(),
                  
                  const SizedBox(height: 80), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: AnimatedBuilder(
          animation: _greetingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-20 * (1 - _greetingAnimation.value), 0),
              child: Opacity(
                opacity: _greetingAnimation.value,
                child: Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Dekoratif daireler
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 50,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // XP göstergesi
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_totalXP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Show notifications
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayProgressSection() {
    return Consumer<RoutineProvider>(
      builder: (context, provider, _) {
        final completed = provider.completedTasksToday;
        final total = provider.totalTasksToday;
        final progress = provider.progressPercentage;
        final allComplete = completed == total && total > 0;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: allComplete
                ? const LinearGradient(
                    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                  )
                : null,
            color: allComplete
                ? null
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: allComplete
                ? null
                : Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
          ),
          child: Row(
            children: [
              // Circular progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: allComplete
                            ? Colors.white.withOpacity(0.3)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          allComplete
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    if (allComplete)
                      const Icon(Icons.check, color: Colors.white, size: 32)
                    else
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allComplete
                          ? 'Tebrikler! 🎉'
                          : 'Bugünün İlerlemesi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: allComplete ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      allComplete
                          ? 'Tüm görevleri tamamladın!'
                          : '$completed / $total görev tamamlandı',
                      style: TextStyle(
                        fontSize: 14,
                        color: allComplete
                            ? Colors.white.withOpacity(0.9)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (!allComplete && total > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${total - completed} görev kaldı',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: allComplete
                    ? Colors.white.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayTasksList() {
    return Consumer<RoutineProvider>(
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
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noTasksToday,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir rutin oluşturarak başla!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: routineProvider.todayTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(
                        task: task,
                        onCompleted: (isCompleted) {
                          routineProvider.markTaskCompleted(task.id!, isCompleted);
                          
                          // Görev tamamlandığında kutlama
                          if (isCompleted) {
                            _showTaskCompletionCelebration(context, routineProvider);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showTaskCompletionCelebration(BuildContext context, RoutineProvider provider) {
    final allComplete = provider.completedTasksToday + 1 == provider.totalTasksToday;
    
    if (allComplete) {
      // Tüm görevler tamamlandı - büyük kutlama
      Future.delayed(const Duration(milliseconds: 300), () {
        showCelebration(
          context,
          title: 'Muhteşem! 🏆',
          subtitle: 'Bugünün tüm görevlerini tamamladın!',
          emoji: '🎉',
          xpEarned: 50,
          type: CelebrationType.routineComplete,
        );
      });
    }
    
    setState(() {
      _totalXP += 10;
      _calculateStreakData();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın! ☀️';
    } else if (hour < 17) {
      return 'İyi öğleden sonralar! 🌤️';
    } else {
      return 'İyi akşamlar! 🌙';
    }
  }
}
