import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/entities/routine_task.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/duolingo_style/celebration_overlay.dart';
import 'edit_routine_screen.dart';

/// Rutin detay ekranı - CRUD işlemleri için
class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<RoutineTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _loadTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final provider = context.read<RoutineProvider>();
    final allTasks = provider.allTasks;
    setState(() {
      _tasks = allTasks.where((t) => t.routineId == widget.routine.id).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildSliverAppBar(context),
          
          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rutin bilgi kartı
                  _buildRoutineInfoCard(context),
                  
                  const SizedBox(height: 24),
                  
                  // Görevler başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Görevler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addNewTask,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Ekle'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Görev listesi
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_tasks.isEmpty)
                    _buildEmptyTasksState()
                  else
                    _buildTasksList(),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Alt butonlar
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.routine.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: PatternPainter(),
                  ),
                ),
              ),
              
              // İkon
              Center(
                child: Icon(
                  Icons.spa,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Düzenle butonu
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEdit(),
          tooltip: 'Düzenle',
        ),
        // Daha fazla seçenekler
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'toggle_active',
              child: Row(
                children: [
                  Icon(Icons.toggle_on),
                  SizedBox(width: 12),
                  Text('Aktif/Pasif'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 12),
                  Text('Kopyala'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoutineInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Durum badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.routine.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.routine.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.routine.isActive
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      size: 16,
                      color: widget.routine.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.routine.isActive ? 'Aktif' : 'Pasif',
                      style: TextStyle(
                        color: widget.routine.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_tasks.length} görev',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Açıklama
          Text(
            widget.routine.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 16),
          
          // Oluşturulma tarihi
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Oluşturulma: ${_formatDate(widget.routine.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz görev yok',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu rutine görevler ekleyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addNewTask,
            icon: const Icon(Icons.add),
            label: const Text('Görev Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      onReorder: _reorderTasks,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _TaskListItem(
          key: ValueKey(task.id),
          task: task,
          index: index,
          onEdit: () => _editTask(task),
          onDelete: () => _deleteTask(task),
          onToggleComplete: () => _toggleTaskComplete(task),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteConfirmation(),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Sil', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEdit(),
                icon: const Icon(Icons.edit),
                label: const Text('Düzenle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'toggle_active':
        _toggleRoutineActive();
        break;
      case 'duplicate':
        _duplicateRoutine();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoutineScreen(routine: widget.routine),
      ),
    ).then((_) => _loadTasks());
  }

  void _toggleRoutineActive() async {
    final provider = context.read<RoutineProvider>();
    final updatedRoutine = widget.routine.copyWith(
      isActive: !widget.routine.isActive,
      updatedAt: DateTime.now(),
    );
    await provider.updateRoutine(updatedRoutine);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedRoutine.isActive
                ? 'Rutin aktif edildi'
                : 'Rutin pasif edildi',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _duplicateRoutine() async {
    final provider = context.read<RoutineProvider>();
    final newRoutine = Routine(
      name: '${widget.routine.name} (Kopya)',
      description: widget.routine.description,
      isActive: true,
      createdAt: DateTime.now(),
    );
    
    final taskTitles = _tasks.map((t) => t.title).toList();
    await provider.addRoutine(newRoutine, tasks: taskTitles);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutin kopyalandı'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
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
          '"${widget.routine.name}" rutinini silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRoutine();
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

  void _deleteRoutine() async {
    final provider = context.read<RoutineProvider>();
    await provider.deleteRoutine(widget.routine.id.toString());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutin silindi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _addNewTask() {
    _showTaskDialog();
  }

  void _editTask(RoutineTask task) {
    _showTaskDialog(task: task);
  }

  void _deleteTask(RoutineTask task) async {
    // TODO: Repository'ye deleteTask ekle
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Görev silindi'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              _tasks.add(task);
              _tasks.sort((a, b) => a.order.compareTo(b.order));
            });
          },
        ),
      ),
    );
  }

  void _toggleTaskComplete(RoutineTask task) async {
    final provider = context.read<RoutineProvider>();
    await provider.markTaskCompleted(task.id!, !task.isCompleted);
    
    // Eğer tamamlandıysa kutlama göster
    if (!task.isCompleted && mounted) {
      showCelebration(
        context,
        title: 'Harika! 🎉',
        subtitle: 'Görev tamamlandı',
        xpEarned: 10,
        type: CelebrationType.taskComplete,
      );
    }
    
    _loadTasks();
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
    // TODO: Sıralamayı kaydet
  }

  void _showTaskDialog({RoutineTask? task}) {
    final controller = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            
            Text(
              task == null ? 'Yeni Görev' : 'Görevi Düzenle',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Görev Adı',
                hintText: 'örn: Minoxidil uygula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.task_alt),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pop(context);
                        // TODO: Görevi kaydet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              task == null
                                  ? 'Görev eklendi'
                                  : 'Görev güncellendi',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(task == null ? 'Ekle' : 'Güncelle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Görev liste öğesi
class _TaskListItem extends StatelessWidget {
  final RoutineTask task;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const _TaskListItem({
    super.key,
    required this.task,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? Colors.green
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                              : null,
                        ),
                      ),
                      if (task.scheduledTime != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.scheduledTime!.hour.toString().padLeft(2, '0')}:${task.scheduledTime!.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Aksiyon butonları
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Arka plan deseni
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

