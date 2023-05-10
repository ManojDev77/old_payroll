import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesTest {
  ///
  /// Instantiation of the SharedPreferences library
  ///

  /// ------------------------------------------------------------
  /// Method that returns the user decision to allow notifications
  /// ------------------------------------------------------------
  Future<bool> getBoolExtra(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(name) ?? false;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision to allow notifications
  /// ----------------------------------------------------------
  Future<bool> setBoolExtra(String name, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(name, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the user decision on sorting order
  /// ------------------------------------------------------------
  Future<String> getStringExtra(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(name) ?? 'name';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision on sorting order
  /// ----------------------------------------------------------
  Future<bool> setStringExtra(String name, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(name, value);
  }

  Future<int> getIntExtra(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(name) ?? 0;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision on sorting order
  /// ----------------------------------------------------------
  Future<bool> setIntExtra(String name, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(name, value);
  }
}
