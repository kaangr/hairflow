import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/predefined_routines.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/animated_loading.dart';
import '../main/main_navigation_screen.dart';

class RoutineRecommendationsScreen extends StatefulWidget {
  final HairType hairType;
  final HairLossStage hairLossStage;
  final UserGoal userGoal;

  const RoutineRecommendationsScreen({
    super.key,
    required this.hairType,
    required this.hairLossStage,
    required this.userGoal,
  });

  @override
  State<RoutineRecommendationsScreen> createState() => 
      _RoutineRecommendationsScreenState();
}

class _RoutineRecommendationsScreenState 
    extends State<RoutineRecommendationsScreen> 
    with TickerProviderStateMixin {
  
  late List<Routine> _recommendedRoutines;
  late List<Map<String, dynamic>> _recommendedData;
  late List<String> _safeStartOrder;
  bool _showingStartOrder = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _recommendedData = PredefinedRoutines.getRecommendedRoutines(
      hairType: widget.hairType,
      stage: widget.hairLossStage,
      goal: widget.userGoal,
    );
    
    _recommendedRoutines = _recommendedData.map((data) => data['routine'] as Routine).toList();

    _safeStartOrder = PredefinedRoutines.getSafeStartOrder();
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Önerilen Rutinler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showingStartOrder ? Icons.list : Icons.info),
            onPressed: () {
              setState(() {
                _showingStartOrder = !_showingStartOrder;
              });
            },
            tooltip: _showingStartOrder ? 'Rutinleri Göster' : 'Güvenli Başlangıç',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _showingStartOrder ? _buildStartOrderView() : _buildRoutinesView(),
          );
        },
      ),
    );
  }

  Widget _buildRoutinesView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getHairTypeText()} • ${_getStageText()} • ${_getGoalText()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Size Özel Rutinler 🎯',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Saç tipiniz ve hedeflerinize göre özelleştirilmiş rutinler',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Routines list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _recommendedRoutines.length,
            itemBuilder: (context, index) {
              final routine = _recommendedRoutines[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 50),
                    child: Opacity(
                      opacity: value,
                      child: _buildRoutineCard(routine, index),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Bottom actions
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addAllRoutines,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Tüm Rutinleri Ekle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Şimdi Değil, Ana Sayfaya Git'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartOrderView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güvenli Başlangıç Sırası',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ürünleri doğru sırayla başlayın',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: ListView.builder(
                itemCount: _safeStartOrder.length,
                itemBuilder: (context, index) {
                  final item = _safeStartOrder[index];
                  
                  if (item.isEmpty) {
                    return const SizedBox(height: 16);
                  }
                  
                  final isHeader = item.contains('⚠️');
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                        color: isHeader 
                            ? Colors.orange 
                            : Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRoutineColor(index),
            _getRoutineColor(index).withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getRoutineColor(index).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
                onTap: () => _addSingleRoutine(routine, index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routine.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final routineData = _recommendedData[index];
                    final tasks = routineData['tasks'] as List<String>;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tasks.length} görev',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tasks.take(3).map((task) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.length > 20 
                                    ? '${task.substring(0, 20)}...'
                                    : task,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (tasks.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+${tasks.length - 3} görev daha',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoutineColor(int index) {
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF9800), // Orange
    ];
    return colors[index % colors.length];
  }

  String _getHairTypeText() {
    switch (widget.hairType) {
      case HairType.dry:
        return 'Kuru Saç';
      case HairType.oily:
        return 'Yağlı Saç';
      case HairType.normal:
        return 'Normal Saç';
      case HairType.sensitive:
        return 'Hassas Saç';
    }
  }

  String _getStageText() {
    switch (widget.hairLossStage) {
      case HairLossStage.prevention:
        return 'Önleyici';
      case HairLossStage.early:
        return 'Erken Dönem';
      case HairLossStage.moderate:
        return 'Orta Seviye';
      case HairLossStage.advanced:
        return 'İleri Seviye';
    }
  }

  String _getGoalText() {
    switch (widget.userGoal) {
      case UserGoal.preventLoss:
        return 'Dökülmeyi Önleme';
      case UserGoal.regrowth:
        return 'Yeni Saç Çıkarma';
      case UserGoal.strengthening:
        return 'Güçlendirme';
      case UserGoal.maintenance:
        return 'Koruma';
    }
  }

  void _addSingleRoutine(Routine routine, int index) async {
    final routineProvider = context.read<RoutineProvider>();
    await routineProvider.addRoutine(routine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const AnimatedSuccessIcon(size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${routine.name} rutininiz eklendi! 🎉'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addAllRoutines() async {
    final routineProvider = context.read<RoutineProvider>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedLoading(
          message: 'Rutinleriniz ekleniyor...',
        ),
      ),
    );

    // Add all routines
    for (final routine in _recommendedRoutines) {
      await routineProvider.addRoutine(routine);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Close loading
    if (mounted) {
      Navigator.of(context).pop();
      
      // Show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Tüm rutinleriniz başarıyla eklendi!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }
}
