import 'package:dio/dio.dart';
import '../../../data/models/task_model.dart';

class TaskListResult {
  final List<Task> tasks;
  final int totalTasks;

  TaskListResult({required this.tasks, required this.totalTasks});
}

class TaskRepository {
  final Dio _dio;

  TaskRepository(this._dio);

  Future<TaskListResult> fetchTasks({required int userId, required int limit, required int skip}) async {
    final response = await _dio.get('https://dummyjson.com/todos/user/$userId', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    final data = response.data['todos'] as List;
    final tasks = data.map((taskJson) => Task.fromJson(taskJson)).toList();
    final totalTasks = response.data['total'] as int;
    return TaskListResult(tasks: tasks, totalTasks: totalTasks);
  }

  Future<int> fetchTotalTasks() async {
    final response = await _dio.get('https://dummyjson.com/todos');
    return response.data['total'] as int;
  }

  Future<Task> addTask(String todo, int userId) async {
    final response = await _dio.post('https://dummyjson.com/todos/add', data: {
      'todo': todo,
      'userId': userId,
    });
    return Task.fromJson(response.data);
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete('https://dummyjson.com/todos/$id');
  }

  Future<Task> updateTask(int id, String todo, bool completed) async {
    final response = await _dio.put('https://dummyjson.com/todos/$id', data: {
      'todo': todo,
      'completed': completed,
    });
    return Task.fromJson(response.data);
  }
}
