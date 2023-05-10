import 'package:badges/badges.dart' as Badge;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:flutter/material.dart';
import 'package:pay_lea_task/screens/attendance_recorder.dart';
import 'package:pay_lea_task/screens/salary_details.dart';
import 'package:pay_lea_task/screens/upcoming_holidays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gps_log_services.dart';
import '../services/notification_service.dart';
import 'AdEmpMeeting.dart';
import 'EmployeeList.dart';
import 'EmployeeListLogDetails.dart';
import 'TaskAndAttendance.dart';
import 'all_employee_details.dart';
import 'approveList.dart';
import 'assignemployee.dart';
import 'attendance_recorder.dart' as attendance;
import 'attendance_without_loc.dart';
import 'calendar_view.dart';
import 'circular_employee.dart';
import 'dashboard_leave.dart';
import 'database.dart';
import 'delete_account_page.dart';
import 'fieldStaffTracker.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

import 'package:progress_dialog/progress_dialog.dart';
import '../sharedpreferences.dart' as sharedpreferences;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'leave_approve_request.dart';

import 'login.dart';
import 'loginmodel.dart';
import 'onlyTaskManager.dart';

const _myListOfRandomColors = [
  Colors.red,
  Colors.blue,
  Colors.teal,
  Colors.amber,
  Colors.deepOrange,
  Colors.green,
  Colors.indigo,
  Colors.pink,
  Colors.orange,
  Colors.purple,
  Colors.brown,
];
ProgressDialog? pr;

final _random = Random();
List<Color> colors = [];
List<DropdownMenuItem<String>> companyDropdownitems = [];
GlobalKey<ScaffoldState> _homepagescaffoldKey = GlobalKey<ScaffoldState>();
sharedpreferences.SharedPreferencesTest sharedpref =
    sharedpreferences.SharedPreferencesTest();
attendance.AttendanceRecorderWidgetState attdnc =
    attendance.AttendanceRecorderWidgetState();
List<AppListModel> applist = [];
List<LoginProfile> loginList = [];
String companydropdownValue = '';
String appdropdownValue = '';
String empName = '';
String empCode = '';
String empDesignation = '';
String empDepartment = '';
String empDOJ = '';
bool isEmpAttendanceOn = false;
bool isEmpSubLoginOn = false;
bool isEmpGpsOn = false;
bool notloaded = false;
bool notigorejected = false;
List listrejected = [];
List circular = [];
List<NoticeModal> mainNoticeList = [];
List<LeaveApproveModel> mainLeaveList = [];
List<LeaveApproveModel> allmainLeaveList = [];
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
int payrollwidgetcnt = 0;
int widgetcnt = 0;

class LandingPagepayroll extends StatelessWidget {
  const LandingPagepayroll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BuildLandingPage(),
    );
  }
}

