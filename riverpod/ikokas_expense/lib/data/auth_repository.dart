/*
import 'package:realm/realm.dart';
import '../models/user_model.dart';

class AuthRepository {
  late Realm _realm;

  AuthRepository() {
    final config = Configuration.local([UserModel.schema], schemaVersion: 1);
    _realm = Realm(config);
  }

  UserModel? getCurrentUser() {
    return _realm.all<UserModel>().where((u) => u.isLoggedIn).firstOrNull;
  }

  List<UserModel> getAllUsers() {
    return _realm.all<UserModel>().where((u) => u.isLoggedIn).toList();
  }

  List<UserModel> getAllOtherUsers(String currentUserId) {
    return _realm.all<UserModel>().where((u) => u.uid != currentUserId).toList();
  }

  
  Future<UserModel> signUp(String name, String email, String password) async {
    
    final existingUser = _realm.all<UserModel>().where((u) => u.email == email).firstOrNull;
    if (existingUser != null) {
      throw Exception('Email already exists');
    }

    final newUser = UserModel(
      ObjectId().hexString,
      name,
      email,
      password,
    );

    _realm.write(() {
      _realm.add(newUser);
    });

    return newUser;
  }

  
  Future<UserModel> login(String email, String password) async {
    final user = _realm.all<UserModel>().where((u) => u.email == email && u.password == password).firstOrNull;
    
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    
    _realm.write(() {
      user.isLoggedIn = true;
    });
    
    return user;
  }

  void logoutUser(UserModel user) {
    _realm.write(() {
      user.isLoggedIn = false;
    });
  }

  void updateUserLocation(UserModel user, String location) {
    _realm.write(() {
      user.location = location;
    });
  }

  bool hasAdmin() {
    return _realm.all<UserModel>().where((u) => u.isAdmin == true).isNotEmpty;
  }

  UserModel? getAdmin() {
    return _realm.all<UserModel>().where((u) => u.isAdmin == true).firstOrNull;
  }

  void setAdmin(UserModel user) {
    _realm.write(() {
      user.isAdmin = true;
    });
  }

  void transferAdmin(UserModel oldAdmin, UserModel newAdmin) {
    _realm.write(() {
      oldAdmin.isAdmin = false;
      newAdmin.isAdmin = true;
    });
  }

  void close() {
    _realm.close();
  }
}
*/
