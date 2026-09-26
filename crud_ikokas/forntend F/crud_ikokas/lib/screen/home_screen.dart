import 'package:crud_ikokas/bloc/crud_bloc.dart';
import 'package:crud_ikokas/bloc/crud_event.dart';
import 'package:crud_ikokas/bloc/crud_state.dart';
import 'package:crud_ikokas/model/crud_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAddEditDialog({CrudModel? crud}) {
    final nameController = TextEditingController(text: crud?.name ?? '');
    final titleController = TextEditingController(text: crud?.title ?? '');
    final descController = TextEditingController(text: crud?.description ?? '');
    final isEdit = crud != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Item' : 'Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCrud = CrudModel(
                  name: nameController.text,
                  title: titleController.text,
                  description: descController.text,
                );
                if (isEdit) {
                  context.read<CrudBloc>().add(updateCrud(id: crud.sId!, crud: newCrud));
                } else {
                  context.read<CrudBloc>().add(createCrud(crud: newCrud));
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD ikokas'),
        centerTitle: true,
      ),
      body: BlocBuilder<CrudBloc, CrudState>(
        builder: (context, state) {
          if (state is CrudloadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CrudErrorState) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is CrudLoadedState) {
            if (state.cruds.isEmpty) {
              return const Center(child: Text('No items found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.cruds.length,
              itemBuilder: (context, index) {
                final item = state.cruds[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(item.title ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${item.name ?? 'No Name'}'),
                        const SizedBox(height: 4),
                        Text(item.description ?? 'No Description'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(crud: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (item.sId != null) {
                              context.read<CrudBloc>().add(deleteCrud(id: item.sId!));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Initialize'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}