class Task {
  const Task({this.id, required this.title, required this.done});

  final int? id;
  final String title;
  final bool done;

  Task copyWith({int? id, String? title, bool? done}) => Task(
        id: id ?? this.id,
        title: title ?? this.title,
        done: done ?? this.done,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'done': done ? 1 : 0,
      };

  static Task fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int?,
        title: m['title'] as String,
        done: (m['done'] as int) == 1,
      );
}


