import 'package:flutter/material.dart';
import '../../domain/entities/routine_task.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/motivational_messages.dart';
import 'animated_loading.dart';

class TaskCard extends StatelessWidget {
  final RoutineTask task;
  final Function(bool) onCompleted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: task.isCompleted ? 1 : 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: task.isCompleted
              ? Theme.of(context).colorScheme.surfaceContainer
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              _buildProductImage(),
              const SizedBox(width: 8),
              // Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    onCompleted(value ?? false);
                    if (value == true) {
                      _showCompletionFeedback(context);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              decoration: task.isCompleted 
                  ? TextDecoration.lineThrough 
                  : null,
              color: task.isCompleted 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  : null,
            ),
          ),
          subtitle: task.description != null
              ? Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                    color: task.isCompleted 
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                )
              : null,
          trailing: task.isCompleted
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (task.completedAt != null)
                      Text(
                        _formatTime(task.completedAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.outline,
                ),
        ),
      ),
    );
  }

  void _showCompletionFeedback(BuildContext context) {
    final motivationalMessage = MotivationalMessages.getRandomTaskCompletionMessage();
    
    // Show success animation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(context, motivationalMessage),
    );

    // Auto dismiss after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    // Also show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const AnimatedSuccessIcon(size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(motivationalMessage)),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSuccessDialog(BuildContext context, String message) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedSuccessIcon(size: 80),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Böyle devam et! 💪',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = Product.getProductImageForTask(task.title);
    
    if (imagePath != null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon();
            },
          ),
        ),
      );
    }
    
    return _buildDefaultIcon();
  }
  
  Widget _buildDefaultIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Icon(
        Icons.medical_services_outlined,
        size: 20,
        color: Colors.grey[600],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
