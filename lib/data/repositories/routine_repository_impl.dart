import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_task.dart';
import '../datasources/local_datasource.dart';
import '../models/routine_model.dart';
import '../models/routine_task_model.dart';
import '../../core/constants/app_constants.dart';

abstract class RoutineRepository {
  Future<List<Routine>> getRoutines();
  Future<Routine?> getRoutineById(int id);
  Future<int> createRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> deleteRoutine(int id);

  Future<List<RoutineTask>> getTasks();
  Future<List<RoutineTask>> getTasksByDate(DateTime date);
  Future<List<RoutineTask>> getTasksByRoutineId(int routineId);
  Future<int> createTask(RoutineTask task);
  Future<void> updateTask(RoutineTask task);
  Future<void> deleteTask(int id);
  Future<void> markTaskCompleted(int id, bool isCompleted);
  Future<void> createDailyTasks(DateTime date);
  Future<int> getCompletedTasksCount(DateTime date);
  Future<int> getTotalTasksCount(DateTime date);
}

class RoutineRepositoryImpl implements RoutineRepository {
  final LocalDataSource _localDataSource;

  RoutineRepositoryImpl(this._localDataSource);

  // Routines
  @override
  Future<List<Routine>> getRoutines() async {
    final routineModels = await _localDataSource.getRoutines();
    return routineModels.cast<Routine>();
  }

  @override
  Future<Routine?> getRoutineById(int id) async {
    final routineModel = await _localDataSource.getRoutineById(id);
    return routineModel;
  }

  @override
  Future<int> createRoutine(Routine routine) async {
    final routineModel = RoutineModel.fromEntity(routine);
    return await _localDataSource.insertRoutine(routineModel);
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final routineModel = RoutineModel.fromEntity(routine);
    await _localDataSource.updateRoutine(routineModel);
  }

  @override
  Future<void> deleteRoutine(int id) async {
    await _localDataSource.deleteRoutine(id);
  }

  // Tasks
  @override
  Future<List<RoutineTask>> getTasks() async {
    final taskModels = await _localDataSource.getTasks();
    return taskModels.cast<RoutineTask>();
  }

  @override
  Future<List<RoutineTask>> getTasksByDate(DateTime date) async {
    final taskModels = await _localDataSource.getTasksByDate(date);
    return taskModels.cast<RoutineTask>();
  }

  @override
  Future<List<RoutineTask>> getTasksByRoutineId(int routineId) async {
    final taskModels = await _localDataSource.getTasksByRoutineId(routineId);
    return taskModels.cast<RoutineTask>();
  }

  @override
  Future<int> createTask(RoutineTask task) async {
    final taskModel = RoutineTaskModel.fromEntity(task);
    return await _localDataSource.insertTask(taskModel);
  }

  @override
  Future<void> updateTask(RoutineTask task) async {
    final taskModel = RoutineTaskModel.fromEntity(task);
    await _localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> markTaskCompleted(int id, bool isCompleted) async {
    await _localDataSource.markTaskCompleted(id, isCompleted);
  }

  @override
  Future<void> createDailyTasks(DateTime date) async {
    // Get all routines
    final routines = await getRoutines();
    if (routines.isEmpty) {
      return; // No routines available
    }

    // For each routine, check if tasks exist for this date, if not create them
    for (final routine in routines) {
      final existingTasksForRoutine = await getTasksByRoutineId(routine.id!);
      final tasksForDate = existingTasksForRoutine.where((task) => 
        task.date.year == date.year && 
        task.date.month == date.month && 
        task.date.day == date.day
      ).toList();

      if (tasksForDate.isEmpty) {
        // Use default tasks if no specific tasks exist
        for (int i = 0; i < AppConstants.defaultRoutineTasks.length; i++) {
          final task = RoutineTask(
            routineId: routine.id!,
            title: AppConstants.defaultRoutineTasks[i],
            order: i,
            date: date,
            createdAt: DateTime.now(),
          );
          await createTask(task);
        }
      }
    }
  }

  @override
  Future<int> getCompletedTasksCount(DateTime date) async {
    final tasks = await getTasksByDate(date);
    return tasks.where((task) => task.isCompleted).length;
  }

  @override
  Future<int> getTotalTasksCount(DateTime date) async {
    final tasks = await getTasksByDate(date);
    return tasks.length;
  }
}
