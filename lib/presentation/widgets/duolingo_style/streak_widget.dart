import 'package:flutter/material.dart';

/// Duolingo tarzı streak (günlük seri) widget'ı
class StreakWidget extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isActiveToday;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.isActiveToday = false,
  });

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _flameAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.isActiveToday) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isActiveToday
              ? [Colors.orange.shade400, Colors.deepOrange.shade600]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (widget.isActiveToday ? Colors.orange : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Alev ikonu
          AnimatedBuilder(
            animation: _flameAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isActiveToday ? _flameAnimation.value : 1.0,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    size: 40,
                    color: widget.isActiveToday ? Colors.yellow : Colors.white70,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 20),
          
          // Streak bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.currentStreak} Gün Seri!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isActiveToday
                      ? 'Bugün de devam! 🔥'
                      : 'Bugünkü görevi tamamla',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // En uzun seri
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Colors.yellow.shade300,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'En uzun: ${widget.longestStreak} gün',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sağ ok
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.7),
            size: 30,
          ),
        ],
      ),
    );
  }
}

/// Haftalık streak göstergesi (Duolingo'daki gibi)
class WeeklyStreakIndicator extends StatelessWidget {
  final List<bool> weeklyProgress; // Son 7 günün durumu

  const WeeklyStreakIndicator({
    super.key,
    required this.weeklyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final today = DateTime.now().weekday - 1; // 0-6
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isCompleted = index < weeklyProgress.length && weeklyProgress[index];
          final isToday = index == today;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                days[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.orange
                      : isToday
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  border: isToday
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      )
                    : isToday
                        ? Icon(
                            Icons.circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 8,
                          )
                        : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}

