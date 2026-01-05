import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/duolingo_style/streak_widget.dart';
import '../../widgets/duolingo_style/xp_progress_bar.dart';
import '../../widgets/duolingo_style/achievement_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder değerler - gerçek veriler Firebase'den gelecek
  int _currentStreak = 5;
  int _longestStreak = 12;
  int _totalXP = 450;
  int _tasksCompleted = 47;
  int _routinesCreated = 3;
  int _perfectDays = 8;
  int _level = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profil App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(context),
            ),
          ),

          // İçerik
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // XP İlerleme
                _buildSectionTitle('Seviye İlerlemesi', Icons.star),
                const SizedBox(height: 12),
                XPProgressBar(
                  currentXP: _totalXP % 200,
                  levelXP: 200,
                  level: _level,
                  label: _getLevelTitle(_level),
                ),

                const SizedBox(height: 32),

                // Haftalık Streak
                _buildSectionTitle('Bu Hafta', Icons.local_fire_department),
                const SizedBox(height: 12),
                Consumer<RoutineProvider>(
                  builder: (context, provider, _) {
                    final isActiveToday = provider.completedTasksToday > 0;
                    return WeeklyStreakIndicator(
                      weeklyProgress: _getWeeklyProgress(isActiveToday),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // İstatistikler
                _buildSectionTitle('İstatistikler', Icons.analytics),
                const SizedBox(height: 12),
                _buildStatsGrid(),

                const SizedBox(height: 32),

                // Rozetler
                _buildSectionTitle('Rozetler', Icons.emoji_events),
                const SizedBox(height: 12),
                AchievementsGrid(
                  achievements: DefaultAchievements.getAll(
                    currentStreak: _currentStreak,
                    tasksCompleted: _tasksCompleted,
                    routinesCreated: _routinesCreated,
                    perfectDays: _perfectDays,
                  ),
                  onAchievementTap: (achievement) {
                    _showAchievementDetail(context, achievement);
                  },
                ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Avatar (Firebase'den veya emoji)
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: authProvider.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(authProvider.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: authProvider.photoURL == null
                      ? const Center(
                          child: Text(
                            '🧔',
                            style: TextStyle(fontSize: 48),
                          ),
                        )
                      : null,
                );
              },
            ),

            const SizedBox(height: 16),

            // Kullanıcı adı (Firebase'den)
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Text(
                  authProvider.displayName ?? authProvider.email?.split('@').first ?? 'HairFlow Kullanıcısı',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Seviye badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Seviye $_level • ${_getLevelTitle(_level)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Streak ve XP özeti
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMiniStat('🔥', '$_currentStreak gün', 'Seri'),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildMiniStat('⭐', '$_totalXP', 'Toplam XP'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
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

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  value: '$_currentStreak',
                  label: 'Günlük Seri',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  value: '$_longestStreak',
                  label: 'En Uzun Seri',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  value: '$_tasksCompleted',
                  label: 'Görev Tamamlandı',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  iconColor: Colors.purple,
                  value: '$_perfectDays',
                  label: 'Mükemmel Gün',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<bool> _getWeeklyProgress(bool isActiveToday) {
    // Placeholder - gerçek veri Firebase'den gelecek
    final today = DateTime.now().weekday - 1;
    return List.generate(7, (i) {
      if (i < today) return i % 2 == 0; // Placeholder için rastgele
      if (i == today) return isActiveToday;
      return false;
    });
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'Çaylak';
      case 2:
        return 'Başlangıç';
      case 3:
        return 'Saç Bakım Uzmanı';
      case 4:
        return 'İleri Seviye';
      case 5:
        return 'Profesyonel';
      default:
        return 'Efsane';
    }
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Emoji
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: achievement.isUnlocked
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                    : null,
                color: achievement.isUnlocked
                    ? null
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Center(
                child: achievement.isUnlocked
                    ? Text(achievement.emoji, style: const TextStyle(fontSize: 48))
                    : const Icon(Icons.lock, size: 40, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // Başlık
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Açıklama
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // İlerleme
            if (!achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('İlerleme'),
                        Text(
                          '${achievement.currentValue}/${achievement.requiredValue}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Kazanıldı! 🎉',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

