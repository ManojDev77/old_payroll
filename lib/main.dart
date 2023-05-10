import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pay_lea_task/screens/TaskAndAttendance.dart';
import 'package:pay_lea_task/screens/dashboard_leave.dart';
import 'package:pay_lea_task/screens/dashboard_payroll.dart';
import 'package:pay_lea_task/screens/fieldStaffTracker.dart';
import 'package:pay_lea_task/screens/leave_status.dart';
import 'package:pay_lea_task/screens/login.dart';
import 'package:pay_lea_task/screens/onlyTaskManager.dart';
import 'package:pay_lea_task/screens/splashscreen.dart';
import 'package:pay_lea_task/services/firebase_send_notification.dart';
import 'package:pay_lea_task/services/http_override.dart';
import 'package:pay_lea_task/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'binder/binders.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  NotificationService.init(initScheduled: true);
  SendNotification.init();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Payroll',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(elevation: 0.0)),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const MyLoginPage(),
        '/homepagepayroll': (context) => const LandingPagepayroll(),
        '/homepageleave': (context) => LandingPageLeave(),
        '/leavestatus': (context) => const LeaveStatusWidget(
              empvalue: '',
            ),
        '/homepagetaskandattendance': (context) => const TaskandAttendance(),
        '/homepagetaskmanager': (context) => const OnlyTaskManager(),
        '/homefieldstafftracker': (context) => const FieldStaffTracker(),
      },
    );
  }
}
