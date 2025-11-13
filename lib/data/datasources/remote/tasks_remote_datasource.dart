import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/task.dart';

class TasksRemoteDataSource {
  TasksRemoteDataSource._();

  static final TasksRemoteDataSource instance = TasksRemoteDataSource._();

  SupabaseClient get _client => Supabase.instance.client;

  String get _table => 'tasks';

  Future<List<Task>> fetchAll() async {
    final rows = await _client
        .from(_table)
        .select('*')
        .order('id', ascending: false);
    final list = (rows as List)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (m) => Task(
            id: m['id'] as int?,
            title: m['title'] as String,
            done: (m['done'] as bool?) ?? false,
          ),
        )
        .toList();
    return list;
  }

  Future<void> upsertTask(Task task) async {
    await _client.from(_table).upsert(<String, dynamic>{
      'id': task.id,
      'title': task.title,
      'done': task.done,
    });
  }

  Future<Task> insertTask(Task task) async {
    final data = await _client
        .from(_table)
        .insert(<String, dynamic>{'title': task.title, 'done': task.done})
        .select()
        .single();
    return Task(
      id: data['id'] as int?,
      title: data['title'] as String,
      done: (data['done'] as bool?) ?? false,
    );
  }

  Future<void> updateDone({required int id, required bool done}) async {
    await _client
        .from(_table)
        .update(<String, dynamic>{'done': done})
        .eq('id', id);
  }

  Future<void> deleteById(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> clearAll() async {
    await _client.from(_table).delete();
  }
}
