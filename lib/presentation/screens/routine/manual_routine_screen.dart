import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../../domain/entities/routine.dart';
import '../../../core/constants/predefined_tasks.dart';

class ManualRoutineScreen extends StatefulWidget {
  const ManualRoutineScreen({super.key});

  @override
  State<ManualRoutineScreen> createState() => _ManualRoutineScreenState();
}

class _ManualRoutineScreenState extends State<ManualRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTasks = [];
  final List<TextEditingController> _customTaskControllers = [];
  
  bool _isLoading = false;
  bool _showTaskSelector = false;

  @override
  void initState() {
    super.initState();
    // Start with task selector open
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _customTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCustomTaskField() {
    setState(() {
      _customTaskControllers.add(TextEditingController());
    });
  }

  void _removeCustomTaskField(int index) {
    if (_customTaskControllers.length > 0) {
      setState(() {
        _customTaskControllers[index].dispose();
        _customTaskControllers.removeAt(index);
      });
    }
  }

  void _addSelectedTask(String task) {
    if (!_selectedTasks.contains(task)) {
      setState(() {
        _selectedTasks.add(task);
      });
    }
  }

  void _removeSelectedTask(String task) {
    setState(() {
      _selectedTasks.remove(task);
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Combine selected predefined tasks and custom tasks
      final customTasks = _customTaskControllers
          .map((controller) => controller.text.trim())
          .where((task) => task.isNotEmpty)
          .toList();
      
      final allTasks = [..._selectedTasks, ...customTasks];

      if (allTasks.isEmpty) {
        throw Exception('En az bir görev eklemelisiniz.');
      }

      final routine = Routine(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      final provider = context.read<RoutineProvider>();
      await provider.addRoutine(routine, tasks: allTasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Rutin başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manuel Rutin Oluştur'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveRoutine,
              child: const Text(
                'Kaydet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Rutininiz oluşturuluyor...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kendi rutininizi oluşturun. Lütfen aynı ürünü birden fazla rutinde kullanmamaya dikkat edin.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Routine Name
                    Text(
                      'Rutin Adı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Sabah Saç Bakım Rutini',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Rutin adı gereklidir';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Açıklama',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Rutininiz hakkında kısa bir açıklama...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Açıklama gereklidir';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Tasks Section
                    Text(
                      'Görevler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Task Selection Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _showTaskSelector = false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_showTaskSelector 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color: !_showTaskSelector 
                                          ? Colors.white 
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hazır Görevler',
                                      style: TextStyle(
                                        color: !_showTaskSelector 
                                            ? Colors.white 
                                            : Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _showTaskSelector = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _showTaskSelector 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: _showTaskSelector 
                                          ? Colors.white 
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Özel Görev',
                                      style: TextStyle(
                                        color: _showTaskSelector 
                                            ? Colors.white 
                                            : Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content based on selected tab
                    if (!_showTaskSelector) ...[
                      // Predefined Tasks Selector
                      _buildPredefinedTasksSelector(),
                    ] else ...[
                      // Custom Task Fields
                      _buildCustomTaskFields(),
                    ],

                    // Selected Tasks Display
                    if (_selectedTasks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Seçilen Görevler (${_selectedTasks.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTasks.map((task) {
                          return Chip(
                            label: Text(
                              task,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeSelectedTask(task),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Önemli Uyarı',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Bu bilgiler genel bilgilendirme amaçlıdır\n'
                                  '• Herhangi bir tedaviye başlamadan önce mutlaka bir dermatoloji uzmanına danışınız\n'
                                  '• Reçeteli ilaçlar doktor kontrolünde kullanılmalıdır\n'
                                  '• Yan etki durumunda kullanımı durdurunuz',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPredefinedTasksSelector() {
    return Column(
      children: PredefinedTasks.getCategories().map((category) {
        final tasks = PredefinedTasks.getTasksByCategory(category);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tasks.map((task) {
                final isSelected = _selectedTasks.contains(task);
                return FilterChip(
                  label: Text(
                    task,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _addSelectedTask(task);
                    } else {
                      _removeSelectedTask(task);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCustomTaskFields() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Özel Görevler',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addCustomTaskField,
              icon: const Icon(Icons.add),
              label: const Text('Görev Ekle'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_customTaskControllers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_task,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Özel görev eklemek için "Görev Ekle" butonuna tıklayın',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customTaskControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customTaskControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Özel görev ${index + 1} (Örn: Vitamin D takviyesi)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.task_alt),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeCustomTaskField(index),
                      icon: const Icon(Icons.remove_circle),
                      color: Colors.red,
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
