import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'admin_user_details_screen.dart';
import 'admin_transfer_dialog.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    
    return FutureBuilder<List<UserModel>>(
      future: authRepo.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allUsers = snapshot.data ?? [];
        
        final Map<String, List<UserModel>> groupedUsers = {};
        for (var user in allUsers) {
          final loc = user.location ?? 'Not Set';
          if (!groupedUsers.containsKey(loc)) {
            groupedUsers[loc] = [];
          }
          groupedUsers[loc]!.add(user);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Transfer Admin Rights',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AdminTransferDialog(allUsers: allUsers),
                  );
                },
              )
            ],
          ),
          body: groupedUsers.isEmpty
              ? const Center(child: Text('No users found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedUsers.keys.length,
                  itemBuilder: (context, index) {
                    final location = groupedUsers.keys.elementAt(index);
                    final usersInLocation = groupedUsers[location]!;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade50,
                          child: const Icon(Icons.location_on, color: Colors.purple),
                        ),
                        title: Text(
                          location,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${usersInLocation.length} user(s)'),
                        children: usersInLocation.map((u) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Text(
                                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.teal),
                              ),
                            ),
                            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(u.email),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminUserDetailsScreen(targetUser: u),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