class BuildLandingPage extends StatelessWidget {
  const BuildLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(""),
        elevation: 0,
        toolbarHeight: 50,
      ),
      drawer: _AndroidDrawer(),
      body: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoaded = false;
  int employeeCount = 0;
  int holyInMonth = 0;
  int newlyJoined = 0;
  int leftEmployee = 0;
  int leaveRqstCount = 0;
  int todayLeave = 0;
  int upLeaveCount = 0;
  int pendingDocRqstCount = 0;
  String nextpage = '';
  List values = [];
  List valueslogin = [];
  Duration? logouttime;
  String? logintimedisp;
  String? logouttimedisp;
  List list = [];
  int notreadcount = 0;
  int leaveleftapprovecnt = 0;
  bool isempcircularseen = false;
  String monthValue = "";
  List<DropdownMenuItem<String>> monthList = [];
  @override
  void initState() {
    refreshData();
    // checkForUpdate();
    loadLoginProfiles();
    super.initState();
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("")));
        });
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("")));
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  _checkforApprover() async {
    String query =
        '${globals.applictionRootUrl}API/CheckApprover?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      globals.isapprover = list;
    }
  }

  Future<void> noticelog() async {
    if (globals.isEmployee) {
      notreadcount = 0;
      String query =
          '${globals.applictionRootUrl}API/NoticeDetailsEmpView?DBName=${globals.databaseName}&UserId=${globals.userId}';
      final http.Response response = await http.post(
        Uri.parse(query),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        var jobject = jsonDecode(response.body.toString());
        var list = jobject["NoticeDetailsList"];
        var mainListNoti = list.map((e) => NoticeModal.fromJson(e)).toList();
        if (mounted) {
          mainNoticeList = List<NoticeModal>.from(mainListNoti);
          for (int i = 0; i < mainNoticeList.length; i++) {
            if (mainNoticeList[i].isread == false) {
              notreadcount++;
            }
          }
        }
        setState(() {
          notreadcount;
        });
      }
    }

    if (globals.isapprover) {
      leaveleftapprovecnt = 0;
      List<LeaveApproveModel> leaveList = [];
      String query2 =
          '${globals.applictionRootUrl}API/GetLeaveRequestList?DBName=${globals.databaseName}&userId=${globals.userId}';
      final http.Response response2 = await http.post(
        Uri.parse(query2),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response2.statusCode == 200) {
        var jobject = jsonDecode(response2.body.toString());
        var list = jobject;
        var mainList = list.map((e) => LeaveApproveModel.fromJson(e)).toList();
        if (mounted) {
          allmainLeaveList = List<LeaveApproveModel>.from(mainList);
          mainLeaveList =
              allmainLeaveList.where((element) => element.status == 1).toList();
          leaveList = mainLeaveList;
          setState(() {
            leaveleftapprovecnt = leaveList.length;
          });
        }
      }
    }
  }

  showDialogIfFirstLoaded() async {
    Location location = Location();
    if (!globals.isWithoutLocationEnabled) {
      PermissionStatus permissionGranted;
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }
  }

  void _checkloginlogoutnoti() async {
    final prefs = await SharedPreferences.getInstance();

    var format = DateFormat("HH:mm");
    var one = format.parse(prefs.getString('logintime')!);

    var two = format.parse("00:10");
    valueslogin = (one.difference(two).toString()).split(":");

    var now = DateTime.now();

    var dateFormat = DateFormat("h:mm a");
    logintimedisp = dateFormat.format(DateTime(now.year, now.month, now.day,
        int.parse(valueslogin[0]), int.parse(valueslogin[1])));

    NotificationService.showNotificationSchedule(
        id: 2,
        title: 'Login Alert',
        body: 'Login Reminder',
        payload: 'Login',
        scheduleDate: DateTime(now.year, now.month, now.day,
            int.parse(valueslogin[0]), int.parse(valueslogin[1]), 00));
  }

  Future _getuserRole() async {
    String query =
        '${globals.applictionRootUrl}API/GetUserRole?DBName=${globals.databaseName}&userId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var role = jobject;

      if (role.toString() == "2") {
        globals.isEmployee = true;
        sharedpref.setBoolExtra("isEmployee", true);
      } else {
        globals.isEmployee = false;
        sharedpref.setBoolExtra("isEmployee", false);
      }
    }
  }

  Future<void> refreshData() async {
    if (mounted) {
      setState(() {
        isLoaded = false;
      });

      await _getuserRole();
      await noticelog();
      await _getSettingsDetailspayroll();
      await _getSettingsDetailsleave();
      if (globals.isEmployee) {
        await _checkforApprover();
      }
      await _getDashboardData();

      if (mounted) {
        setState(() {
          isLoaded = true;
        });
      }

      if (globals.isEmpAttendanceOn &&
          (globals.isGPS || globals.isleaveGPS) &&
          globals.isEmpGpsOn) {
        String status = await attdnc.checkInOutStatuss();
        if (status == 'Logged In') {
          streamSubscription = await GpsLogServices.initPlatformState();
        }
      }
    }
  }

  Future _getSettingsDetailspayroll() async {
    if (mounted) {
      setState(() {
        payrollwidgetcnt = 1;
        globals.isLeave = false;
        globals.istaskenabled = false;
        globals.isdirectbilling = false;
        globals.isCircularEnabled = false;
        globals.isMeetingEnabled = false;
        globals.isCalendarEnabled = false;
        globals.isBiometricEnabled = false;
        globals.isHolidayEnabled = false;
        globals.isSalaryEnabled = false;
        globals.isempcontactenabled = false;
        globals.employeelogin = false;
        globals.isAttendance = false;
        globals.isGPS = false;
        globals.isSublogin = false;
        globals.isWithoutLocationEnabled = false;
        globals.isLoginInWebAllowed = false;
        globals.loginphotocap = false;
        globals.isHolidayEnabled = false;
      });
    }
    String query =
        '${globals.applictionRootUrl}API/GetSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      globals.isLeave = jobject["Item1"][6]["SettingValue"];
      var isPayrollWithoutlocationEnable =
          jobject['Item1'][20]["CalculationType"];
      var payrolllocationenabledinweb = jobject["Item1"][34]["SettingValue"];
      var attendanceEnable = jobject["Item1"][20]["SettingValue"];
      var employeeContact = jobject["Item1"][32]["SettingValue"];
      var photocap = jobject["Item1"][33]["SettingValue"];
      var gpsenable = jobject["Item1"][21]["SettingValue"];
      var sublogin = jobject["Item1"][23]["SettingValue"];
      var employeelogin = jobject["Item1"][12]["SettingValue"];
      var holiday = jobject["Item1"][38]["SettingValue"];
      var circular = jobject["Item1"][36]["SettingValue"];
      var meeting = jobject["Item1"][37]["SettingValue"];
      var calenderview = jobject["Item1"][35]["SettingValue"];
      var salarydetails = jobject["Item1"][39]["SettingValue"];
      var isBiometericEnabled = jobject["Item1"][43]["SettingValue"];
      var directbilling = jobject["Item2"]["SettingData"]["IsTaskDirectBill"];
      var taskenabled = jobject["Item2"]["SettingData"]["TaskManagement"];
      var logintime = jobject["Item2"]["SettingData"]["LInTime"];
      var logouttime = jobject["Item2"]["SettingData"]["LOutTime"];

      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      if (globals.isLeave) {
        globals.isLeave = true;
        payrollwidgetcnt++;

        if (taskenabled) {
          globals.istaskenabled = true;

          if (directbilling) {
            globals.isdirectbilling = true;
          }
        }
        if (circular) {
          payrollwidgetcnt++;
          globals.isCircularEnabled = true;
        }
        if (meeting) {
          payrollwidgetcnt++;
          globals.isMeetingEnabled = true;
        }
        if (calenderview) {
          payrollwidgetcnt++;
          globals.isCalendarEnabled = true;
        }
        if (holiday) {
          payrollwidgetcnt++;
          globals.isHolidayEnabled = true;
        }
      }

      if (isBiometericEnabled) {
        globals.isBiometricEnabled = true;
      }

      if (salarydetails) {
        payrollwidgetcnt++;
        globals.isSalaryEnabled = true;
      }

      if (employeeContact) {
        payrollwidgetcnt++;
        globals.isempcontactenabled = true;
      }

      if (employeelogin) {
        globals.employeelogin = true;
      }

      if (attendanceEnable) {
        payrollwidgetcnt++;
        globals.isAttendance = true;
        if (gpsenable) {
          globals.isGPS = true;
        }
        if (sublogin) {
          globals.isSublogin = true;
        }
        if (isPayrollWithoutlocationEnable == true) {
          globals.isWithoutLocationEnabled = true;
        } else {
          showDialogIfFirstLoaded();
        }

        if (payrolllocationenabledinweb == true) {
          globals.isLoginInWebAllowed = true;
        }
        if (photocap) {
          globals.loginphotocap = true;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }

    print("Payroll" "$payrollwidgetcnt");
  }

  Future _getSettingsDetailsleave() async {
    globals.isLeaveAttendance = true;
    globals.isLeaveSublogin = false;
    globals.isleaveGPS = false;
    globals.isLeaveBiometricEnabled = false;
    globals.leaveisWithoutLocationEnabled = false;
    globals.leaveisLoginInWebAllowed = false;
    globals.isLeaveAttendance = false;
    globals.isLeaveHolidayEnabled = false;
    globals.isLeaveCircularEnabled = false;
    globals.isLeaveMeetingEnabled = false;
    globals.isLeaveCalendarEnabled = false;
    globals.isLeaveempcontactenabled = false;
    globals.isdirectbilling = false;
    globals.istaskenabled = false;
    globals.yearType = 0;
    if (mounted) {
      setState(() {
        widgetcnt = 0;
        widgetcnt = 1;
      });
    }

    String query =
        '${globals.applictionRootUrl}API/GetLeaveSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveAttendance = jobject["SettingData"]["Attendance"];
      var leaveSublogin = jobject["SettingData"]["SubLogin"];
      var leaveattendanceWithOutLocation =
          jobject['SettingData']['AttendanceWithOutLocation'];
      var leavelogininweb = jobject['SettingData']['AttendanceLoginInWeb'];
      var leaveGPS = jobject["SettingData"]["GPSTracking"];
      var yearType = jobject["SettingData"]["YearType"];
      var logintime = jobject["SettingData"]["LInTime"];
      var logouttime = jobject["SettingData"]["LOutTime"];
      var taskManagement = jobject["SettingData"]["TaskManagement"];
      var directbilling = jobject["SettingData"]["IsTaskDirectBill"];
      var meeting = jobject["SettingData"]["Meetings"];
      var holiday = jobject["SettingData"]["Holiday"];
      var circular = jobject["SettingData"]["Circular"];
      var calendarview = jobject["SettingData"]["Calender"];
      var employeecnt = jobject["SettingData"]["EmployeeContactDetails"];
      var isBiometericEnabled = jobject["SettingData"]["Biometric"];
      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      if (leaveAttendance == true) {
        widgetcnt++;
        globals.isLeaveAttendance = true;

        if (leaveSublogin == true) {
          globals.isLeaveSublogin = true;
        } else {
          globals.isLeaveSublogin = false;
        }

        if (leaveGPS == true) {
          globals.isleaveGPS = true;
        } else {
          globals.isleaveGPS = false;
        }
        if (isBiometericEnabled == true) {
          globals.isLeaveBiometricEnabled = true;
        } else {
          globals.isLeaveBiometricEnabled = false;
        }
        if (leaveattendanceWithOutLocation == true) {
          globals.leaveisWithoutLocationEnabled = true;
        } else {
          globals.leaveisWithoutLocationEnabled = false;
        }

        if (leavelogininweb == true) {
          globals.leaveisLoginInWebAllowed = true;
        } else {
          globals.leaveisLoginInWebAllowed = false;
        }
      } else {
        globals.isLeaveAttendance = false;
      }

      if (holiday == true) {
        widgetcnt++;

        globals.isLeaveHolidayEnabled = true;
      } else {
        globals.isLeaveHolidayEnabled = false;
      }

      if (circular == true) {
        widgetcnt++;

        globals.isLeaveCircularEnabled = true;
      } else {
        globals.isLeaveCircularEnabled = false;
      }

      if (meeting == true) {
        widgetcnt++;

        globals.isLeaveMeetingEnabled = true;
      } else {
        globals.isLeaveMeetingEnabled = false;
      }

      if (calendarview == true) {
        widgetcnt++;

        globals.isLeaveCalendarEnabled = true;
      } else {
        globals.isLeaveCalendarEnabled = false;
      }

      if (employeecnt == true) {
        widgetcnt++;

        globals.isLeaveempcontactenabled = true;
      } else {
        globals.isLeaveempcontactenabled = false;
      }

      if (taskManagement == true) {
        widgetcnt++;

        globals.istaskenabled = true;
        if (directbilling == true) {
          globals.isdirectbilling = true;
        } else {
          globals.isdirectbilling = false;
        }
      } else {
        globals.istaskenabled = false;
      }

      if (yearType == 0) {
        globals.yearType = 0;
      } else {
        globals.yearType = 1;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future loadLoginProfiles() async {
    loginList.clear();
    loginList = await DBProvider.db.getAllLoginProfile();
  }

  Future _getDashboardData() async {
    if (mounted) {
      setState(() {
        empName = "";
        empCode = "";
        empDesignation = "";
        empDepartment = "";
        empDOJ = "";
        globals.isEmpAttendanceOn = false;
        globals.isEmpSubLoginOn = false;
        globals.isEmpGpsOn = false;
      });
    }
    String query =
        '${globals.applictionRootUrl}API/GetProfileDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      if (response.body.toString() != '[]') {
        if (jobject[0]["EmployeeName"] != null &&
            jobject[0]["EmployeeCode"] != null &&
            jobject[0]["Designation"] != null &&
            jobject[0]["Department"] != null &&
            jobject[0]["DOJ"] != null) {
          empName = jobject[0]["EmployeeName"];

          empCode = jobject[0]["EmployeeCode"];
          empDesignation = jobject[0]["Designation"];
          empDepartment = jobject[0]["Department"];
          empDOJ = jobject[0]["DOJ"];

          globals.isEmpAttendanceOn = jobject[0]['Attendance'] ?? false;
          globals.isEmpSubLoginOn = jobject[0]['SubLogin'] ?? false;
          globals.isEmpGpsOn = jobject[0]['GPSTracking'] ?? false;
        }
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
    ));
    Color primaryColor = Colors.blue;

    return FutureBuilder(builder: (context, snapshot) {
      return WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: Scaffold(
              key: _homepagescaffoldKey,
              backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
              body: RefreshIndicator(
                onRefresh: refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            border: Border.all(color: primaryColor)),
                      ),
                      Stack(children: <Widget>[
                        ClipPath(
                          clipper: CustomShapeClipper(),
                          child: Container(
                            height: 350.0,
                            decoration: BoxDecoration(color: primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const <Widget>[
                              Text(
                                "Payroll",
                                style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontFamily: "Varela"),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 60.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Material(
                                  elevation: 1.0,
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Colors.red[300],
                                ),
                                if (isLoaded &&
                                    globals.isGPS &&
                                    (!globals.isEmployee || globals.isEmpGpsOn))
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100))),
                                      child: IconButton(
                                        icon: const Icon(Icons.pin_drop),
                                        color: Colors.white,
                                        iconSize: 26.0,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => !globals
                                                        .isEmployee
                                                    ? const EmployeeList()
                                                    : EmployeeLog(
                                                        mainId: globals.userId,
                                                        empName: '',
                                                      )),
                                          );
                                        },
                                      )),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 130.0, right: 15.0, left: 15.0),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: !isLoaded
                                  ? 350
                                  : (payrollwidgetcnt > 6 || widgetcnt > 6)
                                      ? 350
                                      : 250,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0.0, 3.0),
                                        blurRadius: 15.0)
                                  ]),
                              child: !isLoaded
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Center(
                                      child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      direction: Axis.horizontal,
                                      spacing: 20.0,
                                      runSpacing: 8.0,
                                      children: <Widget>[
                                        if (globals.isSalaryEnabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.purple
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon: const Icon(
                                                        Icons.bookmark_border),
                                                    color: Colors.purple,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const SalaryDetailspage()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 11.0),
                                                const Text('Salary Details',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                        if (globals.isLeave)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Badge.Badge(
                                                    showBadge:
                                                        (leaveleftapprovecnt !=
                                                                    0 &&
                                                                globals
                                                                    .isapprover)
                                                            ? true
                                                            : false,
                                                    badgeColor: Colors.blue,
                                                    toAnimate: false,
                                                    badgeContent: Text(
                                                      "$leaveleftapprovecnt",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    child: Material(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        color: Colors.purple
                                                            .withOpacity(0.1),
                                                        child: IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(7.0),
                                                          icon: const Icon(
                                                              Icons.person_add),
                                                          color: Colors.purple,
                                                          iconSize: 35.0,
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const LeaveAproveRequest()),
                                                            ).then((value) =>
                                                                noticelog());
                                                          },
                                                        ))),
                                                const SizedBox(height: 11.0),
                                                const Text('Leave',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        if ((globals.isAttendance &&
                                            (!globals.isEmployee ||
                                                globals.isEmpAttendanceOn)))
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon: const Icon(
                                                        Icons.mark_chat_read),
                                                    color: Colors.blue,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => globals
                                                                    .isWithoutLocationEnabled
                                                                ? const AttendanceWithOutLocation()
                                                                : const attendance
                                                                    .AttendanceRecorderWidget()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text('Attendance',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        if (globals.istaskenabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon:
                                                        const Icon(Icons.task),
                                                    color: Colors.blue,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AssignEmployee()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text('Task',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        if (globals.isCircularEnabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Badge.Badge(
                                                    showBadge: (globals
                                                                .isEmployee &&
                                                            notreadcount != 0)
                                                        ? true
                                                        : false,
                                                    badgeColor: Colors.blue,
                                                    badgeContent: Text(
                                                      "$notreadcount",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      color: Colors.orange
                                                          .withOpacity(0.1),
                                                      child: IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7.0),
                                                        icon: const Icon(Icons
                                                            .messenger_outline),
                                                        color: Colors.orange,
                                                        iconSize: 35.0,
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const CircularEmployee()),
                                                          ).then((value) =>
                                                              noticelog());
                                                        },
                                                      ),
                                                    )),
                                                const SizedBox(height: 10.0),
                                                const Text('Circular',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        if (globals.isMeetingEnabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    icon:
                                                        const Icon(Icons.mail),
                                                    color: Colors.blue,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AdminempMeeting(
                                                                  meetid: 0,
                                                                )),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text('Meeting',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                        if (globals.isHolidayEnabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon: const Icon(
                                                        Icons.beach_access),
                                                    color: Colors.deepPurple,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const UpcomimgHoliday()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text('Holidays',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                        if (globals.isempcontactenabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon: const Icon(
                                                        Icons.people),
                                                    color: Colors.blue,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AllEmpDetails()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text(
                                                    'Employee'
                                                    '\n'
                                                    '    View',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                        if (globals.isCalendarEnabled)
                                          Container(
                                            color: Colors.white,
                                            width: 80,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    icon: const Icon(
                                                        Icons.calendar_today),
                                                    color: Colors.orange,
                                                    iconSize: 35.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const CalendarView()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                const Text(
                                                    'Calendar'
                                                    '\n'
                                                    '   View',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                        if (payrollwidgetcnt == 1)
                                          const Center(
                                            child: Text(
                                                "Please enable required modules in web",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14)),
                                          )
                                      ],
                                    ))),
                        )
                      ]),
                    ],
                  ),
                ),
              )));
    });
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0.0, 390.0 - 200);
    path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _AndroidDrawer extends StatelessWidget {
  final mainTabKey = GlobalKey();
  Future _getuserRole() async {
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/GetUserRole?DBName=${globals.databaseName}&userId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var role = jobject;

      if (role.toString() == "2") {
        globals.isEmployee = true;
        sharedpref.setBoolExtra("isEmployee", true);
      } else {
        globals.isEmployee = false;

        sharedpref.setBoolExtra("isEmployee", false);
      }
    }
  }

  Future _getSettingsDetailspayroll() async {
    String query =
        '${globals.applictionRootUrl}API/GetSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveEnable = jobject["Item1"][6]["SettingValue"];
      var isPayrollWithoutlocationEnable =
          jobject['Item1'][20]["CalculationType"];
      var payrolllocationenabledinweb = jobject["Item1"][34]["SettingValue"];
      var attendanceEnable = jobject["Item1"][20]["SettingValue"];
      var employeeContact = jobject["Item1"][32]["SettingValue"];
      var photocap = jobject["Item1"][33]["SettingValue"];
      var gpsenable = jobject["Item1"][21]["SettingValue"];
      var sublogin = jobject["Item1"][23]["SettingValue"];
      var employeelogin = jobject["Item1"][12]["SettingValue"];
      var holiday = jobject["Item1"][38]["SettingValue"];
      var circular = jobject["Item1"][36]["SettingValue"];
      var meeting = jobject["Item1"][37]["SettingValue"];
      var calenderview = jobject["Item1"][35]["SettingValue"];
      var salarydetails = jobject["Item1"][39]["SettingValue"];
      var directbilling = jobject["Item2"]["SettingData"]["IsTaskDirectBill"];

      if (directbilling == true) {
        globals.isdirectbilling = true;
        sharedpref.setBoolExtra("isdirectbilling", true);
      } else {
        globals.isdirectbilling = false;
        sharedpref.setBoolExtra("isdirectbilling", false);
      }
      if (holiday == true) {
        globals.isHolidayEnabled = true;
      } else {
        globals.isHolidayEnabled = false;
      }

      if (circular == true) {
        globals.isCircularEnabled = true;
      } else {
        globals.isCircularEnabled = false;
      }

      if (meeting == true) {
        globals.isMeetingEnabled = true;
      } else {
        globals.isMeetingEnabled = false;
      }

      if (calenderview == true) {
        globals.isCalendarEnabled = true;
      } else {
        globals.isCalendarEnabled = false;
      }

      if (salarydetails == true) {
        globals.isSalaryEnabled = true;
      } else {
        globals.isSalaryEnabled = false;
      }

      var logintime = jobject["Item2"]["SettingData"]["LInTime"];
      var logouttime = jobject["Item2"]["SettingData"]["LOutTime"];

      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      if (isPayrollWithoutlocationEnable == true) {
        globals.isWithoutLocationEnabled = true;
        sharedpref.setBoolExtra("isWithoutlocationEnable", true);
      } else {
        globals.isWithoutLocationEnabled = false;
        sharedpref.setBoolExtra("isWithoutlocationEnable", false);
      }
      if (payrolllocationenabledinweb == true) {
        globals.isLoginInWebAllowed = true;
        sharedpref.setBoolExtra("locationenabledinweb", true);
      } else {
        globals.isLoginInWebAllowed = false;
        sharedpref.setBoolExtra("locationenabledinweb", false);
      }
      if (photocap == true) {
        globals.loginphotocap = true;
        sharedpref.setBoolExtra("isLoginCap", true);
      } else {
        globals.loginphotocap = false;
        sharedpref.setBoolExtra("isLoginCap", false);
      }
      if (leaveEnable == true) {
        globals.isLeave = true;
      } else {
        globals.isLeave = false;
      }

      if (employeeContact == true) {
        globals.isempcontactenabled = true;
        sharedpref.setBoolExtra("isEmpCnt", true);
      } else {
        globals.isempcontactenabled = false;
        sharedpref.setBoolExtra("isEmpCnt", false);
      }

      if (employeelogin == true) {
        globals.employeelogin = true;
        sharedpref.setBoolExtra("isEmpLogin", true);
      } else {
        globals.employeelogin = false;

        sharedpref.setBoolExtra("isEmpLogin", false);
      }

      if (attendanceEnable == true) {
        globals.isAttendance = true;
        sharedpref.setBoolExtra("isAttendance", true);
      } else {
        globals.isAttendance = false;

        sharedpref.setBoolExtra("isAttendance", false);
      }

      if (gpsenable == true) {
        globals.isGPS = true;
        sharedpref.setBoolExtra("isGPS", true);
      } else {
        globals.isGPS = false;

        sharedpref.setBoolExtra("isGPS", false);
      }
      if (sublogin == true) {
        globals.isSublogin = true;
        sharedpref.setBoolExtra("isSublogin", true);
      } else {
        globals.isSublogin = false;

        sharedpref.setBoolExtra("isSublogin", false);
      }
    }
  }

  Future _getSettingsDetailsleave() async {
    globals.isLeaveAttendance = true;
    globals.isLeaveSublogin = false;
    globals.isleaveGPS = false;
    globals.isLeaveBiometricEnabled = false;
    globals.leaveisWithoutLocationEnabled = false;
    globals.leaveisLoginInWebAllowed = false;
    globals.isLeaveAttendance = false;
    globals.isLeaveHolidayEnabled = false;
    globals.isLeaveCircularEnabled = false;
    globals.isLeaveMeetingEnabled = false;
    globals.isLeaveCalendarEnabled = false;
    globals.isLeaveempcontactenabled = false;
    globals.isdirectbilling = false;
    globals.istaskenabled = false;
    globals.yearType = 0;

    widgetcnt = 0;
    widgetcnt = 1;

    String query =
        '${globals.applictionRootUrl}API/GetLeaveSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveAttendance = jobject["SettingData"]["Attendance"];
      var leaveSublogin = jobject["SettingData"]["SubLogin"];
      var leaveattendanceWithOutLocation =
          jobject['SettingData']['AttendanceWithOutLocation'];
      var leavelogininweb = jobject['SettingData']['AttendanceLoginInWeb'];
      var leaveGPS = jobject["SettingData"]["GPSTracking"];
      var yearType = jobject["SettingData"]["YearType"];
      var logintime = jobject["SettingData"]["LInTime"];
      var logouttime = jobject["SettingData"]["LOutTime"];
      var taskManagement = jobject["SettingData"]["TaskManagement"];
      var directbilling = jobject["SettingData"]["IsTaskDirectBill"];
      var meeting = jobject["SettingData"]["Meetings"];
      var holiday = jobject["SettingData"]["Holiday"];
      var circular = jobject["SettingData"]["Circular"];
      var calendarview = jobject["SettingData"]["Calender"];
      var employeecnt = jobject["SettingData"]["EmployeeContactDetails"];
      var isBiometericEnabled = jobject["SettingData"]["Biometric"];
      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      if (leaveAttendance == true) {
        widgetcnt++;
        globals.isLeaveAttendance = true;

        if (leaveSublogin == true) {
          globals.isLeaveSublogin = true;
        } else {
          globals.isLeaveSublogin = false;
        }

        if (leaveGPS == true) {
          globals.isleaveGPS = true;
        } else {
          globals.isleaveGPS = false;
        }
        if (isBiometericEnabled == true) {
          globals.isLeaveBiometricEnabled = true;
        } else {
          globals.isLeaveBiometricEnabled = false;
        }
        if (leaveattendanceWithOutLocation == true) {
          globals.leaveisWithoutLocationEnabled = true;
        } else {
          globals.leaveisWithoutLocationEnabled = false;
        }

        if (leavelogininweb == true) {
          globals.leaveisLoginInWebAllowed = true;
        } else {
          globals.leaveisLoginInWebAllowed = false;
        }
      } else {
        globals.isLeaveAttendance = false;
      }

      if (holiday == true) {
        widgetcnt++;

        globals.isLeaveHolidayEnabled = true;
      } else {
        globals.isLeaveHolidayEnabled = false;
      }

      if (circular == true) {
        widgetcnt++;

        globals.isLeaveCircularEnabled = true;
      } else {
        globals.isLeaveCircularEnabled = false;
      }

      if (meeting == true) {
        widgetcnt++;

        globals.isLeaveMeetingEnabled = true;
      } else {
        globals.isLeaveMeetingEnabled = false;
      }

      if (calendarview == true) {
        widgetcnt++;

        globals.isLeaveCalendarEnabled = true;
      } else {
        globals.isLeaveCalendarEnabled = false;
      }

      if (employeecnt == true) {
        widgetcnt++;

        globals.isLeaveempcontactenabled = true;
      } else {
        globals.isLeaveempcontactenabled = false;
      }

      if (taskManagement == true) {
        widgetcnt++;

        globals.istaskenabled = true;
        if (directbilling == true) {
          globals.isdirectbilling = true;
        } else {
          globals.isdirectbilling = false;
        }
      } else {
        globals.istaskenabled = false;
      }

      if (yearType == 0) {
        globals.yearType = 0;
      } else {
        globals.yearType = 1;
      }
    }
  }

  void openApp(BuildContext context, int index) async {
    Navigator.pop(context);

    globals.isLoggedIn = true;

    sharedpref.setIntExtra("UserId", loginList[index].loginid!);
    sharedpref.setBoolExtra("IsLoggedIn", true);
    sharedpref.setStringExtra("DatabaseName", loginList[index].databasename!);

    LoginProfile lg = LoginProfile();
    lg.loginid = loginList[index].loginid;
    lg.appid = loginList[index].appid;
    lg.databasename = loginList[index].databasename;
    lg.emaild = loginList[index].emaild;
    lg.isdefault = true;
    globals.userId = loginList[index].loginid!;
    globals.databaseName = loginList[index].databasename!;
    globals.databaseId = loginList[index].appid.toString();

    DBProvider.db.updateDefaultLogin(lg);
    loadagainLoginProfiles();
    loadCompanyDropdowns(context);
    applist.clear();
  }

  void openAppFromApplist(BuildContext context, int index) async {
    await _getuserRole();
    await _getSettingsDetailspayroll();
    await _getSettingsDetailsleave();
    var app = applist[index];
    var appid = app.appid;
    globals.isLoggedIn = true;

    globals.databaseName = applist[index].databasename!;
    sharedpref.setBoolExtra("IsLoggedIn", true);
    sharedpref.setStringExtra("DatabaseName", applist[index].databasename!);
    if (appid == 2) {
      Navigator.popUntil(_homepagescaffoldKey.currentContext!,
          ModalRoute.withName('/homepagepayroll'));
      Navigator.push(
          _homepagescaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (BuildContext context) => const LandingPagepayroll()));

      globals.payroll = 2;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 5) {
      Navigator.popUntil(_homepagescaffoldKey.currentContext!,
          ModalRoute.withName('/homepageleave'));
      Navigator.push(
          _homepagescaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (BuildContext context) => LandingPageLeave()));
      globals.payroll = 5;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 29) {
      Navigator.popUntil(_homepagescaffoldKey.currentContext!,
          ModalRoute.withName('/homepagetaskandattendance'));
      Navigator.push(
          _homepagescaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (BuildContext context) => const TaskandAttendance()));

      globals.payroll = 29;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 27) {
      Navigator.popUntil(_homepagescaffoldKey.currentContext!,
          ModalRoute.withName('/homepagetaskmanager'));
      Navigator.push(
          _homepagescaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (BuildContext context) => const OnlyTaskManager()));

      globals.payroll = 27;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else {
      Navigator.popUntil(_homepagescaffoldKey.currentContext!,
          ModalRoute.withName('/homefieldstafftracker'));
      Navigator.push(
          _homepagescaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (BuildContext context) => const FieldStaffTracker()));

      globals.payroll = 28;
      sharedpref.setIntExtra("payroll", globals.payroll);
    }
  }

  List<MaterialColor> getRandomColorsheere(int amount) {
    return List<MaterialColor>.generate(amount, (index) {
      return _myListOfRandomColors[
          _random.nextInt(_myListOfRandomColors.length)];
    });
  }

  void displayloginDialog(BuildContext mcontext) async {
    await loadagainLoginProfiles();
    _displayAllLoginsDialog(mcontext);
  }

  Future loadagainLoginProfiles() async {
    loginList.clear();
    loginList = await DBProvider.db.getAllLoginProfile();
    colors = getRandomColorsheere(loginList.length);
  }

  void removeLoginOrLogout(BuildContext context, bool isForceLogout) async {
    int userID = globals.userId;
    if (!isForceLogout) {
      DBProvider.db.deleteLogin(userID);
    }

    await loadagainLoginProfiles();

    if (loginList.isNotEmpty && !isForceLogout) {
      displayloginDialog(context);
      globals.isLoggedIn = true;

      sharedpref.setBoolExtra("IsLoggedIn", true);
    } else {
      globals.isLoggedIn = false;
      if (!isForceLogout) {
        sharedpref.setIntExtra("UserId", 0);
        sharedpref.setBoolExtra("IsLoggedIn", false);
        sharedpref.setStringExtra("DatabaseName", "");
      }
      globals.userId = 0;
      globals.databaseName = "";

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyLoginPage()),
          ModalRoute.withName('/login'));
    }
  }

  Future loadCompanyDropdowns(BuildContext contxt) async {
    final prefs = await SharedPreferences.getInstance();
    companydropdownValue = '';
    companyDropdownitems.clear();

    companyDropdownitems.add(const DropdownMenuItem(
      value: "",
      child: Text("Select Company"),
    ));

    final http.Response response = await http.post(
      Uri.parse('${globals.ofcRootUrl}GetCompanyData?UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    List<String> companyDdnitems = [];
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      List responseJson = json.decode(jobject);
      if (responseJson.isNotEmpty) {
        companyDdnitems =
            responseJson.map((e) => e["CompanyName"].toString()).toList();
      }
    }
    companydropdownValue = '';
    for (var item in companyDdnitems) {
      companyDropdownitems.add(DropdownMenuItem(
        value: item,
        child: Text(item.toString()),
      ));
    }
    if (companyDdnitems.length == 1) {
      companydropdownValue = companyDdnitems.first;
      await prefs.setInt('companycount', companyDropdownitems.length);
      globals.compcount = prefs.getInt('companycount')!;
      loadApplist(contxt);
    } else if (companyDdnitems.length > 1) {
      companydropdownValue = "";
      await prefs.setInt('companycount', companyDropdownitems.length);
      globals.compcount = prefs.getInt('companycount')!;
      await _displayDialog(contxt);
    }
  }

  void _changecompanydropdownval(BuildContext context, String val) {
    companydropdownValue = val;
    if (companydropdownValue != '') {
      Navigator.pop(context);
      loadApplist(context);
    }
  }

  Future loadApplist(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    String query =
        '${globals.ofcRootUrl}GetApplicationData?CompanyName=${companydropdownValue.replaceAll("+", "%2B").replaceAll(' ', "%20").replaceAll('&', '%26').replaceAll('!', '%21').replaceAll('#', '%23').replaceAll('-', '%2D').replaceAll('/', '%2F').replaceAll('.', '%2E').replaceAll('"', '%22')}&AppId=2,5,27,28,29&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject1 = jsonDecode(response.body.toString());
      List responseJson1 = json.decode(jobject1);
      if (responseJson1.isNotEmpty) {
        applist = responseJson1.map((e) => AppListModel.fromJson(e)).toList();
      }
    }
    await prefs.setInt('appcount', 0);

    if (applist.length == 1) {
      await prefs.setInt('appcount', applist.length);
      globals.appcount = prefs.getInt('appcount')!;
    } else {
      await prefs.setInt('appcount', applist.length);
      globals.appcount = prefs.getInt('appcount')!;
    }

    _displayDialog(context);
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: _homepagescaffoldKey.currentContext!,
        barrierDismissible: false,
        builder: (dialogContex) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text('Switch App'),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text("Select Company",
                                    style: TextStyle(color: Colors.blue[400]))),
                            DropdownButton<String>(
                              value: companydropdownValue,
                              isExpanded: true,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.blue,
                              ),
                              items: companyDropdownitems,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _changecompanydropdownval(
                                      dialogContex, newValue!);
                                  companydropdownValue = newValue;
                                });
                              },
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Text("Select App",
                                    style: TextStyle(color: Colors.blue[400]))),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                                minHeight: 10, maxHeight: 300),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: applist.length,
                                itemBuilder: (context, index) {
                                  if (applist.isNotEmpty) {
                                    return Container(
                                      child: _buildItem(
                                          context, applist[index], index),
                                    );
                                  } else {
                                    return Container(
                                      child: const Text("No Apps"),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildItem(BuildContext context, AppListModel app, [int? index]) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 0.0),
      key: ValueKey<AppListModel>(app),
      title: Text(app.appname!),
      dense: false,
      trailing: IconButton(
        icon: const Icon(Icons.exit_to_app, color: Colors.blue),
        onPressed: () {
          Navigator.pop(context);
          openAppFromApplist(context, index!);
        },
      ),
    );
  }

  _displayAllLoginsDialog(BuildContext mcontext) async {
    return showDialog(
        context: mcontext,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text('Switch Login'),
                content: SizedBox(
                  width: 100.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        constraints:
                            const BoxConstraints(minHeight: 10, maxHeight: 300),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: loginList.length,
                            itemBuilder: (context, index) {
                              if (loginList.isNotEmpty) {
                                return Container(
                                  child: _buildLoginsItem(
                                      context, loginList[index], index),
                                );
                              } else {
                                return Container(
                                  child: const Text("No Apps"),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const Divider(color: Colors.black, height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            color: Colors.blue,
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: Colors.blue)),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          removeLoginOrLogout(context, true);
                        },
                        child: Text("Add New Login".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildLoginsItem(BuildContext context, LoginProfile app,
      [int? index]) {
    return ListTile(
      onTap: () => {openApp(context, index)},
      contentPadding: const EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      key: ValueKey<LoginProfile>(app),
      title: Text(
        app.emaild!,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      leading: CircleAvatar(
        backgroundColor: colors[index!],
        child: app.isdefault!
            ? IconButton(
                icon: const Icon(
                  Icons.done,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () => {},
              )
            : Text(
                loginList[index].emaild!.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
      ),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.blue.shade800,
                    size: 96,
                  ),
                ),
                Text(
                  "Name : $empName",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.ac_unit, color: Colors.blue),
            title: Text("Employee Code : $empCode",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: Text("Designation : $empDesignation",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_balance, color: Colors.blue),
            title: Text("Department : $empDepartment",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.date_range,
              color: Colors.blue,
            ),
            title: Text("DOJ : $empDOJ",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin),
            title: const Text("Switch Login"),
            onTap: () {
              displayloginDialog(context);
            },
          ),
          (globals.appcount != 1)
              ? ListTile(
                  leading: const Icon(Icons.swap_horizontal_circle),
                  title: const Text("Switch App"),
                  onTap: () {
                    loadCompanyDropdowns(context);
                    applist.clear();
                  },
                )
              : Row(),
          ListTile(
            leading: const Icon(
              Icons.delete_forever,
            ),
            title: const Text("Delete Account"),
            onTap: () {
              Get.back();
              Get.to(() => const DeleteAccountPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text("Logout"),
            onTap: () async {
              _notificationTokenList();
              removeLoginOrLogout(context, false);
            },
          ),
        ],
      ),
    );
  }

  Future _notificationTokenList() async {
    String query =
        '${globals.applictionRootUrl}API/GetNotificationTokenList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      List listOfToken = jobject;

      for (int i = 0; i < listOfToken.length; i++) {
        if (listOfToken[i]['UserId'] == globals.userId) {
          _notificationTokenDelete(listOfToken[i]['ID']);
          return;
        }
      }
    }
  }

  Future _notificationTokenDelete(int id) async {
    String query = globals.applictionRootUrl +
        'API/NotificationTokenRemove?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&NotificationId=' +
        "$id";
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      print("Token Removed");
    }
  }

  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("Send"),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Map<String, dynamic> data = {
            (empName == '' ? "Admin" : empName): _controller.text,
          };
          FirebaseFirestore.instance
              .collection('Reported Bugs')
              .doc("Bugs")
              .set(data);
          _controller.clear();
          Navigator.of(context, rootNavigator: true).pop('dialog');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Bug Successfully Reported")));
          Navigator.pop(context);
        }
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        _controller.clear();
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Report Bug"),
      content: Form(
        autovalidateMode: AutovalidateMode.disabled,
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: TextFormField(
              controller: _controller,
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Required';
                } else {
                  return null;
                }
              },
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                labelText: 'Report Bug',
                hintText: 'Type Here',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                border: OutlineInputBorder(borderSide: BorderSide()),
              )),
        ),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class NoticeModal {
  const NoticeModal({
    this.isread,
  });

  final bool? isread;

  factory NoticeModal.fromJson(Map<String, dynamic> json) {
    return NoticeModal(
      isread: json['IsRead'] ?? false,
    );
  }
}
