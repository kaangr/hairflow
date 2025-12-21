import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/routine_model.dart';
import '../models/routine_task_model.dart';
import '../models/tip_model.dart';
import 'local_datasource.dart';

/// Web-specific data source using SharedPreferences and in-memory storage
/// This is a lightweight alternative to SQLite for web platform
class WebDataSource implements LocalDataSource {
  static const String _routinesKey = 'routines';
  static const String _tasksKey = 'tasks';
  static const String _tipsKey = 'tips';
  
  SharedPreferences? _prefs;
  int _nextRoutineId = 1;
  int _nextTaskId = 1;
  int _nextTipId = 1;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Helper methods
  Future<List<Map<String, dynamic>>> _getList(String key) async {
    final prefs = await _preferences;
    final jsonStr = prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await _preferences;
    await prefs.setString(key, jsonEncode(list));
  }

  // Routines
  @override
  Future<List<RoutineModel>> getRoutines() async {
    final list = await _getList(_routinesKey);
    final routines = list.map((json) => RoutineModel.fromJson(_convertJsonForRead(json))).toList();
    if (routines.isNotEmpty) {
      _nextRoutineId = routines.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    return routines;
  }

  // JSON dönüşüm yardımcıları - Web için is_active int olarak kaydedilmeli
  Map<String, dynamic> _convertJsonForRead(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    // Boolean değerleri int'e çevir
    if (result['is_active'] is bool) {
      result['is_active'] = (result['is_active'] as bool) ? 1 : 0;
    }
    if (result['is_completed'] is bool) {
      result['is_completed'] = (result['is_completed'] as bool) ? 1 : 0;
    }
    if (result['is_favorite'] is bool) {
      result['is_favorite'] = (result['is_favorite'] as bool) ? 1 : 0;
    }
    return result;
  }

  @override
  Future<RoutineModel?> getRoutineById(int id) async {
    final routines = await getRoutines();
    try {
      return routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> insertRoutine(RoutineModel routine) async {
    final list = await _getList(_routinesKey);
    final id = _nextRoutineId++;
    
    final jsonData = routine.toJson();
    jsonData['id'] = id;
    
    list.add(jsonData);
    await _saveList(_routinesKey, list);
    return id;
  }

  @override
  Future<void> updateRoutine(RoutineModel routine) async {
    final list = await _getList(_routinesKey);
    final index = list.indexWhere((r) => r['id'] == routine.id);
    if (index != -1) {
      list[index] = routine.toJson();
      await _saveList(_routinesKey, list);
    }
  }

  @override
  Future<void> deleteRoutine(int id) async {
    final list = await _getList(_routinesKey);
    list.removeWhere((r) => r['id'] == id);
    await _saveList(_routinesKey, list);
    
    // Also delete associated tasks
    final taskList = await _getList(_tasksKey);
    taskList.removeWhere((t) => t['routine_id'] == id);
    await _saveList(_tasksKey, taskList);
  }

  // Tasks
  @override
  Future<List<RoutineTaskModel>> getTasks() async {
    final list = await _getList(_tasksKey);
    final tasks = list.map((json) => RoutineTaskModel.fromJson(_convertJsonForRead(json))).toList();
    if (tasks.isNotEmpty) {
      _nextTaskId = tasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    return tasks;
  }

  @override
  Future<List<RoutineTaskModel>> getTasksByDate(DateTime date) async {
    final tasks = await getTasks();
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return tasks.where((t) {
      final taskDateString = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      return taskDateString == dateString;
    }).toList();
  }

  @override
  Future<List<RoutineTaskModel>> getTasksByRoutineId(int routineId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.routineId == routineId).toList();
  }

  @override
  Future<int> insertTask(RoutineTaskModel task) async {
    final list = await _getList(_tasksKey);
    final id = _nextTaskId++;
    
    final jsonData = task.toJson();
    jsonData['id'] = id;
    
    list.add(jsonData);
    await _saveList(_tasksKey, list);
    return id;
  }

  @override
  Future<void> updateTask(RoutineTaskModel task) async {
    final list = await _getList(_tasksKey);
    final index = list.indexWhere((t) => t['id'] == task.id);
    if (index != -1) {
      list[index] = task.toJson();
      await _saveList(_tasksKey, list);
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    final list = await _getList(_tasksKey);
    list.removeWhere((t) => t['id'] == id);
    await _saveList(_tasksKey, list);
  }

  @override
  Future<void> markTaskCompleted(int id, bool isCompleted) async {
    final list = await _getList(_tasksKey);
    final index = list.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      list[index]['is_completed'] = isCompleted ? 1 : 0;
      list[index]['completed_at'] = isCompleted ? DateTime.now().toIso8601String() : null;
      await _saveList(_tasksKey, list);
    }
  }

  // Tips
  @override
  Future<List<TipModel>> getTips() async {
    final list = await _getList(_tipsKey);
    if (list.isEmpty) {
      // Insert default tips
      await _insertDefaultTips();
      return _getList(_tipsKey).then((l) => l.map((json) => TipModel.fromJson(_convertJsonForRead(json))).toList());
    }
    final tips = list.map((json) => TipModel.fromJson(_convertJsonForRead(json))).toList();
    if (tips.isNotEmpty) {
      _nextTipId = tips.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    return tips;
  }

  @override
  Future<List<TipModel>> getTipsByCategory(String category) async {
    final tips = await getTips();
    return tips.where((t) => t.category.toString().split('.').last == category).toList();
  }

  @override
  Future<int> insertTip(TipModel tip) async {
    final list = await _getList(_tipsKey);
    final id = _nextTipId++;
    
    final jsonData = tip.toJson();
    jsonData['id'] = id;
    
    list.add(jsonData);
    await _saveList(_tipsKey, list);
    return id;
  }

  @override
  Future<void> updateTip(TipModel tip) async {
    final list = await _getList(_tipsKey);
    final index = list.indexWhere((t) => t['id'] == tip.id);
    if (index != -1) {
      list[index] = tip.toJson();
      await _saveList(_tipsKey, list);
    }
  }

  @override
  Future<void> deleteTip(int id) async {
    final list = await _getList(_tipsKey);
    list.removeWhere((t) => t['id'] == id);
    await _saveList(_tipsKey, list);
  }

  @override
  Future<void> toggleTipFavorite(int id, bool isFavorite) async {
    final list = await _getList(_tipsKey);
    final index = list.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      list[index]['is_favorite'] = isFavorite ? 1 : 0;
      await _saveList(_tipsKey, list);
    }
  }

  Future<void> _insertDefaultTips() async {
    final defaultTips = [
      {
        'id': 1,
        'title': 'Minoxidil %5 Çözeltisi',
        'content': 'Minoxidil %5 günde 2 kez (1 ml) uygulanmalıdır. Saç derisi tamamen kuru olduğunda uygulayın ve 4 saat boyunca yıkamayın.',
        'category': 'product',
        'image_url': 'assets/images/products/minoxidil.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'title': 'Biotin 5000mcg Takviyesi',
        'content': 'Biotin 5000-10000 mcg günde 1 kez alınabilir. B vitamin kompleksi ile birlikte alınması önerilir.',
        'category': 'nutrition',
        'image_url': 'assets/images/products/biotin.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'title': 'Günlük Rutin Önerisi',
        'content': 'Sabah: Minoxidil + kafeinli şampuan\nAkşam: Minoxidil (2. doz)\nGünlük: Biotin takviyesi',
        'category': 'routine',
        'image_url': 'assets/images/routines/daily_routine.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];
    
    await _saveList(_tipsKey, defaultTips);
    _nextTipId = 4;
  }
}
