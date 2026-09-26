import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminTransferDialog extends ConsumerWidget {
  final List<UserModel> allUsers;

  const AdminTransferDialog({Key? key, required this.allUsers}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final otherUsers = allUsers.where((u) => u.uid != currentUser?.uid).toList();

    return AlertDialog(
      title: const Text('Transfer Admin Rights'),
      content: SizedBox(
        width: double.maxFinite,
        child: otherUsers.isEmpty
            ? const Text('No other users available to transfer rights to.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: otherUsers.length,
                itemBuilder: (context, index) {
                  final user = otherUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    onTap: () {
                      _confirmTransfer(context, ref, user, currentUser);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _confirmTransfer(BuildContext context, WidgetRef ref, UserModel targetUser, UserModel? currentUser) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Text('Are you sure you want to transfer admin rights to ${targetUser.name}? You will lose admin access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(adminProvider.notifier).transferAdminRights(targetUser, currentUser!);
              if (context.mounted) {
                // Pop confirm dialog
                Navigator.pop(ctx);
                // Pop transfer dialog
                Navigator.pop(context);
                // Pop Admin Dashboard to return to Profile
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Admin rights transferred to ${targetUser.name}')),
                );
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}
