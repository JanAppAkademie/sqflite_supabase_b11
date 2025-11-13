import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/task.dart';
import '../datasources/local/tasks_local_datasource.dart';
import '../datasources/remote/tasks_remote_datasource.dart';

class TasksRepositoryImpl {
  TasksRepositoryImpl._();
  static final TasksRepositoryImpl instance = TasksRepositoryImpl._();

  final TasksLocalDataSource _local = TasksLocalDataSource.instance;
  final TasksRemoteDataSource _remote = TasksRemoteDataSource.instance;

  Future<List<Task>> fetchAll() async {
    return _local.fetchAll();
  }

  Future<Task> insertTask(Task task) async {
    return _local.insertTask(task);
  }

  Future<void> updateDone({required int id, required bool done}) async {
    await _local.updateDone(id: id, done: done);
  }

  Future<void> deleteById(int id) async {
    try {
      final _ = Supabase.instance.client;
      await _remote.deleteById(id);
    } catch (_) {}
    await _local.deleteById(id);
  }

  Future<void> clearAll() async {
    await _local.clearAll();
  }

  Future<void> syncToRemote() async {
    final _ = Supabase.instance.client;
    final ops = await _local.fetchPendingOps();
    for (final op in ops) {
      final opId = op['op_id'] as int;
      final kind = op['op'] as String;
      final taskId = op['task_id'] as int;
      if (kind == 'upsert') {
        final title = op['title'] as String?;
        final doneInt = op['done'] as int?;
        final done = doneInt == 1;
        if (title != null) {
          await _remote.upsertTask(Task(id: taskId, title: title, done: done));
        }
      } else if (kind == 'delete') {
        await _remote.deleteById(taskId);
      }
      await _local.removePendingOp(opId);
    }
  }
}
