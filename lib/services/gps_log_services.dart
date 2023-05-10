import 'dart:io';
import 'package:pay_lea_task/screens/screens.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:intl/intl.dart';
import '../screens/dbhelper.dart';
import '../screens/globals.dart' as globals;
import 'package:http/http.dart' as http;

class GpsLogServices {
  static Future<StreamSubscription<LocationData>?> initPlatformState() async {
    StreamSubscription<LocationData>? streamSubscription;
    if (((globals.isGPS || globals.isleaveGPS) && globals.isEmpGpsOn)) {
      Location location = Location();
      await location.enableBackgroundMode(enable: true);
      bool enabled = FlutterBackground.isBackgroundExecutionEnabled;
      if (!enabled) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: "Payroll",
          notificationText: "Fetching location",
          notificationImportance: AndroidNotificationImportance.Default,
          notificationIcon:
              AndroidResource(name: 'ic_launcher', defType: 'drawable'),
        );
        await FlutterBackground.initialize(androidConfig: androidConfig);
        await FlutterBackground.enableBackgroundExecution();
      }

      streamSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        getlogdetails(currentLocation);
      });
    }
    return streamSubscription;
  }

  static Future getlogdetails(LocationData currentLocation) async {
    print('object');
    Database? db;
    DateTime? currentTime;
    String? updatedDate;
    String? updatedTime;
    final prefs = await SharedPreferences.getInstance();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int timestampNew = 0;
    if (prefs.getInt('myTimestampKey') != null) {
      timestampNew = prefs.getInt('myTimestampKey')!;
    } else {
      timestampNew == -10000;
    }

    int min = 0;
    if (timestampNew != -10000) {
      DateTime before = DateTime.fromMillisecondsSinceEpoch(timestampNew);
      DateTime now = DateTime.now();
      Duration timeDifference = now.difference(before);
      min = timeDifference.inMinutes;
    }

    if (timestampNew == -10000 || min >= 10) {
      currentTime = DateTime.now();

      timestamp = DateTime.now().millisecondsSinceEpoch;
      prefs.setInt('myTimestampKey', timestamp);
      updatedDate = DateFormat('yyyy-MM-dd').format(currentTime);
      updatedTime = DateFormat('HH:mm:ss').format(currentTime);

      try {
        final result = await InternetAddress.lookup('www.google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
      } on SocketException catch (_) {
        Map<String, dynamic> row = {
          DatabaseHelper.columnName: 'OfflineLocation',
          DatabaseHelper.columnLat: currentLocation.latitude,
          DatabaseHelper.columnLong: currentLocation.longitude,
          DatabaseHelper.columnTime: updatedTime,
          DatabaseHelper.columnDate: updatedDate
        };
        await db!.insert(DatabaseHelper.table, row);
      }
      String query =
          '${globals.applictionRootUrl}API/GPSLogDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&Date=$updatedDate&Time=$updatedTime&lat=${currentLocation.latitude}&longitude=${currentLocation.longitude}';
      await http.post(
        Uri.parse(query),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
    }
  }
}
