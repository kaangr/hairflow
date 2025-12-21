import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../../domain/entities/routine.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/predefined_routines.dart';
import '../../widgets/task_card.dart';
import '../../widgets/routine_calendar.dart';
import '../../widgets/duolingo_style/xp_progress_bar.dart';
import '../routine/hair_assessment_screen.dart';
import '../routine/manual_routine_screen.dart';
import '../routine/routine_recommendations_screen.dart';
import '../routine/routine_detail_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myRoutines),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Show calendar view
            },
          ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, routineProvider, child) {
          if (routineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (routineProvider.routines.isEmpty) {
            return _buildEmptyState(context);
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // Sekme çubuğu
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Görevler'),
                      Tab(text: 'Rutinler'),
                      Tab(text: 'Takvim'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Bugünün görevleri
                      _buildTodayTasksView(context, routineProvider),
                      // Rutin listesi (CRUD)
                      _buildRoutinesListView(context, routineProvider),
                      // Takvim görünümü
                      _buildCalendarView(context, routineProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoutineOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Rutin Oluştur'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu ikon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.spa,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Saç Bakım Yolculuğuna Başla! 🌱',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Kişiselleştirilmiş rutin oluşturarak saç sağlığını takip et',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Ana buton - Akıllı Öneri
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToSmartRoutine(context),
              icon: const Icon(Icons.psychology, size: 24),
              label: const Text('Akıllı Rutin Önerisi Al'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // İkincil buton - Manuel
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToCustomRoutine(context),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Manuel Rutin Oluştur'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesListView(BuildContext context, RoutineProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.routines.length,
      itemBuilder: (context, index) {
        final routine = provider.routines[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _RoutineCard(
                  routine: routine,
                  taskCount: provider.allTasks
                      .where((t) => t.routineId == routine.id)
                      .length,
                  onTap: () => _navigateToRoutineDetail(context, routine),
                  onEdit: () => _navigateToRoutineDetail(context, routine),
                  onDelete: () => _showDeleteRoutineDialog(context, provider, routine),
                  onToggleActive: () => _toggleRoutineActive(context, provider, routine),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToRoutineDetail(BuildContext context, Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailScreen(routine: routine),
      ),
    );
  }

  void _showDeleteRoutineDialog(
    BuildContext context,
    RoutineProvider provider,
    Routine routine,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Rutini Sil'),
          ],
        ),
        content: Text(
          '"${routine.name}" rutinini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteRoutine(routine.id.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rutin silindi'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _toggleRoutineActive(
    BuildContext context,
    RoutineProvider provider,
    Routine routine,
  ) {
    final updated = routine.copyWith(
      isActive: !routine.isActive,
      updatedAt: DateTime.now(),
    );
    provider.updateRoutine(updated);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isActive
              ? '${routine.name} aktif edildi'
              : '${routine.name} pasif edildi',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateRoutineOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Text(
                    'Rutin Oluştur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Akıllı öneri
              _CreateOptionCard(
                icon: Icons.psychology,
                title: '🎯 Akıllı Öneri (Önerilen)',
                subtitle: 'Saç tipinize özel rutin önerisi',
                isPrimary: true,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSmartRoutine(context);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Manuel oluşturma
              _CreateOptionCard(
                icon: Icons.edit,
                title: 'Manuel Oluştur',
                subtitle: 'Kendi rutininizi sıfırdan oluşturun',
                isPrimary: false,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCustomRoutine(context);
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSmartRoutine(BuildContext context) {
    final userPrefs = context.read<UserPreferencesProvider>();
    
    if (userPrefs.hasCompletedAssessment && 
        userPrefs.preferences.hairType != null &&
        userPrefs.preferences.hairLossStage != null &&
        userPrefs.preferences.userGoal != null) {
      // Assessment zaten yapılmış, doğrudan önerilere git
      final hairType = _parseHairType(userPrefs.preferences.hairType!);
      final hairLossStage = _parseHairLossStage(userPrefs.preferences.hairLossStage!);
      final userGoal = _parseUserGoal(userPrefs.preferences.userGoal!);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoutineRecommendationsScreen(
            hairType: hairType,
            hairLossStage: hairLossStage,
            userGoal: userGoal,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HairAssessmentScreen(),
        ),
      );
    }
  }

  void _navigateToCustomRoutine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManualRoutineScreen(),
      ),
    );
  }

  HairType _parseHairType(String value) {
    switch (value) {
      case 'dry':
        return HairType.dry;
      case 'oily':
        return HairType.oily;
      case 'sensitive':
        return HairType.sensitive;
      default:
        return HairType.normal;
    }
  }

  HairLossStage _parseHairLossStage(String value) {
    switch (value) {
      case 'early':
        return HairLossStage.early;
      case 'moderate':
        return HairLossStage.moderate;
      case 'advanced':
        return HairLossStage.advanced;
      default:
        return HairLossStage.prevention;
    }
  }

  UserGoal _parseUserGoal(String value) {
    switch (value) {
      case 'regrowth':
        return UserGoal.regrowth;
      case 'strengthening':
        return UserGoal.strengthening;
      case 'maintenance':
        return UserGoal.maintenance;
      default:
        return UserGoal.preventLoss;
    }
  }

  Widget _buildTodayTasksView(BuildContext context, RoutineProvider provider) {
    if (provider.todayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noTasksToday,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bugün için planlanmış görev yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final completedTasks = provider.todayTasks.where((task) => task.isCompleted).toList();
    final pendingTasks = provider.todayTasks.where((task) => !task.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İlerleme özeti - Duolingo tarzı
          CircularProgressWidget(
            progress: provider.progressPercentage,
            completedTasks: provider.completedTasksToday,
            totalTasks: provider.totalTasksToday,
          ),

          const SizedBox(height: 24),

          // Bekleyen görevler
          if (pendingTasks.isNotEmpty) ...[
            _buildTaskSectionHeader(context, 'Bekleyen Görevler', pendingTasks.length, false),
            const SizedBox(height: 12),
            ...pendingTasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                onCompleted: (isCompleted) {
                  provider.markTaskCompleted(task.id!, isCompleted);
                },
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Tamamlanan görevler
          if (completedTasks.isNotEmpty) ...[
            _buildTaskSectionHeader(context, 'Tamamlanan Görevler', completedTasks.length, true),
            const SizedBox(height: 12),
            ...completedTasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                onCompleted: (isCompleted) {
                  provider.markTaskCompleted(task.id!, isCompleted);
                },
              ),
            )),
          ],

          if (completedTasks.length == provider.totalTasksToday && provider.totalTasksToday > 0) ...[
            const SizedBox(height: 24),
            _buildAllCompleteCard(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskSectionHeader(BuildContext context, String title, int count, bool isCompleted) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllCompleteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF46A302)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harika İş! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.allTasksCompleted,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, RoutineProvider provider) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: RoutineCalendar(),
    );
  }
}

/// Rutin kartı widget'ı
class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final int taskCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _RoutineCard({
    required this.routine,
    required this.taskCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: routine.isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: routine.isActive
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: routine.isActive ? null : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              routine.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: routine.isActive
                                    ? null
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                          if (!routine.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pasif',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routine.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$taskCount görev',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menü
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onToggleActive();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            routine.isActive ? Icons.pause : Icons.play_arrow,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(routine.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Oluşturma seçenek kartı
class _CreateOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CreateOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              )
            : null,
        border: isPrimary
            ? null
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isPrimary ? Colors.white : null,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isPrimary
                              ? Colors.white70
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isPrimary
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
