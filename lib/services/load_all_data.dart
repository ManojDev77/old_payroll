import 'dart:convert';

import '../sharedpreferences.dart' as sharedpreferences;
import '../screens/globals.dart' as globals;
import 'package:http/http.dart' as http;

class LoadAllData {
  String empName = '';
  String empCode = '';
  String empDesignation = '';
  String empDepartment = '';
  String empDOJ = '';
  sharedpreferences.SharedPreferencesTest sharedpref =
      sharedpreferences.SharedPreferencesTest();
  List<NoticeModal> mainNoticeList = [];

  Future<void> refreshData() async {
    await _getuserRole();
    await noticelog();
    await _getSettingsDetailspayroll();
    await _getSettingsDetailsleave();
    await _getDashboardData();
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

  Future<void> noticelog() async {
    if (globals.isEmployee) {
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

        mainNoticeList = List<NoticeModal>.from(mainListNoti);
        for (int i = 0; i < mainNoticeList.length; i++) {
          if (mainNoticeList[i].isread == false) {}
        }
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

      var directbilling = jobject["Item2"]["SettingData"]["IsTaskDirectBill"];
      if (directbilling == true) {
        globals.isdirectbilling = true;
        sharedpref.setBoolExtra("isdirectbilling", true);
      } else {
        globals.isdirectbilling = false;
        sharedpref.setBoolExtra("isdirectbilling", false);
      }

      var logintime = jobject["Item2"]["SettingData"]["LInTime"];
      var logouttime = jobject["Item2"]["SettingData"]["LOutTime"];
      // var taskManagement = jobject["SettingData"]["TaskManagement"];

      // if (taskManagement == true) {
      //   globals.istaskenabled = true;
      //   sharedpref.setBoolExtra("istaskenabled", true);
      // } else {
      //   sharedpref.setBoolExtra("istaskenabled", false);
      // }
      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      // accountitem = new List<String>.from(streetsFromJson["Text"]);
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
        sharedpref.setBoolExtra("isLeave", true);
      } else {
        globals.isLeave = false;

        sharedpref.setBoolExtra("isLeave", false);
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
      if (directbilling == true) {
        globals.isdirectbilling = true;
        sharedpref.setBoolExtra("isdirectbilling", true);
      } else {
        globals.isdirectbilling = false;
        sharedpref.setBoolExtra("isdirectbilling", false);
      }

      if (leaveattendanceWithOutLocation == true) {
        globals.leaveisWithoutLocationEnabled = true;
        sharedpref.setBoolExtra("isWithoutlocationEnable", true);
      } else {
        globals.leaveisWithoutLocationEnabled = false;
        sharedpref.setBoolExtra("isWithoutlocationEnable", false);
      }

      if (leavelogininweb == true) {
        globals.leaveisLoginInWebAllowed = true;
        sharedpref.setBoolExtra("locationenabledinweb", true);
      } else {
        globals.leaveisLoginInWebAllowed = false;
        sharedpref.setBoolExtra("locationenabledinweb", false);
      }

      if (taskManagement == true) {
        globals.istaskenabled = true;
        sharedpref.setBoolExtra("istaskenabled", true);
      } else {
        globals.istaskenabled = false;
        sharedpref.setBoolExtra("istaskenabled", false);
      }

      if (yearType == 0) {
        globals.yearType = 0;
        sharedpref.setIntExtra("yeartype", 0);
      } else {
        globals.yearType = 1;
        sharedpref.setIntExtra("yeartype", 1);
      }

      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");

      if (leaveAttendance == true) {
        globals.isLeaveAttendance = true;
        sharedpref.setBoolExtra("isLeaveAttendance", true);
      } else {
        globals.isLeaveAttendance = false;

        sharedpref.setBoolExtra("isLeaveAttendance", false);
      }
      if (leaveSublogin == true) {
        globals.isLeaveSublogin = true;
        sharedpref.setBoolExtra("isLeaveSublogin", true);
      } else {
        globals.isLeaveSublogin = false;

        sharedpref.setBoolExtra("isLeaveSublogin", false);
      }
      if (leaveGPS == true) {
        globals.isleaveGPS = true;
        sharedpref.setBoolExtra("isleaveGPS", true);
      } else {
        globals.isleaveGPS = false;

        sharedpref.setBoolExtra("isleaveGPS", false);
      }
    }
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
