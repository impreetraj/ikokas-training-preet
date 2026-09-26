import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';

class TodoRepository {
  final DbHelper _dbHelper = DbHelper.instance;

  
  Future<int> insert(Todo todo) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DbHelper.table,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Todo>> getAllTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DbHelper.table);

    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // Update a Todo
  Future<int> update(Todo todo) async {
    final db = await _dbHelper.database;
    return await db.update(
      DbHelper.table,
      todo.toMap(),
      where: '${DbHelper.columnId} = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete a Todo
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DbHelper.table,
      where: '${DbHelper.columnId} = ?',
      whereArgs: [id],
    );
  }
}
