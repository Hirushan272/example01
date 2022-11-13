import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;
  Database? get database => _database;

  Future<void> createDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = "$databasesPath/demo.db";

    _database = await openDatabase(path);
  }
}
