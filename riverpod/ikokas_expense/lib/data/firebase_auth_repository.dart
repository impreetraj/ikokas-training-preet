import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:realm/realm.dart';

class FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUserModel;

  UserModel? getCurrentUser() {
    return _currentUserModel;
  }

  Future<UserModel?> fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _currentUserModel = UserModel(
        uid,
        data['name'] ?? '',
        data['email'] ?? '',
        '', // Password not stored locally
      );
      _currentUserModel!.isLoggedIn = true;
      _currentUserModel!.isAdmin = data['isAdmin'] ?? false;
      _currentUserModel!.location = data['location'];
      return _currentUserModel;
    }
    return null;
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final uid = userCredential.user!.uid;

    final newUserModel = UserModel(
      uid,
      name,
      email,
      '', // Don't store password locally
    );
    newUserModel.isLoggedIn = true;

    // Save user info to Firestore
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'isAdmin': false,
      'location': null,
    });

    _currentUserModel = newUserModel;
    return newUserModel;
  }

  Future<UserModel> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final uid = userCredential.user!.uid;
    final userModel = await fetchUserData(uid);
    
    if (userModel == null) {
      throw Exception('User data not found in database.');
    }
    
    return userModel;
  }

  Future<void> logoutUser(UserModel user) async {
    await _auth.signOut();
    _currentUserModel = null;
  }

  Future<void> updateUserLocation(UserModel user, String location) async {
    user.location = location;
    await _firestore.collection('users').doc(user.uid).update({
      'location': location,
    });
  }

  Future<bool> hasAdmin() async {
    final snapshot = await _firestore.collection('users').where('isAdmin', isEqualTo: true).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<UserModel?> getAdmin() async {
    final snapshot = await _firestore.collection('users').where('isAdmin', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      final adminUser = UserModel(
        doc.id,
        data['name'] ?? '',
        data['email'] ?? '',
        '',
      );
      adminUser.isAdmin = true;
      adminUser.location = data['location'];
      return adminUser;
    }
    return null;
  }

  Future<void> setAdmin(UserModel user) async {
    user.isAdmin = true;
    await _firestore.collection('users').doc(user.uid).update({
      'isAdmin': true,
    });
  }

  Future<void> transferAdmin(UserModel oldAdmin, UserModel newAdmin) async {
    oldAdmin.isAdmin = false;
    newAdmin.isAdmin = true;
    
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(oldAdmin.uid), {'isAdmin': false});
    batch.update(_firestore.collection('users').doc(newAdmin.uid), {'isAdmin': true});
    await batch.commit();
  }

  Future<List<UserModel>> getAllOtherUsers(String currentUserId) async {
    final snapshot = await _firestore.collection('users').where('uid', isNotEqualTo: currentUserId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final user = UserModel(
        doc.id,
        data['name'] ?? '',
        data['email'] ?? '',
        '',
      );
      user.isAdmin = data['isAdmin'] ?? false;
      user.location = data['location'];
      return user;
    }).toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final user = UserModel(
        doc.id,
        data['name'] ?? '',
        data['email'] ?? '',
        '',
      );
      user.isAdmin = data['isAdmin'] ?? false;
      user.location = data['location'];
      return user;
    }).toList();
  }
}
