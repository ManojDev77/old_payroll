import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pay_lea_task/controller/var_controller.dart';
import 'package:pay_lea_task/services/gps_log_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/style.dart';
import '../models/get_employee.dart';
import '../services/notification_service.dart';
import 'api.dart';
import 'attendance_summary.dart';
import 'dbhelper.dart';
import 'map_view.dart';
import 'sharedpreferences.dart' as sharedpreferences;
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

var varController = Get.put(VarController());
StreamSubscription<LocationData>? streamSubscription;

int count = 0;
sharedpreferences.SharedPreferencesTest sharedpref =
    sharedpreferences.SharedPreferencesTest();
final Completer<GoogleMapController> _googlemapcontroller = Completer();
double zoomVal = 5.0;
int? masterID;
String? updatedTime;
String placeValue = "";
String subplaceValue = "";
List<DropdownMenuItem<String>> placeList = [];
List<DropdownMenuItem<String>> subplaceList = [];
TextEditingController remarkController = TextEditingController();
TextEditingController remarkController2 = TextEditingController();
DateTime? currentDate;
LatLng? currentPostion;
bool? _serviceEnabled;
bool once = true;
final Location location = Location();
var mainEmployeeList = [];
List values = [];
List valueslogin = [];
String? logintimedisp;
String? logouttimedisp;
Database? db;
GoogleMapController? newcontroller;

class AttendanceRecorderWidget extends StatefulWidget {
  const AttendanceRecorderWidget({Key? key}) : super(key: key);

  @override
  AttendanceRecorderWidgetState createState() =>
      AttendanceRecorderWidgetState();
}

