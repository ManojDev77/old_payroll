// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'package:payroll/screens/globals.dart' as globals;
// import 'package:http/http.dart' as http;
// import 'package:payroll/services/notification_custom.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter/material.dart';

// class GeoLocationService {
//   checkPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     LocationSettings locationSettings;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Fluttertoast.showToast(
//           msg: "Location Service Is Disabled",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 3,
//           backgroundColor: Colors.white,
//           textColor: Colors.black,
//           fontSize: 13.0);
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Fluttertoast.showToast(
//             msg: "Location Permission Denied",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 3,
//             backgroundColor: Colors.white,
//             textColor: Colors.black,
//             fontSize: 13.0);
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(
//           msg: "Location Permission Denied Forever",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 3,
//           backgroundColor: Colors.white,
//           textColor: Colors.black,
//           fontSize: 13.0);
//     }
//     locationSettings = AndroidSettings(
//       accuracy: LocationAccuracy.high,
//       forceLocationManager: true,
//       intervalDuration: const Duration(seconds: 60),
//     );

//     Geolocator.getPositionStream(locationSettings: locationSettings)
//         .listen((Position position) {
//       print(position == null
//           ? 'Unknown'
//           : '${position.latitude.toString()}, ${position.longitude.toString()}');
//       NotificationService.showNotification(
//           3, "Gps Log", "Gps Location Logged", "n");
//     });
//   }

//   // static setGpsLog(Position _locationData) async {
//   //   // Position _locationData = await Geolocator.getCurrentPosition(
//   //   //     desiredAccuracy: LocationAccuracy.best);

//   //   DateTime now = DateTime.now();
//   //   String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//   //   String formattedTime = DateFormat('HH:mm:ss').format(now);
//   //   String query = globals.applictionRootUrl +
//   //       'API/GPSLogDetails?DBName=' +
//   //       globals.databaseName +
//   //       '&UserId=' +
//   //       "${globals.userId}" +
//   //       '&Date=' +
//   //       formattedDate +
//   //       '&Time=' +
//   //       formattedTime +
//   //       '&lat=' +
//   //       (_locationData.latitude.toString() ?? "0.0") +
//   //       '&longitude=' +
//   //       (_locationData.longitude.toString() ?? "0.0");
//   //   final http.Response response = await http.post(
//   //     Uri.parse(query),
//   //     headers: <String, String>{
//   //       'Content-Type': 'application/x-www-form-urlencoded',
//   //     },
//   //   );
//   //   if (response.statusCode == 200) {
//   //     print('Gps  Location Fetched');
//   //     NotificationService.showNotification(
//   //         3, "Gps Log", "Gps Location Logged", "n");
//   //   }
//   // }
// }
