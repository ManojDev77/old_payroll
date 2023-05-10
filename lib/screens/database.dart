import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'loginmodel.dart';

// This file has a number of platform-agnostic non-Widget utility functions.
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "PTCDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE LoginProfile ("
          "loginid INTEGER PRIMARY KEY,"
          "appid INTEGER,"
          "emaild TEXT,"
          "databasename TEXT,"
          "isdefault BIT"
          ")");
    });
  }

  newLogin(LoginProfile newLogin) async {
    final db = await database;
    var res = await db.rawInsert(
        "INSERT Into LoginProfile (loginid,appid,emaild,databasename,isdefault)"
        " VALUES (${newLogin.loginid},${newLogin.appid},${newLogin.emaild},${newLogin.databasename},${newLogin.isdefault})");
    return res;
  }

  newLoginProfile(LoginProfile newLogin) async {
    final db = await database;

    db.rawDelete("update LoginProfile set isdefault='false'");
    var res = await db.insert("LoginProfile", newLogin.toMap());
    return res;
  }

  newLoginProfileInsert(LoginProfile newLogin) async {
    final db = await database;
    //get the biggest id in the table
    var table =
        await db.rawQuery("SELECT MAX(loginid)+1 as id FROM LoginProfile");
    Object? id = table.first["loginid"];
    //insert to the table using the new id

    db.rawDelete("update LoginProfile set isdefault='false'");
    var raw = await db.rawInsert(
        "INSERT Into LoginProfile (loginid,appid,emaild,databasename,isdefault)"
        " VALUES (?,?,?,?,?)",
        [
          id,
          newLogin.appid,
          newLogin.emaild,
          newLogin.databasename,
          newLogin.isdefault
        ]);
    return raw;
  }

  getLoginProfile(int id) async {
    final db = await database;
    var res =
        await db.query("LoginProfile", where: "loginid = ?", whereArgs: [id]);
    return res.isNotEmpty ? LoginProfile.fromMap(res.first) : Null;
  }

  Future<List<LoginProfile>> getAllLoginProfile() async {
    final db = await database;
    var res = await db.query("LoginProfile");
    List<LoginProfile> list =
        res.isNotEmpty ? res.map((c) => LoginProfile.fromMap(c)).toList() : [];
    return list;
  }

  updateLoginProfile(LoginProfile login) async {
    final db = await database;
    var res = await db.update("LoginProfile", login.toMap(),
        where: "loginid = ?", whereArgs: [login.loginid]);
    return res;
  }

  updateDefaultLogin(LoginProfile login) async {
    final db = await database;
    LoginProfile defaultLogin = LoginProfile(
        loginid: login.loginid,
        appid: login.appid,
        emaild: login.emaild,
        databasename: login.databasename,
        isdefault: true);

    db.rawDelete("update LoginProfile set isdefault='false'");
    var res = await db.update("LoginProfile", defaultLogin.toMap(),
        where: "loginid = ?", whereArgs: [login.loginid]);
    return res;
  }

  deleteLogin(int id) async {
    final db = await database;
    db.delete("LoginProfile", where: "loginid = ?", whereArgs: [id]);
  }
}

class LoginProfileBloc {
  LoginProfileBloc() {
    getAllLogins();
  }
  final _clientController = StreamController<List<LoginProfile>>.broadcast();
  get clients => _clientController.stream;

  dispose() {
    _clientController.close();
  }

  getAllLogins() async {
    _clientController.sink.add(await DBProvider.db.getAllLoginProfile());
  }
}
