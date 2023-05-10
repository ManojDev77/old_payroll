import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/attendance_recorder.dart';
import '../screens/attendance_summary.dart';

void attendanceSummaryCallback(BuildContext context) {
  Navigator.push(
    context,
    CupertinoPageRoute(
        builder: (context) => AttendanceSummary(
              title: "Attendance Summary",
            )),
  );
}

void attendanceRecorderCallback(BuildContext context) {
  Navigator.push(context,
      CupertinoPageRoute(builder: (context) => AttendanceRecorderWidget()));
}

List<List> infoAboutTiles = [
  [
    "assets/icons/attendance_recorder.png",
    "Attendance Recorder",
    "Mark your In and Out Time",
    attendanceRecorderCallback
  ],
  [
    "assets/icons/attendance_summary.png",
    "Attendance Summary",
    "Check your previous records",
    attendanceSummaryCallback
  ],
];
