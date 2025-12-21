import 'package:flutter/material.dart';

/// Duolingo tarzı XP/İlerleme çubuğu
class XPProgressBar extends StatefulWidget {
  final int currentXP;
  final int levelXP;
  final int level;
  final String? label;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.levelXP,
    required this.level,
    this.label,
  });

  @override
  State<XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends State<XPProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentXP / widget.levelXP,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(XPProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXP != widget.currentXP) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.currentXP / widget.levelXP,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst bilgi satırı
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF58CC02).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Seviye ${widget.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.label != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    widget.label!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${widget.currentXP}/${widget.levelXP} XP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF58CC02),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF58CC02), Color(0xFF7FD934)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Shine effect
                  if (_progressAnimation.value > 0.1)
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Dairesel ilerleme göstergesi (görev tamamlama için)
class CircularProgressWidget extends StatefulWidget {
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final double size;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    this.size = 120,
  });

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final isComplete = widget.completedTasks == widget.totalTasks && widget.totalTasks > 0;
        
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
              ),
              
              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isComplete)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    )
                  else
                    Text(
                      '${((_progressAnimation.value) * 100).round()}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.completedTasks}/${widget.totalTasks}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

