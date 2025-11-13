import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/task.dart';

class TasksLocalDataSource {
  TasksLocalDataSource._();
  static final TasksLocalDataSource instance = TasksLocalDataSource._();

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_opening != null) return await _opening!;
    _opening = _open()
        .then((db) {
          _db = db;
          return db;
        })
        .whenComplete(() => _opening = null);
    return await _opening!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'tasks.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, done INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE pending_ops ('
          'op_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'op TEXT NOT NULL, '
          'task_id INTEGER NOT NULL, '
          'title TEXT, '
          'done INTEGER, '
          'ts_ms INTEGER NOT NULL'
          ')',
        );
      },
    );
  }

  Future<List<Task>> fetchAll() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'id DESC');
    return rows.map((m) => Task.fromMap(m)).toList();
  }

  Future<Task> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap()..remove('id'));
    final inserted = task.copyWith(id: id);
    await _enqueueUpsert(inserted);
    return inserted;
  }

  Future<void> updateDone({required int id, required bool done}) async {
    final db = await database;
    await db.update(
      'tasks',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    final rows = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await _enqueueUpsert(Task.fromMap(rows.first));
    }
  }

  Future<void> deleteById(int id) async {
    final db = await database;
    await _enqueueDelete(id);
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    final rows = await db.query('tasks', columns: ['id']);
    for (final r in rows) {
      final tid = r['id'] as int?;
      if (tid != null) {
        await _enqueueDelete(tid);
      }
    }
    await db.delete('tasks');
  }

  Future<void> replaceAll(List<Task> newTasks) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      for (final t in newTasks) {
        await txn.insert('tasks', {
          'id': t.id,
          'title': t.title,
          'done': t.done ? 1 : 0,
        });
      }
    });
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await db.close();
  }

  Future<void> _enqueueUpsert(Task task) async {
    final db = await database;
    await db.insert('pending_ops', {
      'op': 'upsert',
      'task_id': task.id,
      'title': task.title,
      'done': task.done ? 1 : 0,
      'ts_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _enqueueDelete(int taskId) async {
    final db = await database;
    await db.insert('pending_ops', {
      'op': 'delete',
      'task_id': taskId,
      'title': null,
      'done': null,
      'ts_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, Object?>>> fetchPendingOps() async {
    final db = await database;
    return db.query('pending_ops', orderBy: 'ts_ms ASC, op_id ASC');
  }

  Future<void> removePendingOp(int opId) async {
    final db = await database;
    await db.delete('pending_ops', where: 'op_id = ?', whereArgs: [opId]);
  }
}


