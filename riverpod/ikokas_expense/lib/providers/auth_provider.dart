import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../data/firebase_auth_repository.dart';
import 'admin_provider.dart';

final authRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});


final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final FirebaseAuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(_repository.getCurrentUser()) {
    if (state != null) {
      _checkAdmin(state!);
    }
  }

  void _checkAdmin(UserModel user) {
    _ref.read(adminProvider.notifier).checkAndSetFirstAdmin(user);
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _repository.login(email, password);
      _checkAdmin(user);
      state = user; 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      final user = await _repository.signUp(name, email, password);
      _checkAdmin(user);
      state = user; 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (state == null) return;
    
    await _repository.logoutUser(state!);
    
    // In Firebase auth, usually only one user is logged in at a time on the device, 
    // unless you implement multi-account. For now, just set to null.
    state = null;
  }

  void switchAccount(UserModel user) {
    state = user;
  }

  Future<List<UserModel>> getAllOtherUsers() async {
    if (state == null) return [];
    return await _repository.getAllOtherUsers(state!.uid);
  }

  Future<void> updateLocation(String location) async {
    if (state == null) return;
    await _repository.updateUserLocation(state!, location);
    state = _repository.getCurrentUser();
  }
}
