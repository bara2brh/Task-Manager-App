import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/models/task_model.dart';

class LocalStorageService {
  final SharedPreferences _preferences;

  LocalStorageService(this._preferences);

  Future<void> saveTasks(List<Task> tasks, int userId) async {
    final taskJsonList = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _preferences.setStringList('tasks_$userId', taskJsonList);
  }

  Future<List<Task>> loadTasks(int userId) async {
    final taskJsonList = _preferences.getStringList('tasks_$userId');
    if (taskJsonList == null) return [];

    return taskJsonList.map((taskJson) => Task.fromJson(jsonDecode(taskJson))).toList();
  }

  Future<void> clearTasks(int userId) async {
    await _preferences.remove('tasks_$userId');
  }
}
