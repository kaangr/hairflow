import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

/// Duolingo tarzı kutlama overlay'i
/// Görev tamamlandığında, streak elde edildiğinde kullanılır
class CelebrationOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? emoji;
  final int? xpEarned;
  final VoidCallback onDismiss;
  final CelebrationType type;

  const CelebrationOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
    this.xpEarned,
    required this.onDismiss,
    this.type = CelebrationType.taskComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // Animasyonları başlat
    _scaleController.forward();
    _confettiController.play();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _bounceController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Konfeti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: _getConfettiColors(),
            ),
          ),
          
          // Ana içerik
          GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: _getTypeColor().withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji veya ikon
                        AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -10 * _bounceAnimation.value),
                              child: _buildIcon(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Başlık
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Alt başlık
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // XP kazanıldıysa göster
                        if (widget.xpEarned != null) ...[
                          const SizedBox(height: 24),
                          _buildXPBadge(),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Devam butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onDismiss,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getTypeColor(),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'DEVAM ET',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.emoji != null) {
      return Text(
        widget.emoji!,
        style: const TextStyle(fontSize: 72),
      );
    }
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor(),
            _getTypeColor().withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor().withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        _getTypeIcon(),
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildXPBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            '+${widget.xpEarned} XP',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getConfettiColors() {
    switch (widget.type) {
      case CelebrationType.taskComplete:
        return [Colors.green, Colors.lightGreen, Colors.teal, Colors.cyan];
      case CelebrationType.streakAchieved:
        return [Colors.orange, Colors.amber, Colors.yellow, Colors.red];
      case CelebrationType.routineComplete:
        return [Colors.purple, Colors.deepPurple, Colors.pink, Colors.blue];
      case CelebrationType.milestone:
        return [Colors.amber, Colors.orange, Colors.yellow, Colors.white];
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case CelebrationType.taskComplete:
        return Colors.green;
      case CelebrationType.streakAchieved:
        return Colors.orange;
      case CelebrationType.routineComplete:
        return Colors.purple;
      case CelebrationType.milestone:
        return Colors.amber;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case CelebrationType.taskComplete:
        return Icons.check_circle;
      case CelebrationType.streakAchieved:
        return Icons.local_fire_department;
      case CelebrationType.routineComplete:
        return Icons.emoji_events;
      case CelebrationType.milestone:
        return Icons.star;
    }
  }
}

enum CelebrationType {
  taskComplete,
  streakAchieved,
  routineComplete,
  milestone,
}

/// Kutlama overlay'ini göstermek için helper fonksiyon
void showCelebration(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? emoji,
  int? xpEarned,
  CelebrationType type = CelebrationType.taskComplete,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => CelebrationOverlay(
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      xpEarned: xpEarned,
      type: type,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}

