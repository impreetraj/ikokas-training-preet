import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';
import '../controllers/todo_controller.dart';


final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});


final todoControllerProvider = StateNotifierProvider<TodoController, List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoController(repository);
});
