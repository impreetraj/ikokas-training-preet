import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';

class TodoController extends StateNotifier<List<Todo>> {
  final TodoRepository _repository;

  TodoController(this._repository) : super([]) {
    _loadTodos();
  }

  
  Future<void> _loadTodos() async {
    final todos = await _repository.getAllTodos();
    state = todos;
  }

  
  Future<void> addTodo(String title, String description) async {
    final newTodo = Todo(
      title: title,
      description: description,
    );
    
    await _repository.insert(newTodo);
    await _loadTodos(); 
  }

  
  Future<void> updateTodo(Todo updatedTodo) async {
    await _repository.update(updatedTodo);
    await _loadTodos(); 
  }



  Future<void> deleteTodo(int id) async {
    await _repository.delete(id);
    await _loadTodos(); // Refresh state after deleting
  }
}
