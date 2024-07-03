import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT,
        value TEXT
      )
      ''',
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    user.forEach((key, value) async {
      await db.insert('user', {'key': key, 'value': value});
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    return {for (var map in maps) map['key']: map['value']};
  }

  Future<int> getUserDataCount() async {
    Database db = await database;
    final int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user'))!;
    return count;
  }

  Future<void> clearUserData() async {
    Database db = await database;
    await db.delete('user');
  }
}
