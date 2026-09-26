import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'package:ikokas_expense/screens/map_screen.dart';
import 'transaction_logs_screen.dart';
import 'settings_screen.dart';
import '../providers/admin_provider.dart';
import 'admin/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
       backgroundColor: const Color(0xFFF8F9FA),
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Name', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Location', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(user.location ?? 'Not set', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text('Transaction Logs', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionLogsScreen()));
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.settings, color: Colors.blue),
              ),
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.location_on, color: Colors.blue),
              ),
              title: const Text('Maps', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                if (result != null && result is String) {
                  ref.read(authProvider.notifier).updateLocation(result);
                  ref.invalidate(authProvider); 
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location saved successfully!')));
                  }
                }
              },
            ),
            if (ref.watch(adminProvider) == user.uid) ...[
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                ),
                title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                },
              ),
            ],
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Switch Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
            const SizedBox(height: 8),
          
            Consumer(builder: (context, ref, child) {
              return FutureBuilder<List<UserModel>>(
                future: ref.read(authRepositoryProvider).getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox();
                  }
                  final allUsers = snapshot.data!;
                  final otherUsers = allUsers.where((u) => u.uid != user.uid).toList();
                  
                  return Column(
                    children: [
                      ...otherUsers.map((otherUser) => Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Text(otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.teal)),
                            ),
                            title: Text(otherUser.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(otherUser.email),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              ref.read(authProvider.notifier).switchAccount(otherUser);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched to ${otherUser.name}')));
                            },
                          ),
                        ),
                      )),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.add, color: Colors.teal),
                        ),
                        title: const Text('Add Account', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                      ),
                    ],
                  );
                }
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); 
                  ref.read(authProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Colors.red.shade200),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
