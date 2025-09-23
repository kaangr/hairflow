import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_task.dart';
import '../../data/repositories/routine_repository_impl.dart';

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

  Future<void> addRoutine(Routine routine) async {
    try {
      // Bu basit demo için sadece listeye ekleyelim
      // Gerçek uygulamada database insert yapılacak
      final id = DateTime.now().millisecondsSinceEpoch;
      final newRoutine = routine.copyWith(id: id);
      _routines.add(newRoutine);
      
      // Create tasks for today if any
      await _loadTodayTasks();
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
}