class AttendanceRecorderWidgetState extends State<AttendanceRecorderWidget>
    with WidgetsBindingObserver {
  TextEditingController remarkController3 = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (globals.isEmpAttendanceOn) {
      setCurrentLocation();
      checkBatteryOptimization();
      initializedb();
      _checkalreadylogin();
      checkInOutStatuss();
      if (globals.isSublogin || globals.isLeaveSublogin) {
        checkInOutSubStatuss();
      }
      _getLocationData();
      _getSubLocationData();
      _getEmployeeData();
    }
    WidgetsBinding.instance.addObserver(this);
  }

  setCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    varController.isLocationLoaded.value = false;
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
    }
    var locationData = await location.getLocation();
    varController.initialposition.value = CameraPosition(
      bearing: 15,
      target: LatLng(locationData.latitude!, locationData.longitude!),
      zoom: 15,
    );
    varController.isLocationLoaded.value = true;
  }

  checkBatteryOptimization() async {
    OptimizeBattery.isIgnoringBatteryOptimizations().then((onValue) {
      setState(() {
        if (onValue) {
        } else {
          OptimizeBattery.stopOptimizingBatteryUsage();
        }
      });
    });
  }

  Future _getEmployeeData() async {
    mainEmployeeList = await GetEmployee().getEmployeeData();
    if (mounted) {
      setState(() {});
    }
  }

  initializedb() async {
    db = await DatabaseHelper.instance.database;
    List resultloc = await DatabaseHelper.instance.getAllLocationData();
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (resultloc.isNotEmpty) {
          for (int i = 0; i < resultloc.length; i++) {
            String query = '';
            query =
                '${globals.applictionRootUrl}API/GPSLogDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&Date=${resultloc[i].date}&Time=${resultloc[i].time}&lat=${resultloc[i].lat}&longitude=${resultloc[i].long}';
            await http.post(
              Uri.parse(query),
              headers: <String, String>{
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            );
          }
          await DatabaseHelper.instance.deleteAll();
          resultloc.clear;
        }
      }
    } on SocketException catch (_) {}
  }

  @override
  void dispose() {
    // newcontroller.dispose();
    // _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final bool isBackground = state == AppLifecycleState.paused;

    if (!varController.loginVisible.value &&
        once &&
        isBackground &&
        ((globals.isGPS || globals.isleaveGPS) && globals.isEmpGpsOn)) {
      once = false;
      NotificationService.showNoti(
        id: 1,
        title: 'Payroll',
        body: 'Please keep app in backround',
        payload: '1111',
      );
    }
  }

  Future _getLocationData() async {
    placeList.clear();
    placeList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));

    String query =
        '${globals.applictionRootUrl}API/GetLoginLocationList?DBName=${globals.databaseName}&userId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      var placeitem = jobject;

      placeitem.forEach((item) {
        placeList.add(DropdownMenuItem(
            value: item["ID"].toString(),
            child: Text(item["Name"].toString())));
      });
      setState(() {
        placeValue = placeList[0].value!;
      });
    }
  }

  Future _getSubLocationData() async {
    subplaceList.clear();
    subplaceList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));

    String query =
        '${globals.applictionRootUrl}API/GetSubLoginList?DBName=${globals.databaseName}&userId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var subplaceitem = jobject;
      subplaceitem.forEach((item) {
        subplaceList.add(DropdownMenuItem(
            value: item["ID"].toString(),
            child: Text(item["Name"].toString())));
      });
      setState(() {
        subplaceValue = subplaceList[0].value!;
      });
    }
  }

  Future checkInData() async {
    print("object");
    LocationData locationData = await location.getLocation();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query =
        '${globals.applictionRootUrl}API/CheckIn?DBName=${globals.databaseName}&UserId=${globals.userId}&Date=$formattedDate&Time=$formattedTime&lat=${locationData.latitude}&longitude=${locationData.longitude}&Remarks=${remarkController.text}&Location=$placeValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var res = jobject;
      if (res == true) {
        varController.loginVisible.value = false;
        varController.logoutVisible.value = true;
        varController.subloginVisible.value = true;

        Fluttertoast.showToast(
            msg: "Logged In Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      } else {
        Fluttertoast.showToast(
            msg: "Please Check Your Location Permission",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      }
    }
  }

  Future checkInSubData() async {
    LocationData locationData = await location.getLocation();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query =
        '${globals.applictionRootUrl}API/SubLogIn?DBName=${globals.databaseName}&UserId=${globals.userId}&MasterLoginId=$masterID&Date=$formattedDate&Time=$formattedTime&lat=${locationData.latitude}&longitude=${locationData.longitude}&Remarks=${remarkController.text}&Location=$subplaceValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var res = jobject;
      if (res == true) {
        varController.loginSubVisible.value = false;
        varController.logoutSubVisible.value = true;
        varController.logoutVisible.value = false;

        Fluttertoast.showToast(
            msg: "Sub Logged In Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      } else {
        Fluttertoast.showToast(
            msg: "Please Check Your Location Permission",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      }
    }
  }

  Future checkOutData() async {
    LocationData locationData = await location.getLocation();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query =
        '${globals.applictionRootUrl}API/CheckOut?DBName=${globals.databaseName}&UserId=${globals.userId}&Date=$formattedDate&Time=$formattedTime&lat=${locationData.latitude}&longitude=${locationData.longitude}&Remarks=${remarkController2.text}&Location=$placeValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var res = jobject;

      if (res == true) {
        varController.loginVisible.value = true;
        varController.logoutVisible.value = false;
        varController.subloginVisible.value = false;

        Fluttertoast.showToast(
            msg: "Logged Out Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      } else {
        Fluttertoast.showToast(
            msg: "Please Check Your Location Permission",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 15.0);
      }
    }
  }

  Future checkOutSubData() async {
    LocationData locationData = await location.getLocation();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query =
        '${globals.applictionRootUrl}API/SubLogOut?DBName=${globals.databaseName}&UserId=${globals.userId}&MasterLoginId=$masterID&Date=$formattedDate&Time=$formattedTime&lat=${locationData.latitude}&longitude=${locationData.longitude}&Remarks=${remarkController2.text}&Location=$subplaceValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var res = jobject;

      if (res == true) {
        Fluttertoast.showToast(
            msg: "Sub Logged Out Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 18.0);

        varController.loginSubVisible.value = true;
        varController.logoutSubVisible.value = false;
        varController.logoutVisible.value = true;
      } else {
        Fluttertoast.showToast(
            msg: "Please Check Your Location Permission",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 18.0);
      }
    }
  }

  Future<String> checkInOutStatuss() async {
    var checkInOutVal = '';
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/CheckInOutStatus?DBName=${globals.databaseName}&UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      checkInOutVal = jobject["Item1"];
      masterID = jobject["Item2"];

      if (jobject["Item1"] == 'Logged In') {
        varController.loginVisible.value = false;
        varController.logoutVisible.value = true;
        varController.subloginVisible.value = true;
      } else {
        varController.loginVisible.value = true;
        varController.logoutVisible.value = false;
        varController.subloginVisible.value = false;
      }
    }

    return checkInOutVal;
  }

  Future checkInOutSubStatuss() async {
    String query =
        '${globals.applictionRootUrl}API/SubLogInOutStatus?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      if (jobject == "Logged In") {
        varController.loginSubVisible.value = false;
        varController.logoutSubVisible.value = true;
      } else {
        varController.loginSubVisible.value = true;
        varController.logoutSubVisible.value = false;
      }
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _checkalreadylogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('logouttime') != "not set" ||
        (prefs.getString('logintime') != "not set")) {
      values = (prefs.getString('logouttime'))!.split(":");
      var format = DateFormat("HH:mm");
      var one = format.parse(prefs.getString('logouttime')!);
      var two = format.parse("00:15");
      values = (one.difference(two).toString()).split(":");

      var format2 = DateFormat("HH:mm");
      var loginTime = format2.parse(prefs.getString('logintime')!);

      var loginTime2 = format2.parse("00:10");
      valueslogin = (loginTime.difference(loginTime2).toString()).split(":");
      setState(() {});
    }

    // var now = DateTime.now();

    // var dateFormat = DateFormat("h:mm a");
    // logintimedisp = dateFormat.format(DateTime(now.year, now.month, now.day,
    //     int.parse(valueslogin[0]), int.parse(valueslogin[1])));

    // var dateFormat2 = DateFormat("h:mm a");
    // logouttimedisp = dateFormat2.format(DateTime(now.year, now.month, now.day,
    //     int.parse(values[0]), int.parse(values[1])));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !(varController.isLocationLoaded.value)
          ? Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : DefaultTabController(
              length: ((globals.isGPS || globals.isleaveGPS) &&
                      (globals.isEmployee || globals.isEmpGpsOn))
                  ? globals.isEmpAttendanceOn
                      ? 3
                      : 2
                  : globals.isEmpAttendanceOn
                      ? 2
                      : 1,
              child: Scaffold(
                  key: UniqueKey(),
                  appBar: AppBar(
                      backgroundColor: Colors.blue,
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // actions: <Widget>[
                      //   IconButton(
                      //     icon: const Icon(
                      //       Icons.info,
                      //       color: Colors.white,
                      //     ),
                      //     onPressed: () {
                      //       showDialog(
                      //           context: context,
                      //           builder: (context) {
                      //             return const Padding(
                      //               padding: EdgeInsets.all(30),
                      //               child: AlertDialog(
                      //                 title: Center(
                      //                   child: Text(
                      //                     "Login Time - \n\nLogout Time - ",
                      //                     style: TextStyle(fontSize: 13),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           });
                      //     },
                      //   )
                      // ],
                      title: const Text(
                        "Attendance",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins-Medium",
                          fontSize: 25,
                        ),
                      ),
                      centerTitle: true,
                      bottom: ((globals.isGPS || globals.isleaveGPS) &&
                              (globals.isEmployee || globals.isEmpGpsOn))
                          ? TabBar(
                              tabs: [
                                if (globals.isEmpAttendanceOn)
                                  const Tab(
                                    text: "Attendance",
                                  ),
                                const Tab(
                                  text: "Log Info",
                                ),
                                const Tab(
                                  text: "Map View",
                                ),
                              ],
                            )
                          : TabBar(
                              tabs: [
                                if (globals.isEmpAttendanceOn)
                                  const Tab(
                                    text: "Attendance",
                                  ),
                                const Tab(
                                  text: "Log Info",
                                ),
                              ],
                            )),
                  body: ((globals.isGPS || globals.isleaveGPS) &&
                          (globals.isEmployee || globals.isEmpGpsOn))
                      ? TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                              if (globals.isEmpAttendanceOn)
                                Stack(
                                  children: <Widget>[
                                    googleMap(context),
                                    buildContainer(context),
                                    ((globals.isSublogin ||
                                                globals.isLeaveSublogin) &&
                                            globals.isEmpSubLoginOn)
                                        ? buildContainer2(context)
                                        : Row(),
                                  ],
                                ),
                              const AttendanceSummary(),
                              const MapView(),
                            ])
                      : TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                              if (globals.isEmpAttendanceOn)
                                Stack(
                                  children: <Widget>[
                                    googleMap(context),
                                    buildContainer(context),
                                    ((globals.isSublogin ||
                                                globals.isLeaveSublogin) &&
                                            globals.isEmpSubLoginOn)
                                        ? buildContainer2(context)
                                        : Row(),
                                  ],
                                ),
                              const AttendanceSummary(),
                            ]))),
    );
  }

  Widget googleMap(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Obx(() => GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: varController.initialposition.value,
            onMapCreated: (GoogleMapController controller) {
              if (_googlemapcontroller.isCompleted) {
                _googlemapcontroller.complete(controller);

                newcontroller = controller;
              }
            },
          )),
    );
  }

  buildContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 50),
      child: Obx(() => Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                varController.loginVisible.value
                    ? ElevatedButton(
                        onPressed: () async {
                          _displayDialog();
                        },
                        child: const Text("LOGIN"))
                    : Row(),
                const Spacer(flex: 20),
                varController.logoutVisible.value
                    ? ElevatedButton(
                        onPressed: () async {
                          _displayDialog2();
                        },
                        child: const Text("LOGOUT"))
                    : Row(),
              ],
            ),
          )),
    );
  }

  buildContainer2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 180, horizontal: 60),
      child: Obx(() => Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                varController.subloginVisible.value
                    ? ElevatedButton(
                        onPressed: _displayDialogSubLogin,
                        child: const Text("SUB LOGIN"))
                    : Row(),
              ],
            ),
          )),
    );
  }

  _displayDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContex) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                // title: const Text('Remark'),
                content: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        "Location",
                        style: ThemeText.pageHeaderBlack,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: placeValue,
                        style: ThemeText.text,
                        onChanged: (String? newValue) {
                          setState(() {
                            placeValue = newValue!;
                          });
                        },
                        items: placeList,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Remark',
                        style: ThemeText.pageHeaderBlack,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextField(
                        autofocus: false,
                        controller: remarkController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                NotificationService.showNotificationSchedule(
                                    id: 1,
                                    title: 'Logout Alert',
                                    body: 'Logout Reminder',
                                    payload: 'Logout',
                                    scheduleDate: DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        int.parse(values[0]),
                                        int.parse(values[1]),
                                        00));
                                List<CameraDescription> cameras = [];
                                Navigator.pop(context);
                                if (globals.loginphotocap) {
                                  cameras = await availableCameras();
                                }

                                String username = mainEmployeeList
                                    .where((element) =>
                                        element.userid == globals.userId)
                                    .toList()[0]
                                    .empname;

                                (globals.loginphotocap)
                                    ? Get.to(
                                        () => TakePictureScreen(
                                          camera: cameras,
                                          state: "Login",
                                          username:
                                              "${username}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}",
                                          remark: remarkController.text,
                                          loc: placeValue,
                                        ),
                                      )
                                    : _callMarkInFunction();
                              },
                              child: const Text('Login',
                                  style: TextStyle(color: Colors.white))),
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

  _displayDialog2() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContex) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Location",
                      style: ThemeText.pageHeaderBlack,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: placeValue,
                      elevation: 0,
                      style: ThemeText.text,
                      onChanged: (String? newValue) {
                        setState(() {
                          placeValue = newValue!;
                        });
                      },
                      items: placeList,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Remark',
                      style: ThemeText.pageHeaderBlack,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      autofocus: false,
                      controller: remarkController2,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final now = DateTime.now();

                              NotificationService.showNotificationSchedule(
                                  id: 1,
                                  title: 'Login Alert',
                                  body: 'Login Reminder',
                                  payload: 'Login',
                                  scheduleDate: DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      int.parse(valueslogin[0]),
                                      int.parse(valueslogin[1]),
                                      00));
                              Navigator.pop(context);

                              bool enabled = FlutterBackground
                                  .isBackgroundExecutionEnabled;
                              if (enabled) {
                                await FlutterBackground.initialize();
                                await FlutterBackground
                                    .disableBackgroundExecution();
                              }

                              final cameras = await availableCameras();
                              String username = mainEmployeeList
                                  .where((element) =>
                                      element.userid == globals.userId)
                                  .toList()[0]
                                  .empname;

                              final prefs =
                                  await SharedPreferences.getInstance();

                              await prefs.setInt('myTimestampKey', -10000);

                              (globals.loginphotocap)
                                  ? Get.to(
                                      () => TakePictureScreen(
                                          camera: cameras,
                                          state: "Logout",
                                          username:
                                              "${username}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}",
                                          remark: remarkController2.text,
                                          loc: placeValue),
                                    )
                                  : _callMarkOutFunction();
                            },
                            child: const Text('Logout',
                                style: TextStyle(color: Colors.white))),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  _displayDialogSubLogin() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContex) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text('Sub Login'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      autofocus: false,
                      controller: remarkController3,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Location", style: ThemeText.pageHeaderBlack),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButton<String>(
                      value: subplaceValue,
                      isExpanded: true,
                      elevation: 20,
                      style: ThemeText.text,
                      onChanged: (String? newValue) {
                        setState(() {
                          subplaceValue = newValue!;
                        });
                      },
                      items: subplaceList,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Visibility(
                                visible: varController.loginSubVisible.value,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _callMarkInSubFunction();
                                    },
                                    child: const Text('Sub Login',
                                        style: TextStyle(color: Colors.white))),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Visibility(
                                  visible: varController.logoutSubVisible.value,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _callMarkOutSubFunction();
                                      },
                                      child: const Text('Sub Logout',
                                          style:
                                              TextStyle(color: Colors.white))))
                            ])),
                  ],
                ),
              );
            },
          );
        });
  }

  timer() async {
    // await location.enableBackgroundMode(enable: true);
    streamSubscription = await GpsLogServices.initPlatformState();
  }

  void _callMarkInFunction() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
    }
    checkInData();
    if ((globals.isGPS || globals.isleaveGPS) && (globals.isEmpGpsOn)) {
      timer();
    }
  }

  void _callMarkInSubFunction() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
    }
    checkInSubData();
  }

  void _callMarkOutFunction() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
    }

    checkOutData();
    if ((globals.isGPS || globals.isleaveGPS) && (globals.isEmpGpsOn)) {
      if (streamSubscription != null) {
        streamSubscription!.cancel();
      }
      await location.enableBackgroundMode(enable: false);
    }
  }

  void _callMarkOutSubFunction() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
    }
    checkOutSubData();
  }
}

