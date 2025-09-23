import 'package:flutter/material.dart';
import '../../domain/entities/tip.dart';
import '../../core/constants/motivational_messages.dart';
import 'animated_loading.dart';

class MotivationalTipCard extends StatefulWidget {
  final dynamic tip; // Tip entity
  final VoidCallback? onRefresh;
  final Function(bool)? onFavoriteToggle;
  final VoidCallback? onTap;

  const MotivationalTipCard({
    super.key,
    required this.tip,
    this.onRefresh,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<MotivationalTipCard> createState() => _MotivationalTipCardState();
}

class _MotivationalTipCardState extends State<MotivationalTipCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  bool _isRefreshing = false;
  String _motivationalMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _motivationalMessage = MotivationalMessages.getRandomDailyMotivation();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    // Animate out
    await _animationController.reverse();
    
    // Update content
    setState(() {
      _motivationalMessage = MotivationalMessages.getRandomDailyMotivation();
    });
    
    // Call refresh callback
    widget.onRefresh?.call();
    
    // Wait a bit for the new tip to load
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Animate back in
    await _animationController.forward();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                children: [
                  // Main card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(context, widget.tip?.category ?? TipCategory.general),
                          _getCategoryColor(context, widget.tip?.category ?? TipCategory.general).withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(context, widget.tip?.category ?? TipCategory.general).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with category and actions
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getCategoryIcon(widget.tip?.category ?? TipCategory.general),
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getCategoryName(widget.tip?.category ?? TipCategory.general),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (widget.onFavoriteToggle != null)
                                    IconButton(
                                      icon: Icon(
                                        widget.tip?.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => widget.onFavoriteToggle?.call(!(widget.tip?.isFavorite ?? false)),
                                    ),
                                  if (widget.onRefresh != null)
                                    IconButton(
                                      icon: _isRefreshing 
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: PulsingDots(color: Colors.white, size: 4),
                                            )
                                          : const Icon(Icons.refresh, color: Colors.white),
                                      onPressed: _handleRefresh,
                                      tooltip: 'Yeni öneri',
                                    ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Motivational message
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _motivationalMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Tip title
                              Text(
                                widget.tip?.title ?? 'Yükleniyor...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Tip content
                              Text(
                                widget.tip?.content ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              if (widget.onTap != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Devamını Oku',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating motivation bubble
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lightbulb,
                        color: _getCategoryColor(context, widget.tip?.category ?? TipCategory.general),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(BuildContext context, TipCategory category) {
    switch (category) {
      case TipCategory.product:
        return const Color(0xFF2196F3); // Blue
      case TipCategory.routine:
        return const Color(0xFF4CAF50); // Green
      case TipCategory.general:
        return const Color(0xFFFF9800); // Orange
      case TipCategory.nutrition:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData _getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.product:
        return Icons.medical_services;
      case TipCategory.routine:
        return Icons.schedule;
      case TipCategory.general:
        return Icons.info;
      case TipCategory.nutrition:
        return Icons.restaurant;
    }
  }

  String _getCategoryName(TipCategory category) {
    switch (category) {
      case TipCategory.product:
        return 'Ürün';
      case TipCategory.routine:
        return 'Rutin';
      case TipCategory.general:
        return 'Genel';
      case TipCategory.nutrition:
        return 'Beslenme';
    }
  }
}
