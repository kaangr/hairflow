import 'package:flutter/material.dart';
import '../../domain/entities/tip.dart';

class TipCard extends StatelessWidget {
  final dynamic tip; // Tip entity
  final VoidCallback? onRefresh;
  final Function(bool)? onFavoriteToggle;
  final VoidCallback? onTap;

  const TipCard({
    super.key,
    required this.tip,
    this.onRefresh,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200, // Fixed height to prevent overflow
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with category and actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context, tip.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryName(tip.category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onFavoriteToggle != null)
                    IconButton(
                      icon: Icon(
                        tip.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: tip.isFavorite 
                            ? Colors.red 
                            : Theme.of(context).colorScheme.outline,
                      ),
                      onPressed: () => onFavoriteToggle?.call(!tip.isFavorite),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  if (onRefresh != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRefresh,
                      tooltip: 'Yeni öneri',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title - Fixed height
              SizedBox(
                height: 48,
                child: Text(
                  tip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Content - Flexible to fill remaining space
              Expanded(
                child: Text(
                  tip.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Bottom action
              if (onTap != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.read_more, size: 16),
                    label: const Text(
                      'Devamını Oku',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, TipCategory category) {
    switch (category) {
      case TipCategory.product:
        return Colors.blue;
      case TipCategory.routine:
        return Colors.green;
      case TipCategory.general:
        return Colors.orange;
      case TipCategory.nutrition:
        return Colors.purple;
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