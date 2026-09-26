import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

import '../data/firebase_auth_repository.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AdminNotifier(repo);
});

class AdminNotifier extends StateNotifier<String?> {
  final FirebaseAuthRepository _repository;

  AdminNotifier(this._repository) : super(null) {
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final admin = await _repository.getAdmin();
    state = admin?.uid;
  }

  Future<void> checkAndSetFirstAdmin(UserModel currentUser) async {
    final hasAdmin = await _repository.hasAdmin();
    if (!hasAdmin) {
      await _repository.setAdmin(currentUser);
      state = currentUser.uid;
    }
  }

  Future<void> transferAdminRights(UserModel newAdmin, UserModel oldAdmin) async {
    await _repository.transferAdmin(oldAdmin, newAdmin);
    state = newAdmin.uid;
  }
}
