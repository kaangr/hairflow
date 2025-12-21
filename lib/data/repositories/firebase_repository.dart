import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_task.dart';
import '../../domain/entities/tip.dart';
import '../models/routine_model.dart';
import '../models/routine_task_model.dart';
import '../models/tip_model.dart';

/// Firebase Firestore repository - Cloud sync için
class FirebaseRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // ============ ROUTINE METHODS ============

  /// Rutin oluştur ve Firebase'e kaydet
  Future<String> createRoutine(Routine routine) async {
    final data = {
      'name': routine.name,
      'description': routine.description,
      'isActive': routine.isActive,
    };
    return await _firestoreService.createRoutine(data);
  }

  /// Firebase'den tüm rutinleri getir
  Future<List<RoutineModel>> getRoutines() async {
    final data = await _firestoreService.getRoutines();
    return data.map((json) => _routineFromFirestore(json)).toList();
  }

  /// Rutin güncelle
  Future<void> updateRoutine(Routine routine) async {
    if (routine.id == null) return;
    await _firestoreService.updateRoutine(routine.id.toString(), {
      'name': routine.name,
      'description': routine.description,
      'isActive': routine.isActive,
    });
  }

  /// Rutin sil
  Future<void> deleteRoutine(String routineId) async {
    await _firestoreService.deleteRoutine(routineId);
  }

  // ============ TASK METHODS ============

  /// Görev oluştur
  Future<String> createTask(RoutineTask task) async {
    final data = {
      'routineId': task.routineId.toString(),
      'title': task.title,
      'description': task.description,
      'order': task.order,
      'isCompleted': task.isCompleted,
      'date': Timestamp.fromDate(task.date),
      'scheduledTime': task.scheduledTime != null 
          ? Timestamp.fromDate(task.scheduledTime!) 
          : null,
    };
    return await _firestoreService.createTask(data);
  }

  /// Belirli tarihteki görevleri getir
  Future<List<RoutineTaskModel>> getTasksByDate(DateTime date) async {
    final data = await _firestoreService.getTasksByDate(date);
    return data.map((json) => _taskFromFirestore(json)).toList();
  }

  /// Tüm görevleri getir
  Future<List<RoutineTaskModel>> getAllTasks() async {
    final data = await _firestoreService.getAllTasks();
    return data.map((json) => _taskFromFirestore(json)).toList();
  }

  /// Rutin'e ait görevleri getir
  Future<List<RoutineTaskModel>> getTasksByRoutineId(String routineId) async {
    final data = await _firestoreService.getTasksByRoutineId(routineId);
    return data.map((json) => _taskFromFirestore(json)).toList();
  }

  /// Görev güncelle
  Future<void> updateTask(RoutineTask task) async {
    if (task.id == null) return;
    await _firestoreService.updateTask(task.id.toString(), {
      'title': task.title,
      'description': task.description,
      'order': task.order,
      'isCompleted': task.isCompleted,
      'date': Timestamp.fromDate(task.date),
      'scheduledTime': task.scheduledTime != null 
          ? Timestamp.fromDate(task.scheduledTime!) 
          : null,
    });
  }

  /// Görev tamamlandı olarak işaretle
  Future<void> markTaskCompleted(String taskId, bool isCompleted) async {
    await _firestoreService.markTaskCompleted(taskId, isCompleted);
    
    // XP ekle ve streak güncelle
    if (isCompleted) {
      await _firestoreService.addXP(10);
      await _firestoreService.updateStreak();
    }
  }

  /// Görev sil
  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }

  // ============ TIPS METHODS ============

  /// Global ipuçlarını getir
  Future<List<TipModel>> getTips() async {
    final data = await _firestoreService.getTips();
    return data.map((json) => _tipFromFirestore(json)).toList();
  }

  /// Kategoriye göre ipuçlarını getir
  Future<List<TipModel>> getTipsByCategory(String category) async {
    final data = await _firestoreService.getTipsByCategory(category);
    return data.map((json) => _tipFromFirestore(json)).toList();
  }

  // ============ PRODUCTS METHODS ============

  /// Global ürünleri getir
  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _firestoreService.getProducts();
  }

  /// Kategoriye göre ürünleri getir
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final products = await _firestoreService.getProducts();
    return products.where((p) => p['category'] == category).toList();
  }

  // ============ USER STATS METHODS ============

  /// Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>?> getUserStats() async {
    return await _firestoreService.getUserStats();
  }

  /// XP ekle
  Future<void> addXP(int amount) async {
    await _firestoreService.addXP(amount);
  }

  /// Streak güncelle
  Future<void> updateStreak() async {
    await _firestoreService.updateStreak();
  }

  // ============ HELPER METHODS ============

  RoutineModel _routineFromFirestore(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];
    
    return RoutineModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: createdAt is Timestamp 
          ? createdAt.toDate() 
          : DateTime.now(),
      updatedAt: updatedAt is Timestamp 
          ? updatedAt.toDate() 
          : null,
    );
  }

  RoutineTaskModel _taskFromFirestore(Map<String, dynamic> json) {
    final date = json['date'];
    final scheduledTime = json['scheduledTime'];
    final createdAt = json['createdAt'];
    final completedAt = json['completedAt'];
    
    return RoutineTaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      routineId: int.tryParse(json['routineId'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      date: date is Timestamp ? date.toDate() : DateTime.now(),
      scheduledTime: scheduledTime is Timestamp ? scheduledTime.toDate() : null,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      completedAt: completedAt is Timestamp ? completedAt.toDate() : null,
    );
  }

  TipModel _tipFromFirestore(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final categoryStr = json['category'] as String? ?? 'general';
    
    TipCategory category;
    switch (categoryStr) {
      case 'product':
        category = TipCategory.product;
        break;
      case 'routine':
        category = TipCategory.routine;
        break;
      case 'nutrition':
        category = TipCategory.nutrition;
        break;
      default:
        category = TipCategory.general;
    }
    
    return TipModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: category,
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}

