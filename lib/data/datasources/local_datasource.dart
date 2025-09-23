import 'package:sqflite/sqflite.dart';
import '../models/routine_model.dart';
import '../models/routine_task_model.dart';
import '../models/tip_model.dart';
import '../../core/constants/app_constants.dart';
import 'database_helper.dart';

abstract class LocalDataSource {
  // Routines
  Future<List<RoutineModel>> getRoutines();
  Future<RoutineModel?> getRoutineById(int id);
  Future<int> insertRoutine(RoutineModel routine);
  Future<void> updateRoutine(RoutineModel routine);
  Future<void> deleteRoutine(int id);

  // Routine Tasks
  Future<List<RoutineTaskModel>> getTasks();
  Future<List<RoutineTaskModel>> getTasksByDate(DateTime date);
  Future<List<RoutineTaskModel>> getTasksByRoutineId(int routineId);
  Future<int> insertTask(RoutineTaskModel task);
  Future<void> updateTask(RoutineTaskModel task);
  Future<void> deleteTask(int id);
  Future<void> markTaskCompleted(int id, bool isCompleted);

  // Tips
  Future<List<TipModel>> getTips();
  Future<List<TipModel>> getTipsByCategory(String category);
  Future<int> insertTip(TipModel tip);
  Future<void> updateTip(TipModel tip);
  Future<void> deleteTip(int id);
  Future<void> toggleTipFavorite(int id, bool isFavorite);
}

class LocalDataSourceImpl implements LocalDataSource {
  final DatabaseHelper _databaseHelper;

  LocalDataSourceImpl(this._databaseHelper);

  // Routines
  @override
  Future<List<RoutineModel>> getRoutines() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.routinesTable,
      orderBy: 'created_at ASC',
    );
    return result.map((json) => RoutineModel.fromJson(json)).toList();
  }

  @override
  Future<RoutineModel?> getRoutineById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.routinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return RoutineModel.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<int> insertRoutine(RoutineModel routine) async {
    final db = await _databaseHelper.database;
    return await db.insert(AppConstants.routinesTable, routine.toJson());
  }

  @override
  Future<void> updateRoutine(RoutineModel routine) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.routinesTable,
      routine.toJson(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  @override
  Future<void> deleteRoutine(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      AppConstants.routinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Routine Tasks
  @override
  Future<List<RoutineTaskModel>> getTasks() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.routineTasksTable,
      orderBy: 'date DESC, order_index ASC',
    );
    return result.map((json) => RoutineTaskModel.fromJson(json)).toList();
  }

  @override
  Future<List<RoutineTaskModel>> getTasksByDate(DateTime date) async {
    final db = await _databaseHelper.database;
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.query(
      AppConstants.routineTasksTable,
      where: 'date = ?',
      whereArgs: [dateString],
      orderBy: 'order_index ASC',
    );
    return result.map((json) => RoutineTaskModel.fromJson(json)).toList();
  }

  @override
  Future<List<RoutineTaskModel>> getTasksByRoutineId(int routineId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.routineTasksTable,
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'date DESC, order_index ASC',
    );
    return result.map((json) => RoutineTaskModel.fromJson(json)).toList();
  }

  @override
  Future<int> insertTask(RoutineTaskModel task) async {
    final db = await _databaseHelper.database;
    return await db.insert(AppConstants.routineTasksTable, task.toJson());
  }

  @override
  Future<void> updateTask(RoutineTaskModel task) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.routineTasksTable,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      AppConstants.routineTasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markTaskCompleted(int id, bool isCompleted) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.routineTasksTable,
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tips
  @override
  Future<List<TipModel>> getTips() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.tipsTable,
      orderBy: 'created_at DESC',
    );
    return result.map((json) => TipModel.fromJson(json)).toList();
  }

  @override
  Future<List<TipModel>> getTipsByCategory(String category) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.tipsTable,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => TipModel.fromJson(json)).toList();
  }

  @override
  Future<int> insertTip(TipModel tip) async {
    final db = await _databaseHelper.database;
    return await db.insert(AppConstants.tipsTable, tip.toJson());
  }

  @override
  Future<void> updateTip(TipModel tip) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.tipsTable,
      tip.toJson(),
      where: 'id = ?',
      whereArgs: [tip.id],
    );
  }

  @override
  Future<void> deleteTip(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      AppConstants.tipsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleTipFavorite(int id, bool isFavorite) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.tipsTable,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
