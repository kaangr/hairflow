import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_task.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../core/utils/time_scheduler.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineRepository _repository;
  
  List<Routine> _routines = [];
  List<RoutineTask> _todayTasks = [];
  List<RoutineTask> _allTasks = [];
  bool _isLoading = false;
  String? _error;

  RoutineProvider(this._repository) {
    loadData();
  }

  List<Routine> get routines => _routines;
  List<RoutineTask> get todayTasks => _todayTasks;
  List<RoutineTask> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get completedTasksToday {
    return _todayTasks.where((task) => task.isCompleted).length;
  }

  int get totalTasksToday => _todayTasks.length;

  double get progressPercentage {
    if (totalTasksToday == 0) return 0.0;
    return completedTasksToday / totalTasksToday;
  }

  Future<void> loadData() async {
    _setLoading(true);
    try {
      await _loadRoutines();
      await _loadTodayTasks();
      await _loadAllTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> _loadRoutines() async {
    _routines = await _repository.getRoutines();
  }

  Future<void> _loadTodayTasks() async {
    final today = DateTime.now();
    await _repository.createDailyTasks(today);
    _todayTasks = await _repository.getTasksByDate(today);
  }

  Future<void> _loadAllTasks() async {
    _allTasks = await _repository.getTasks();
  }

  Future<void> markTaskCompleted(int taskId, bool isCompleted) async {
    try {
      await _repository.markTaskCompleted(taskId, isCompleted);
      
      // Update local state
      final taskIndex = _todayTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _todayTasks[taskIndex] = _todayTasks[taskIndex].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }

      // Update all tasks as well
      final allTaskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (allTaskIndex != -1) {
        _allTasks[allTaskIndex] = _allTasks[allTaskIndex].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getTasksByDate(DateTime date) async {
    try {
      await _repository.createDailyTasks(date);
      final tasks = await _repository.getTasksByDate(date);
      
      if (isSameDay(date, DateTime.now())) {
        _todayTasks = tasks;
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> addRoutine(Routine routine, {List<String>? tasks}) async {
    try {
      // Duplicate product validation (genel saç sağlığı hariç)
      if (tasks != null && !routine.name.toLowerCase().contains('genel')) {
        final conflicts = await _checkForProductConflicts(tasks);
        if (conflicts.isNotEmpty) {
          throw Exception('Bu ürünler zaten başka rutinlerde kullanılıyor: ${conflicts.join(', ')}. Aynı anda birden fazla rutinde aynı ürün kullanılamaz.');
        }
      }
      
      // Gerçek veritabanına kaydet
      final id = await _repository.createRoutine(routine);
      final newRoutine = routine.copyWith(id: id);
      
      // Local listeye ekle
      _routines.add(newRoutine);
      
      // Eğer görevler verilmişse, bunları bugün için oluştur
      if (tasks != null && tasks.isNotEmpty) {
        await _createTasksForRoutine(id, tasks, DateTime.now());
      }
      
      // Bugün için görevleri yeniden yükle
      await _loadTodayTasks();
      await _loadAllTasks();
      
      _error = null;
      notifyListeners();
      
      // Force a complete data reload to ensure consistency across platforms
      await Future.delayed(const Duration(milliseconds: 100));
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<String>> _checkForProductConflicts(List<String> newTasks) async {
    final conflicts = <String>[];
    
    // Mevcut tüm görevleri al
    final existingTasks = await _repository.getTasks();
    
    // Yeni görevlerdeki ürünleri çıkar
    final newProducts = <ProductType>{};
    for (final task in newTasks) {
      final productType = Product.extractProductType(task);
      if (productType != null && productType != ProductType.generalCare) {
        newProducts.add(productType);
      }
    }
    
    // Mevcut görevlerdeki ürünleri kontrol et
    final existingProducts = <ProductType>{};
    for (final task in existingTasks) {
      final productType = Product.extractProductType(task.title);
      if (productType != null && productType != ProductType.generalCare) {
        existingProducts.add(productType);
      }
    }
    
    // Çakışmaları tespit et
    for (final product in newProducts) {
      if (existingProducts.contains(product)) {
        conflicts.add(Product.productNames[product] ?? product.toString());
      }
    }
    
    return conflicts;
  }

  Future<void> _createTasksForRoutine(int routineId, List<String> taskTitles, DateTime date) async {
    // Otomatik saat ataması yap
    final scheduledTimes = TimeScheduler.assignTimesToTasks(taskTitles, date);
    
    for (int i = 0; i < taskTitles.length; i++) {
      final task = RoutineTask(
        routineId: routineId,
        title: taskTitles[i],
        order: i,
        date: date,
        scheduledTime: i < scheduledTimes.length ? scheduledTimes[i] : null,
        createdAt: DateTime.now(),
      );
      await _repository.createTask(task);
    }
  }

  Future<void> updateRoutine(Routine routine) async {
    try {
      await _repository.updateRoutine(routine);
      
      final index = _routines.indexWhere((r) => r.id == routine.id);
      if (index != -1) {
        _routines[index] = routine;
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      await _repository.deleteRoutine(int.parse(routineId));
      _routines.removeWhere((r) => r.id.toString() == routineId);
      
      // Reload today's tasks as they might have changed
      await _loadTodayTasks();
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get tasks for a specific date
  List<RoutineTask> getTasksForDate(DateTime date) {
    return _allTasks.where((task) {
      return task.date.year == date.year &&
             task.date.month == date.month &&
             task.date.day == date.day;
    }).toList();
  }

  // Get task completion percentage for date
  double getCompletionPercentageForDate(DateTime date) {
    final tasksForDate = getTasksForDate(date);
    if (tasksForDate.isEmpty) return 0.0;
    
    final completedTasks = tasksForDate.where((task) => task.isCompleted).length;
    return completedTasks / tasksForDate.length;
  }

  // Update task scheduled time
  Future<void> updateTaskScheduledTime(int taskId, DateTime newTime) async {
    try {
      // Find and update task in local list
      for (int i = 0; i < _allTasks.length; i++) {
        if (_allTasks[i].id == taskId) {
          _allTasks[i] = _allTasks[i].copyWith(scheduledTime: newTime);
          break;
        }
      }
      
      // Update in database
      final task = _allTasks.firstWhere((t) => t.id == taskId);
      await _repository.updateTask(task);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
