import 'package:flutter/material.dart';
import 'package:sqflite_supabase_b11/application/tasks_service.dart';
import 'package:sqflite_supabase_b11/domain/entities/task.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do Hive',
      theme: ThemeData.light(useMaterial3: true),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final c = TextEditingController();
  final tasks = ValueNotifier<List<Task>>(<Task>[]);
  final service = TasksService.instance;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final all = await service.fetchAll();
    tasks.value = all;
  }

  Future<void> _add() async {
    final text = c.text.trim();
    if (text.isEmpty) return;
    await service.insertTask(Task(title: text, done: false));
    c.clear();
    await _reload();
  }

  Future<void> _toggle(int i) async {
    final current = tasks.value;
    if (i < 0 || i >= current.length) return;
    final t = current[i];
    if (t.id == null) return;
    await service.updateDone(id: t.id!, done: !t.done);
    await _reload();
  }

  Future<void> _delete(int i) async {
    final current = tasks.value;
    if (i < 0 || i >= current.length) return;
    final t = current[i];
    if (t.id == null) return;
    await service.deleteById(t.id!);
    await _reload();
  }

  Future<void> _clear() async {
    await service.clearAll();
    await _reload();
  }

  Future<void> _sync() async {
    try {
      await service.syncToRemote();
      print('Synced to Supabase');
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          IconButton(onPressed: _sync, icon: const Icon(Icons.sync)),
          IconButton(onPressed: _clear, icon: const Icon(Icons.delete_sweep)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: c,
                    decoration: const InputDecoration(
                      labelText: 'Add a task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _add, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Task>>(
              valueListenable: tasks,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return const Center(child: Text('No tasks'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final t = list[i];
                    return ListTile(
                      leading: Checkbox(
                        value: t.done,
                        onChanged: (_) => _toggle(i),
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          decoration: t.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(i),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