class EmployeeId {
  EmployeeId({this.empid, this.userid, this.empname});
  int? empid;
  int? userid;
  String? empname;
  factory EmployeeId.fromJson(Map<String, dynamic> json) {
    return EmployeeId(
        empid: json['EmpID'] ?? 0,
        userid: json['UserID'] ?? 0,
        empname: json['EmpName'] ?? "");
  }
}

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription>? camera;
  final String? state;
  final String? username;
  final String? loc;
  final String? remark;
  const TakePictureScreen(
      {Key? key,
      @required this.camera,
      @required this.state,
      @required this.username,
      @required this.loc,
      @required this.remark})
      : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? controller;
  Future<void>? initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      widget.camera![0],
      ResolutionPreset.high,
    );

    initializeControllerFuture = controller!.initialize();
  }

  @override
  void dispose() {
    //  _controller!.dispose();
    //newcontroller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Take a picture')),
      body: Stack(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<void>(
            future: initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(controller!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.35,
          bottom: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () async {
                  try {
                    await initializeControllerFuture;

                    controller!.setFlashMode(FlashMode.off);

                    final image = await controller!.takePicture();
                    String dateAdd =
                        DateFormat('HH:mm:ss').format(DateTime.now());

                    var appDir =
                        (await getApplicationDocumentsDirectory()).path;
                    await image
                        .saveTo('$appDir/${widget.username}$dateAdd.jpg');

                    String imgpath = ('$appDir/${widget.username}$dateAdd.jpg');

                    Get.to(
                      () => DisplayPictureScreen(
                        imagePath: imgpath,
                        imageName: widget.username!,
                        state: widget.state!,
                        loc: widget.loc!,
                        remark: widget.remark!,
                      ),
                    );
                  } catch (e) {}
                },
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 35,
                )),
            const SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () async {
                  _toggleCameraLens();
                },
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 35,
                ))
          ]),
        )
      ]),
    );
  }

  void _toggleCameraLens() async {
    final cameras = await availableCameras();
    final lensDirection = controller!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    _initCamera(newDescription);
  }

  Future<void> _initCamera(CameraDescription description) async {
    controller = CameraController(description, ResolutionPreset.max);

    try {
      await controller!.initialize();
      setState(() {});
    } catch (e) {}
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String? imagePath;
  final String? imageName;
  final String? state;
  final String? loc;
  final String? remark;
  const DisplayPictureScreen(
      {Key? key,
      @required this.imagePath,
      @required this.imageName,
      @required this.state,
      @required this.loc,
      @required this.remark})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final Location location = Location();

  void pickFile() async {
    DateTime currentTimePick = DateTime.now();
    var updatedDate = DateFormat('yyyy-MM-dd').format(currentTimePick);
    var updatedTime = DateFormat('HH:mm:ss').format(currentTimePick);

    var location2 = await location.getLocation();

    _uploadFile(
        File(widget.imagePath!),
        updatedDate,
        updatedTime,
        "${location2.latitude}",
        "${location2.longitude}",
        widget.remark!,
        widget.loc!);
  }

  Future _uploadFile(File imgFile, String date, String time, String lat,
      String long, String remark, String loc) async {
    try {
      var response = await Api.putFile(
          '${globals.applictionRootUrl}API/${widget.state == "Login" ? "CheckInWithPhoto" : "CheckOutWithPhoto"}',
          imgFile,
          date,
          time,
          lat,
          long,
          remark,
          loc);

      if (response.statusCode == 200) {
        if (widget.state == 'Login') {
          varController.loginVisible.value = false;
          varController.logoutVisible.value = true;
          varController.subloginVisible.value = true;
          if ((globals.isGPS || globals.isleaveGPS) && (globals.isEmpGpsOn)) {
            timer();
          }
        } else {
          varController.loginVisible.value = true;
          varController.logoutVisible.value = false;
          varController.subloginVisible.value = false;
          if ((globals.isGPS || globals.isleaveGPS) && (globals.isEmpGpsOn)) {
            if (streamSubscription != null) {
              streamSubscription!.cancel();
            }
            await location.enableBackgroundMode(enable: false);
          }
        }
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        NotificationService.showNoti(
          id: 1,
          title: 'Payroll',
          body: 'Image Uploaded Successfully',
          payload: 'img',
        );
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        NotificationService.showNoti(
          id: 1,
          title: 'Payroll',
          body: 'Something went wrong',
          payload: 'img',
        );
      }
    } catch (exception) {
      return null;
    }
  }

  timer() async {
    // await location.enableBackgroundMode(enable: true);
    streamSubscription = await GpsLogServices.initPlatformState();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(centerTitle: true, title: const Text('Login/Logout Image')),
      body: Stack(children: [
        Image.file(
          File(widget.imagePath!),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.35,
          bottom: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 35,
                )),
            const SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () async {
                  Get.snackbar('', 'Uploading Image To Server...',
                      backgroundColor: Colors.white,
                      colorText: Colors.black,
                      snackPosition: SnackPosition.BOTTOM);

                  pickFile();
                },
                icon: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                  size: 35,
                )),
          ]),
        ),
      ]),
    );
  }
}
