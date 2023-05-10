import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String messageTitle = "Empty";
  String notificationAlert = "alert";
  String nextpage = "";

  @override
  void initState() {
    getApplicationRootUrl();
    super.initState();
  }

  Future getApplicationRootUrl() async {
    Timer(const Duration(seconds: 3), () => _checkalreadylogin());
  }

  void _checkalreadylogin() async {
    final prefs = await SharedPreferences.getInstance();
    int shrduserId = prefs.getInt('UserId') ?? 0;
    bool? shrdloggedin = prefs.getBool("IsLoggedIn");

    bool isEmployee = prefs.getBool("isEmployee") ?? false;
    globals.isEmployee = isEmployee;
    // bool isLeave = prefs.getBool("isLeave");
    bool isLeave = prefs.getBool("isLeave") ?? false;

    bool isempdetailson = prefs.getBool("isEmpCnt") ?? false;

    int? ispayrollog = prefs.getInt("payroll") ?? 0;
    bool isAttendance = prefs.getBool("isAttendance") ?? false;
    bool isGPS = prefs.getBool("isGPS") ?? false;
    bool isSublogin = prefs.getBool("isSublogin") ?? false;
    // Object? subMasterID =
    //     prefs.getInt("subMasterID") == null ? 0 : prefs.getBool("subMasterID");
    // globals.subMasterID = subMasterID;

    String? shrddatabasename = prefs.getString("DatabaseName");
    if (shrduserId != 0 && shrddatabasename != '') {
      globals.userId = shrduserId;
      globals.databaseName = shrddatabasename!;
      globals.isLoggedIn = true;
      globals.isLeave = isLeave;
      globals.isempcontactenabled = isempdetailson;
      globals.payroll = ispayrollog;
      globals.isAttendance = isAttendance;
      globals.isGPS = isGPS;
      globals.isSublogin = isSublogin;
      if (globals.payroll == 2) {
        Get.offAllNamed('/homepagepayroll');
      } else if (globals.payroll == 5) {
        Get.offAllNamed('/homepageleave');
      } else if (globals.payroll == 29) {
        Get.offAllNamed('/homepagetaskandattendance');
      } else if (globals.payroll == 27) {
        Get.offAllNamed('/homepagetaskmanager');
      } else {
        Get.offAllNamed('/homefieldstafftracker');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'assets/office_anywhere_logo_black.png',
              height: 300,
              width: 300,
            ),
          ),
          Positioned(
              width: MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height - 100,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/gaamma_logo.jpg', scale: 3.0),
                    ]),
              ))
        ],
      ),
    );
  }
}
