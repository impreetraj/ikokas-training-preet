import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database_helper.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      for (var result in results) {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          syncData();
          break;
        }
      }
    });
  }

  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await DatabaseHelper.instance.database;

    final unsyncedTransactions = await db.query(
      'transactions',
      where: 'syncStatus = ?',
      whereArgs: [0],
    );

    for (final txn in unsyncedTransactions) {
      try {
        final data = Map<String, dynamic>.from(txn);
        data.remove('id');
        data.remove('syncStatus');

        final docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(data);

        
        await db.update(
          'transactions',
          {'syncStatus': 1},
          where: 'id = ?',
          whereArgs: [txn['id']],
        );
      } catch (e) {
        print('Error syncing transaction: $e');
      }
    }
  }
}
