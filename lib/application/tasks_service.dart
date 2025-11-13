import '../domain/entities/task.dart';
import '../data/repositories/tasks_repository_impl.dart';

class TasksService {
  TasksService._();
  static final TasksService instance = TasksService._();

  final TasksRepositoryImpl _repo = TasksRepositoryImpl.instance;

  Future<List<Task>> fetchAll() => _repo.fetchAll();

  Future<Task> insertTask(Task task) => _repo.insertTask(task);

  Future<void> updateDone({required int id, required bool done}) =>
      _repo.updateDone(id: id, done: done);

  Future<void> deleteById(int id) => _repo.deleteById(id);

  Future<void> clearAll() => _repo.clearAll();

  Future<void> syncToRemote() => _repo.syncToRemote();
}
