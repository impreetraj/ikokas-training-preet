import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TransactionModel> insert(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    final map = transaction.toMap();
    map['syncStatus'] = 0; // Default unsynced
    final id = await db.insert('transactions', map);
    
    // Try to sync immediately
    final isOnline = await _isOnline();
    if (isOnline) {
      try {
        final dataToSync = Map<String, dynamic>.from(map);
        dataToSync.remove('id');
        dataToSync.remove('syncStatus');
        await _firestore
            .collection('users')
            .doc(transaction.userId)
            .collection('transactions')
            .add(dataToSync);
        
        await db.update(
          'transactions',
          {'syncStatus': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        // Ignore, will be picked up by SyncService later
      }
    }
    
    return transaction.copyWith(id: id);
  }

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    for (var result in results) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        return true;
      }
    }
    return false;
  }

  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> update(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    final map = transaction.toMap();
    map['syncStatus'] = 0; // Mark as unsynced again
    
    final result = await db.update(
      'transactions',
      map,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );

    // Sync updates if online (Needs a way to identify the exact doc in firestore, 
    // for now we rely on a proper sync mechanism, or just skip immediate update sync for simplicity in this implementation)
    // A robust solution requires storing the firestore document ID in the local SQLite DB.
    
    return result;
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
