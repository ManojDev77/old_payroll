import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../constants/style.dart';
import '../services/notification_service.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceWithOutLocation extends StatefulWidget {
  const AttendanceWithOutLocation({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _AttendanceWithOutLocationState createState() =>
      _AttendanceWithOutLocationState();
}

class _AttendanceWithOutLocationState extends State<AttendanceWithOutLocation> {
  List<LocationModel> _selecteddatetimeList = [];
  TextEditingController searchcontroller = TextEditingController();
  List<LocationModel> searchList = [];
  List<LocationModel> datetimelist = [];
  double? locateuseradminLat;
  double? locateuseradminLong;
  double? locateuseremp;
  String empValue = "";
  List<DropdownMenuItem<String>> empList = [];
  List<EmployeeId> mainEmployeeList = [];
  List<dynamic> empitem = [];
  bool isLoaded = false;
  int? masterID;
  DateTime? currentTime;
  String? updatedTime;
  String placeValue = "";
  String subplaceValue = "";
  List<DropdownMenuItem<String>> placeList = [];
  List<DropdownMenuItem<String>> subplaceList = [];
  TextEditingController remarkController = TextEditingController();
  TextEditingController remarkController2 = TextEditingController();
  TextEditingController remarkController3 = TextEditingController();
  List values = [];
  List valueslogin = [];
  String? logintimedisp;
  String? logouttimedisp;
  DateTime? currentDate;
  String? updatedDate;
  String? checkinoutStatus;
  String? checksubinoutStatus;
  String? checkinoutSubStatus;
  bool loginVisible = true;
  bool subloginVisible = false;
  bool logoutVisible = false;
  bool loginSubVisible = true;
  bool logoutSubVisible = true;
  @override
  void initState() {
    checkInOutStatuss();
    checkInOutSubStatuss();
    // isLoggedInFromWeb();
    _getEmployeeData();
    getcheckInandOutData();
    _getLocationData();
    _getSubLocationData();
    _checkalreadylogin();

    initializeDateFormatting();

    super.initState();
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getcheckInandOutData() async {
    isLoaded = false;
    String formattedDate = "";
    String formattedTime;
    if (getdate() == "Select Date") {
      formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      formattedTime = DateFormat('hh:mm:ss').format(DateTime.now());
    } else {
      formattedDate = getdate().split('-').reversed.join("-");
      formattedTime = DateFormat('hh:mm:ss').format(DateTime.now());
    }

    String userid = "";

    if (globals.isEmployee) {
      setState(() {
        userid = globals.userId.toString();
      });
    } else {
      if (empValue == "") {
        userid = globals.userId.toString();
      } else {
        setState(() {
          userid = empValue;
        });
      }
    }

    String query =
        '${globals.applictionRootUrl}${userid == "-1" ? 'API/CheckInOUTHistory?DBName=' : 'API/CheckInOUTHistoryUpdated?DBName='}${globals.databaseName}&UserId=${userid == "-1" ? globals.userId.toString() : userid}&Date=$formattedDate&Time=$formattedTime';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    _selecteddatetimeList.clear();
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;

      var mainList = list.map((e) => LocationModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          // mainLeaveList = List<LeaveModel>.from(mainList);
          _selecteddatetimeList = List<LocationModel>.from(mainList);
          datetimelist = _selecteddatetimeList;
          // isLoaded = true;
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
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
      if (mounted) {
        setState(() {
          if (placeList.isNotEmpty) {
            if (placeList.length == 2) {
              placeValue = placeList[1].value!;
            } else {
              placeValue = placeList[0].value!;
            }
          }
        });
      }
    }
  }

  Future _getEmployeeData() async {
    empList.clear();
    setState(() {
      empList.add(const DropdownMenuItem(
        value: "",
        child: Text("Select"),
      ));
    });

    // setState(() {
    //   isLoaded = false;
    // });

    String query =
        '${globals.applictionRootUrl}API/TotalEmployeeList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var empitems = jobject;

      var mainList = empitems.map((e) => EmployeeId.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainEmployeeList = List<EmployeeId>.from(mainList);
        });
      }
      empitem = List.from(empitems);

      // accountitem = new List<String>.from(streetsFromJson["Text"]);
      if (mounted) {
        setState(() {
          empList.add(const DropdownMenuItem(value: "-1", child: Text("All")));

          for (var item in empitem) {
            empList.add(DropdownMenuItem(
                value: item["UserID"].toString(),
                child: Text(item["EmpName"].toString())));
          }

          if (empList.isNotEmpty) {
            if (empList.length == 2) {
              empValue = empList[1].value!;
            } else {
              empValue = empList[1].value!;
              getcheckInandOutData();
            }
          }
          // isLoaded = true;
        });
      }
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
      if (mounted) {
        setState(() {
          if (subplaceList.isNotEmpty) {
            if (subplaceList.length == 2) {
              subplaceValue = subplaceList[1].value!;
            } else {
              subplaceValue = subplaceList[0].value!;
            }
          }
        });
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

  onSearchTextChanged(String text) async {
    searchList.clear();
    // if (text.isEmpty) {
    //   setState(() {});
    //   return;
    // }
    // isSearch = true;
    for (var detail in datetimelist) {
      if (detail.empname!.toLowerCase().contains(text)) searchList.add(detail);
    }
    if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
      _selecteddatetimeList = searchList;
    } else {
      _selecteddatetimeList = datetimelist;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Attendance"),
        backgroundColor: Colors.blue[500],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height *
                    ((globals.isEmpAttendanceOn) ? 0.8 : 1),
                padding: const EdgeInsets.only(bottom: 8),
                color: Colors.white10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        onPressed: () {
                          datepicker(context);
                        },
                        child: Text("${getdate()}"),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      !globals.isEmployee
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Employee',
                                    style: ThemeText.pageHeaderBlack),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  hint: const Text("Employee"),
                                  value: empValue,
                                  // isDense: true,
                                  // isExpanded: true,
                                  elevation: 0,
                                  style: ThemeText.text,

                                  onChanged: (String? newValue) {
                                    setState(() {
                                      empValue = newValue!;
                                    });
                                    getcheckInandOutData();
                                  },
                                  items: empList,
                                ),
                              ],
                            )
                          : Row(),
                    ]),
                    const SizedBox(height: 8.0),
                    const SizedBox(height: 8.0),
                    Expanded(child: _buildEventList()),
                  ],
                ),
              ),
            ),
      bottomSheet: (globals.isEmpAttendanceOn)
          ? Container(
              color: Colors.blue,
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ((globals.isSublogin || globals.isLeaveSublogin) &&
                              globals.isEmpSubLoginOn) &&
                          subloginVisible
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _displayDialogSubLogin();
                          },
                          child: const Text(
                            "SubLogin",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : Row(),
                  const SizedBox(
                    width: 10,
                  ),
                  loginVisible
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            _displayDialog();
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : Row(),
                  !loginVisible && loginSubVisible
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            _displayDialog2();
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : Row(),
                ],
              ),
            )
          : Row(),
    );
  }

  Future checkInData() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query = globals.applictionRootUrl +
        'API/CheckIn?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&Date=' +
        formattedDate.toString() +
        '&Time=' +
        formattedTime.toString() +
        '&lat=' +
        "0" +
        '&longitude=' +
        "0" +
        '&Remarks=' +
        remarkController.text +
        '&Location=' +
        placeValue;
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
        getcheckInandOutData();
        setState(() {
          loginVisible = false;
          logoutVisible = true;
          subloginVisible = true;
          globals.isAttendanceLoggedIn = true;
        });
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query = globals.applictionRootUrl +
        'API/SubLogIn?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&MasterLoginId=' +
        masterID.toString() +
        '&Date=' +
        formattedDate +
        '&Time=' +
        formattedTime.toString() +
        '&lat=' +
        "0" +
        '&longitude=' +
        "0" +
        '&Remarks=' +
        remarkController.text +
        '&Location=' +
        subplaceValue;
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
        setState(() {
          loginSubVisible = false;
          logoutSubVisible = true;
          logoutVisible = false;
        });
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query = globals.applictionRootUrl +
        'API/CheckOut?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&Date=' +
        formattedDate +
        '&Time=' +
        formattedTime.toString() +
        '&lat=' +
        "0" +
        '&longitude=' +
        "0" +
        '&Remarks=' +
        remarkController2.text +
        '&Location=' +
        placeValue;
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
        getcheckInandOutData();
        setState(() {
          loginVisible = true;
          logoutVisible = false;
          subloginVisible = false;
          globals.isAttendanceLoggedIn = false;
          // sharedpref.setBoolExtra("isloggedin", false);
        });
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String query = globals.applictionRootUrl +
        'API/SubLogOut?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&MasterLoginId=' +
        masterID.toString() +
        '&Date=' +
        formattedDate +
        '&Time=' +
        formattedTime.toString() +
        '&lat=' +
        "0" +
        '&longitude=' +
        "0" +
        '&Remarks=' +
        remarkController2.text +
        '&Location=' +
        subplaceValue;
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
        setState(() {
          loginSubVisible = true;
          logoutSubVisible = false;
          logoutVisible = true;
        });
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
      //  setState(() {});
    }
  }

  Future<String> checkInOutStatuss() async {
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/CheckInOutStatus?DBName=${globals.databaseName}&UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      checkinoutStatus = jobject["Item1"];
      masterID = jobject["Item2"];

      if (checkinoutStatus == 'Logged In') {
        print("${checkinoutStatus!}mmmmmmmmmm");
        if (mounted) {
          setState(() {
            loginVisible = false;
            logoutVisible = true;
            subloginVisible = true;
            globals.isAttendanceLoggedIn = true;
          });
        }
      } else {
        print("${checkinoutStatus!}mmmmmmmmmm");
        if (mounted) {
          setState(() {
            loginVisible = true;
            logoutVisible = false;
            subloginVisible = false;
            globals.isAttendanceLoggedIn = false;
          });
        }
      }
    }
    return checkinoutStatus ?? "";
    // setState(() {});
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
      checksubinoutStatus = jobject;
      if (checksubinoutStatus == "Logged In") {
        if (mounted) {
          setState(() {
            loginSubVisible = false;
            logoutSubVisible = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loginSubVisible = true;
            logoutSubVisible = false;
          });
        }
      }
    }
    // setState(() {});
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
                title: const Text('Remark'),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        autofocus: false,
                        controller: remarkController,
                        //onSubmitted: _giveData(emailController),
                        decoration: const InputDecoration(
                          labelText: "Remarks",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Text("Location",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                      DropdownButton<String>(
                        value: placeValue,
                        isExpanded: true,

                        // icon: Icon(
                        //   Icons.arrow_drop_down,
                        // ),
                        // iconSize: 30,
                        elevation: 20,

                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
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

                            Navigator.pop(context);
                            _callMarkInFunction();
                          },
                          child: const Text('Login',
                              style: TextStyle(color: Colors.white)))
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
                title: const Text('Remark'),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        autofocus: false,
                        controller: remarkController2,
                        //onSubmitted: _giveData(emailController),
                        decoration: const InputDecoration(
                          labelText: "Remarks",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Text("Location",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                      DropdownButton<String>(
                        value: placeValue,
                        isExpanded: true,
                        elevation: 20,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
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

                            _callMarkOutFunction();
                          },
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.white)))
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _callMarkInFunction() async {
    await checkInOutStatuss();
    if (checkinoutStatus == "Logged In") {
      setState(() {
        loginVisible = false;
        logoutVisible = true;
        subloginVisible = true;
      });
    } else {
      checkInData();
    }
  }

  void _callMarkInSubFunction() async {
    await checkInOutSubStatuss();
    // await timer();
    if (checkinoutSubStatus == "Logged In") {
      const CircularProgressIndicator(backgroundColor: Colors.green);
      setState(() {
        loginSubVisible = false;
        logoutSubVisible = true;
      });
    } else {
      checkInSubData();
    }
  }

  void _callMarkOutFunction() async {
    await checkInOutStatuss();
    if (checkinoutStatus == "Logged Out") {
      setState(() {
        loginVisible = true;
        logoutVisible = false;
        subloginVisible = false;
      });
    } else {
      checkOutData();
    }
  }

  void _callMarkOutSubFunction() async {
    await checkInOutSubStatuss();

    if (checkinoutSubStatus == "Logged Out") {
      setState(() {
        loginSubVisible = true;
        logoutSubVisible = false;
      });
    } else {
      checkOutSubData();
    }
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
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        autofocus: false,
                        controller: remarkController3,
                        //onSubmitted: _giveData(emailController),
                        decoration: const InputDecoration(
                          labelText: "Remarks",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Text("Location",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                      DropdownButton<String>(
                        value: subplaceValue,
                        isExpanded: true,
                        elevation: 20,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
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
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Visibility(
                          visible: loginSubVisible,
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
                            visible: logoutSubVisible,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _callMarkOutSubFunction();
                                },
                                child: const Text('Sub Logout',
                                    style: TextStyle(color: Colors.white))))
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  DateTime? date;
  getdate() {
    if (date == null) {
      return '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
    }
    return '${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}';
  }

  Future datepicker(BuildContext context) async {
    final initialdate = date ?? DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialdate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (newDate == null) return;

    setState(() {
      date = newDate;
    });
    getcheckInandOutData();
  }

  Widget _buildEventList() {
    return _selecteddatetimeList.isNotEmpty
        ? ListView(
            children: _selecteddatetimeList.reversed
                .map((event) => GestureDetector(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 7.0),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Name",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text("Status",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text("Remark",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  (((globals.isBiometricEnabled ||
                                              globals
                                                  .isLeaveBiometricEnabled) ||
                                          (globals.isLoginInWebAllowed ||
                                              globals
                                                  .leaveisLoginInWebAllowed)))
                                      ? const Text("Logged From",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ))
                                      : Row(),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(": ${event.empname}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(": ${event.loginstatus}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      ": ${event.loginoutdate} ${event.logininouttime}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(": ${event.remark}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
                                  // const SizedBox(
                                  //   height: 5,
                                  // ),
                                  (((globals.isBiometricEnabled ||
                                              globals
                                                  .isLeaveBiometricEnabled) ||
                                          (globals.isLoginInWebAllowed ||
                                              globals
                                                  .leaveisLoginInWebAllowed)))
                                      ? Text(
                                          ": ${event.isFromBiometric! ? "Biometric" : (event.isloggedfromweb! ? "Laptop" : "Mobile")}",
                                          style: ThemeText.text)
                                      : Row()
                                ],
                              ),
                            ],
                          ),
                        ))))
                .toList(),
          )
        : Center(
            heightFactor: 10,
            child: Text(
              "No records found".toUpperCase(),
              style:
                  const TextStyle(fontSize: 30, fontFamily: "poppins-medium"),
            ),
          );
  }
}

