import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    
    try {
      await db.execute('ALTER TABLE transactions ADD COLUMN paymentSlipPath TEXT');
    } catch (e) {
      
    }

    try {
      await db.execute('ALTER TABLE transactions ADD COLUMN syncStatus INTEGER DEFAULT 0');
    } catch (e) {
      
    }

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transaction_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionId INTEGER NOT NULL,
          action TEXT NOT NULL,
          previousData TEXT,
          newData TEXT,
          timestamp TEXT NOT NULL,
          logStatus TEXT NOT NULL
        )
      ''');
    } catch (e) {
      
    }

    return db;
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const numType = 'REAL NOT NULL';
    const textNullableType = 'TEXT';

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  userId $textType,
  title $textType,
  amount $numType,
  date $textType,
  category $textType,
  type $textType,
  paymentMethod $textType,
  notes $textNullableType,
  isShared INTEGER DEFAULT 0,
  sharedBy TEXT,
  paymentSlipPath $textNullableType,
  syncStatus INTEGER DEFAULT 0
)
''');
  }

    Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
