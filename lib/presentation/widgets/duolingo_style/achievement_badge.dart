import 'package:flutter/material.dart';

/// Başarı rozeti modeli
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final int requiredValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.requiredValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => (currentValue / requiredValue).clamp(0.0, 1.0);
}

enum AchievementType {
  streak,       // Gün serisi
  tasksCompleted, // Tamamlanan görev sayısı
  routinesCreated, // Oluşturulan rutin sayısı
  perfectDays,  // Mükemmel günler (tüm görevler tamamlandı)
  consistency,  // Tutarlılık
  earlyBird,    // Sabah rutinleri
  nightOwl,     // Akşam rutinleri
}

/// Duolingo tarzı rozet widget'ı
class AchievementBadge extends StatefulWidget {
  final Achievement achievement;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.onTap,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.achievement.isUnlocked) {
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
    final achievement = widget.achievement;
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isUnlocked
                  ? _getTypeColor(achievement.type).withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border.all(
                color: isUnlocked
                    ? _getTypeColor(achievement.type).withOpacity(0.5)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: _getTypeColor(achievement.type)
                            .withOpacity(_glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji/İkon
                Transform.scale(
                  scale: isUnlocked ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isUnlocked
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getTypeColor(achievement.type),
                                _getTypeColor(achievement.type).withOpacity(0.7),
                              ],
                            )
                          : null,
                      color: isUnlocked
                          ? null
                          : Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Center(
                      child: isUnlocked
                          ? Text(
                              achievement.emoji,
                              style: const TextStyle(fontSize: 32),
                            )
                          : Icon(
                              Icons.lock,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                              size: 28,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Başlık
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Açıklama
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // İlerleme çubuğu
                if (widget.showProgress && !isUnlocked) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(context, achievement),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Achievement achievement) {
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: achievement.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTypeColor(achievement.type),
                    _getTypeColor(achievement.type).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.currentValue}/${achievement.requiredValue}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getTypeColor(achievement.type),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Color _getTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Colors.orange;
      case AchievementType.tasksCompleted:
        return Colors.green;
      case AchievementType.routinesCreated:
        return Colors.blue;
      case AchievementType.perfectDays:
        return Colors.purple;
      case AchievementType.consistency:
        return Colors.teal;
      case AchievementType.earlyBird:
        return Colors.amber;
      case AchievementType.nightOwl:
        return Colors.indigo;
    }
  }
}

/// Rozetler listesi widget'ı
class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final void Function(Achievement)? onAchievementTap;

  const AchievementsGrid({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    // Açık rozetler önce, kilitli olanlar sonra
    final sorted = [...achievements]
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return b.progress.compareTo(a.progress);
      });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final achievement = sorted[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: AchievementBadge(
                  achievement: achievement,
                  onTap: onAchievementTap != null
                      ? () => onAchievementTap!(achievement)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Varsayılan başarılar listesi
class DefaultAchievements {
  static List<Achievement> getAll({
    int currentStreak = 0,
    int tasksCompleted = 0,
    int routinesCreated = 0,
    int perfectDays = 0,
  }) {
    return [
      // Streak rozetleri
      Achievement(
        id: 'streak_3',
        title: 'Başlangıç',
        description: '3 günlük seri yap',
        emoji: '🔥',
        type: AchievementType.streak,
        requiredValue: 3,
        currentValue: currentStreak,
        isUnlocked: currentStreak >= 3,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Bir Hafta',
        description: '7 günlük seri yap',
        emoji: '💪',
        type: AchievementType.streak,
        requiredValue: 7,
        currentValue: currentStreak,
        isUnlocked: currentStreak >= 7,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Ay Savaşçısı',
        description: '30 günlük seri yap',
        emoji: '🏆',
        type: AchievementType.streak,
        requiredValue: 30,
        currentValue: currentStreak,
        isUnlocked: currentStreak >= 30,
      ),

      // Görev rozetleri
      Achievement(
        id: 'tasks_10',
        title: 'Görev Avcısı',
        description: '10 görev tamamla',
        emoji: '✅',
        type: AchievementType.tasksCompleted,
        requiredValue: 10,
        currentValue: tasksCompleted,
        isUnlocked: tasksCompleted >= 10,
      ),
      Achievement(
        id: 'tasks_50',
        title: 'Süper Üretken',
        description: '50 görev tamamla',
        emoji: '🚀',
        type: AchievementType.tasksCompleted,
        requiredValue: 50,
        currentValue: tasksCompleted,
        isUnlocked: tasksCompleted >= 50,
      ),

      // Rutin rozetleri
      Achievement(
        id: 'routines_1',
        title: 'İlk Adım',
        description: 'İlk rutinini oluştur',
        emoji: '🌱',
        type: AchievementType.routinesCreated,
        requiredValue: 1,
        currentValue: routinesCreated,
        isUnlocked: routinesCreated >= 1,
      ),
      Achievement(
        id: 'routines_3',
        title: 'Rutin Ustası',
        description: '3 rutin oluştur',
        emoji: '🎯',
        type: AchievementType.routinesCreated,
        requiredValue: 3,
        currentValue: routinesCreated,
        isUnlocked: routinesCreated >= 3,
      ),

      // Mükemmel gün rozetleri
      Achievement(
        id: 'perfect_5',
        title: 'Mükemmeliyetçi',
        description: '5 mükemmel gün',
        emoji: '⭐',
        type: AchievementType.perfectDays,
        requiredValue: 5,
        currentValue: perfectDays,
        isUnlocked: perfectDays >= 5,
      ),
    ];
  }
}