class LocationModel {
  const LocationModel(
      {this.empname,
      this.loginstatus,
      this.loginoutdate,
      this.logininouttime,
      this.latitude,
      this.longitude,
      this.remark,
      this.id,
      this.isloggedfromweb,
      this.isFromBiometric});
  final String? empname;
  final String? loginstatus;
  final String? loginoutdate;
  final String? logininouttime;
  final double? latitude;
  final double? longitude;
  final String? remark;
  final int? id;
  final bool? isloggedfromweb;
  final bool? isFromBiometric;
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
        empname: json['EmployeeName'] ?? "",
        loginstatus: json['Loginstatus'] ?? "",
        loginoutdate: json['LoginoutDate'] ?? "",
        logininouttime: json['LoginoutTime'] ?? "",
        latitude: json['lat'] == null ? 0 : json['lat'] + 0.0,
        longitude: json['longitude'] == null ? 0 : json['longitude'] + 0.0,
        remark: json['remark'] ?? "",
        isloggedfromweb: json['IsLoginFromLaptop'] ?? false,
        isFromBiometric: json['IsFromBiometric'] ?? false,
        id: json["Id"] ?? 0);
  }
}

class EmployeeId {
  EmployeeId({this.empid, this.userid});
  int? empid;
  int? userid;

  factory EmployeeId.fromJson(Map<String, dynamic> json) {
    return EmployeeId(
      empid: json['EmpID'] ?? 0,
      userid: json['UserID'] ?? 0,
    );
  }
}
