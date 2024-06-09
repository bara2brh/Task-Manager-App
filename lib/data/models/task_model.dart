class Task {
  final int id;
  final String todo;
  final bool completed;
  final bool isTemporary;

  Task({required this.id, required this.todo, required this.completed, this.isTemporary = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'] ?? false,
      isTemporary: json['isTemporary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'isTemporary': isTemporary,
    };
  }
}
