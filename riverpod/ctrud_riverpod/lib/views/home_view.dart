import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import 'add_edit_todo_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final todos = ref.watch(todoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crud riverpod'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text(
                'No crud yet. Add one!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Dismissible(
                  key: Key(todo.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    
                    ref.read(todoControllerProvider.notifier).deleteTodo(todo.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${todo.title} deleted')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(todo.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditTodoView(todo: todo),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref.read(todoControllerProvider.notifier).deleteTodo(todo.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${todo.title} deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTodoView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
