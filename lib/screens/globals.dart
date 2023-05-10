library myapp2.globals;

import 'package:flutter/material.dart';
import '../screens/approveList.dart';
import '../screens/attendance_summary.dart';
import 'leave_status.dart';

String taskidnew = "";
String taskdate = '';
double taskhours = 0.0;
String taskremark = "";

int meetingTabId = 0;
String subject = "";
String desc = "";
String meetingDate = "";
String noticeDate = "";

bool isEmployee = false;
bool isLeave = false;
bool isAttendance = false;
bool isLoggedIn = false;
bool isAttendanceLoggedIn = false;
bool isAutoSync = false;
bool isGPS = false;
bool isSublogin = false;
bool isLeaveSublogin = false;
bool isleaveGPS = false;
bool isLeaveAttendance = false;
bool isempcontactenabled = false;
int yearType = 0;
String databaseName = "";
String databaseId = "";
int payroll = 0;
int subMasterID = 0;
int leave = 0;
bool employeelogin = true;
// String applictionRootUrl = "";
String applictionRootUrl = "https://payrollapi.officeanywhere.io/";
//String applictionRootUrl = "https://payrollapi.rapidapps.net/";
String ofcRootUrl = "https://mobile.officeanywhere.io/OFCApi/";
//String ofcRootUrl = "https://mobile.of.radicalceo.net/OFCApi/";
// String ofcRootUrl = "https://mobile.rapidapps.net/OFCApi/";
String defaultcountrycode = "";
int userId = 0;
double totalExpense = 0;
double totalReceipt = 0;
int circularcnt = 0;
String empname = '';
int compcount = 0;
int appcount = 0;
bool istaskenabled = false;
bool loginphotocap = false;
bool isapprover = true;
bool isEmpAttendanceOn = false;
bool isEmpSubLoginOn = false;
bool isEmpGpsOn = false;
bool isWithoutLocationEnabled = false;
bool isLoginInWebAllowed = false;
bool isLoggedInInWeb = false;
bool isBiometricEnabled = false;
bool isLeaveBiometricEnabled = false;
bool leaveisWithoutLocationEnabled = false;
bool leaveisLoginInWebAllowed = false;
bool leaveisLoggedInInWeb = false;
int tabid = 0;
bool isdirectbilling = false;
bool isHolidayEnabled = false;
bool isCircularEnabled = false;
bool isMeetingEnabled = false;
bool isCalendarEnabled = false;
bool isSalaryEnabled = false;

bool isLeaveHolidayEnabled = false;
bool isLeaveCircularEnabled = false;
bool isLeaveMeetingEnabled = false;
bool isLeaveCalendarEnabled = false;
bool isLeaveempcontactenabled = false;

class KeyValuePair {
  const KeyValuePair({this.key, this.value});

  final String? value;
  final int? key;
  factory KeyValuePair.fromJson(
      Map<String, dynamic> json, String keyFieldVal, String valueFieldVal) {
    return KeyValuePair(
      key: json[keyFieldVal] ?? 0,
      value: json[valueFieldVal] == null
          ? ""
          : json[valueFieldVal].toString().trim(),
    );
  }
}

class CommonFunction {
  static getPageNavigatorFromScreenName(String name) {
    switch (name) {
      case 'leavestatus':
        return MaterialPageRoute(
            builder: (BuildContext context) => const LeaveStatusWidget(
                  empvalue: '',
                ));
      case 'approveleavelist':
        return MaterialPageRoute(
            builder: (BuildContext context) => const ApproveLeaveList());

      case 'holiday':
        return MaterialPageRoute(
            builder: (BuildContext context) => const AttendanceSummary());

      // case 'docstatus':
      //   return MaterialPageRoute(
      //       builder: (BuildContext context) => DocStatusWidget());
    }
  }
}
