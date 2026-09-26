import 'package:sqflite/sqflite.dart';
import '../models/transaction_log_model.dart';
import 'database_helper.dart';

class TransactionLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<TransactionLogModel> insertLog(TransactionLogModel log) async {
    final db = await _dbHelper.database;
    final id = await db.insert('transaction_logs', log.toMap());
    return log.copyWith(id: id);
  }

  Future<List<TransactionLogModel>> getLogsForTransaction(int transactionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transaction_logs',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TransactionLogModel.fromMap(map)).toList();
  }

  Future<List<TransactionLogModel>> getAllLogs() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transaction_logs',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TransactionLogModel.fromMap(map)).toList();
  }
}
