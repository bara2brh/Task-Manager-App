import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/models/task_model.dart';

class DatabaseHelper {
  late Database _database;

  DatabaseHelper() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'tasks_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, todo TEXT, completed INTEGER, isTemporary INTEGER, userId INTEGER)',
        );
      },

      version: 1,
    );
  }

  Future<void> insertTask(Task task, int userId) async {
    await _database.insert(
      'tasks',
      task.toJson()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks(int userId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        todo: maps[i]['todo'],
        completed: maps[i]['completed'] == 1,
      );
    });
  }

  Future<void> updateTask(Task task) async {
    await _database.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
