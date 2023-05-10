import 'package:badges/badges.dart' as Badge;
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdEmpMeeting.dart';
import 'TaskAndAttendance.dart';
import 'all_employee_details.dart';
import 'assignemployee.dart';
import 'calendar_view.dart';
import 'circular_employee.dart';
import 'dashboard_leave.dart';
import 'dashboard_payroll.dart';
import 'database.dart';
import 'fieldStaffTracker.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import '../sharedpreferences.dart' as sharedpreferences;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'login.dart';
import 'loginmodel.dart';
import 'upcoming_holidays.dart';

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

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
int payrollwidgetcnt = 0;
int widgetcnt = 0;

class OnlyTaskManager extends StatelessWidget {
  const OnlyTaskManager({Key? key}) : super(key: key);

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
  int LeaveRequestCount = 0;
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
  AppUpdateInfo? _updateInfo;
  bool isempcircularseen = false;

  @override
  void initState() {
    refreshData();
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
  }

  Future _getuserRole() async {
    if (mounted) {
      setState(() {
        isLoaded = false;
      });
    }
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
    await _getuserRole();
    await noticelog();
    await _getSettingsDetailsleave();

    await _getDashboardData();
    if (mounted) {
      setState(() {});
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
    setState(() {
      widgetcnt = 0;
      widgetcnt = 1;
    });

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
      var logintime = jobject["SettingData"]["LInTime"];
      var logouttime = jobject["SettingData"]["LOutTime"];
      var taskManagement = jobject["SettingData"]["TaskManagement"];
      var directbilling = jobject["SettingData"]["IsTaskDirectBill"];
      var meeting = jobject["SettingData"]["Meetings"];
      var holiday = jobject["SettingData"]["Holiday"];
      var circular = jobject["SettingData"]["Circular"];
      var calendarview = jobject["SettingData"]["Calender"];
      var employeecnt = jobject["SettingData"]["EmployeeContactDetails"];
      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

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
    }

    setState(() {});
  }

  Future loadLoginProfiles() async {
    loginList.clear();
    loginList = await DBProvider.db.getAllLoginProfile();
  }

  Future _getDashboardData() async {
    String query =
        '${globals.applictionRootUrl}API/GetProfileDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
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
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  String monthValue = "";
  List<DropdownMenuItem<String>> monthList = [];

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
                                "Task Manager",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontFamily: "Varela"),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 130.0, right: 15.0, left: 15.0),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 250,
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
                                        if (globals.istaskenabled != false)
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
                                        if (globals.isLeaveCircularEnabled !=
                                            false)
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
                                        if (globals.isLeaveMeetingEnabled !=
                                            false)
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
                                        if (globals.isLeaveHolidayEnabled !=
                                            false)
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
                                        if (globals.isLeaveempcontactenabled !=
                                            false)
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
                                        if (globals.isLeaveCalendarEnabled !=
                                            false)
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

      // accountitem = new List<String>.from(streetsFromJson["Text"]);

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
    // var login = loginList[index];
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
    // Navigator.pop(context);
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
      // Navigator.pop(context, true);

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
      // sharedpref.setIntExtra("UserId", 0);
      sharedpref.setBoolExtra("IsLoggedIn", true);
      // sharedpref.setStringExtra("DatabaseName", "");

      // globals.userId = 0;
      // globals.databaseName = "";
    } else {
      globals.isLoggedIn = false;
      if (!isForceLogout) {
        sharedpref.setIntExtra("UserId", 0);
        sharedpref.setBoolExtra("IsLoggedIn", false);
        sharedpref.setStringExtra("DatabaseName", "");
      }
      globals.userId = 0;
      globals.databaseName = "";
      //  Navigator.pushNamedAndRemoveUntil(context, "/login",
      //                         (Route<dynamic> route) => false);
      // Navigator.pushNamedAndRemoveUntil(
      //     context, "/login", (Route<dynamic> route) => false);
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

    // prPleaseWait.show();
    // appDrodownitems.clear();
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.ofcRootUrl}GetApplicationData?CompanyName=$companydropdownValue&AppId=2,5&UserId=${globals.userId}'),
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
                              // icon: Icon(Icons.arrow_downward),
                              // iconSize: 15,
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
        // onLongPress: () => deleteUser(index),
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
                          //  globals.userId = 0;
                          // globals.databaseName = "";
                          // globals.isLoggedIn = false;
                          Navigator.pop(context);

                          // Navigator.of(mcontext).pushAndRemoveUntil(
                          //     MaterialPageRoute(
                          //         builder: (mcontext) => MyLoginPage()),
                          //     ModalRoute.withName('/'));
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
                // onLongPress: () => deleteUser(index),
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
          if (globals.payroll == 2)
            ListTile(
              leading: const Icon(Icons.person_pin),
              title: const Text("Switch Login"),
              onTap: () {
                displayloginDialog(context);
              },
            ),
          (globals.payroll == 2 && globals.appcount != 1)
              ? ListTile(
                  leading: const Icon(Icons.swap_horizontal_circle),
                  title: const Text("Switch App"),
                  onTap: () {
                    loadCompanyDropdowns(context);
                    applist.clear();
                  },
                )
              : Row(),
          // ListTile(
          //   leading: const Icon(Icons.bug_report),
          //   title: const Text("Report Bug"),
          //   onTap: () {
          //     showAlertDialog(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text("Logout"),
            onTap: () async {
              // _notificationTokenList();
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
