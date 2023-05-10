import 'dart:io' show Directory;
import '../screens/locationmodel.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class DatabaseHelper {
  static const _databaseName = "LocationOffline.db";
  static const _databaseVersion = 1;

  static const table = 'location';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnLat = 'lat';
  static const columnLong = 'long';
  static const columnTime = 'time';
  static const columnDate = 'date';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnLat TEXT NOT NULL,
            $columnLong TEXT NOT NULL,
            $columnTime TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
  }

  Future<List<LocationModal>> getAllLocationData() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM location ');
    List<LocationModal> list =
        res.isNotEmpty ? res.map((c) => LocationModal.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.rawDelete('DELETE  FROM location ');
  }
}
