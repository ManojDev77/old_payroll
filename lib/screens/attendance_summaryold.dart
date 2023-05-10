// import 'package:flutter/material.dart';
// import 'package:payroll/widgets/loader_dialog.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:payroll/screens/locate_user.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'globals.dart' as globals;
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// final Map<DateTime, List> _holidays = {
//   DateTime(2019, 1, 1): ['New Year\'s Day'],
//   DateTime(2019, 1, 6): ['Epiphany'],
//   DateTime(2019, 2, 14): ['Valentine\'s Day'],
//   DateTime(2019, 4, 21): ['Easter Sunday'],
//   DateTime(2019, 11, 18): ['Easter Monday'],
//   DateTime(2019, 12, 25): ['Christmas Eve'],
// };
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// class AttendanceSummaryOld extends StatefulWidget {
//   const AttendanceSummaryOld({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _AttendanceSummaryOldState createState() => _AttendanceSummaryOldState();
// }

// class _AttendanceSummaryOldState extends State<AttendanceSummaryOld>
//     with TickerProviderStateMixin {
//   Map<DateTime, List> _events;
//   // List _selecteddatetimeList = [];

//   List<LocationModel> _selecteddatetimeList = [];
//   TextEditingController searchcontroller = TextEditingController();
//   List<LocationModel> searchList = [];
//   List<LocationModel> datetimelist = [];
//   List _selecteddatetime;
//   AnimationController _animationController;
//   CalendarController _calendarController;
//   double locateuseradminLat;
//   double locateuseradminLong;
//   double locateuseremp;

//   @override
//   void initState() {
//     getcheckInandOutData(DateTime.now());

//     initializeDateFormatting();
//     final _selectedDay = DateTime.now();

//     _events = {};

//     _selecteddatetime = _events[_selectedDay] ?? [];
//     _calendarController = CalendarController();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _animationController.forward();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _calendarController.dispose();
//     super.dispose();
//   }

//   void _onDaySelected(DateTime day, List events) {
//     onLoadingDialog(context);
//     // AttendanceDatabase.getAttendanceListOfParticularDateBasedOnUID(
//     //         widget.user.uid, day)
//     //     .then((AttendanceList attendanceList) {
//     //   print(attendanceList.attendanceList);
//     //   attendanceList.attendanceList.forEach((Attendance attendance) {
//     //     print(attendance.office);
//     //     events.add(
//     //         "Type: ${attendance.type.toString().split('.').last} Time: ${attendance.time.hour} hours ${attendance.time.minute} minutes at ${attendance.office} ");
//     //     setState(() {
//     //       _selectedEvents = events;
//     //     });
//     //   });

//     //   if (attendanceList.attendanceList.length == 0) {
//     //     setState(() {
//     //       _selectedEvents = [];
//     //     });
//     //   }

//     //   Navigator.of(context, rootNavigator: true).pop('dialog');
//     // });
//   }

//   void _onVisibleDaysChanged(
//       DateTime first, DateTime last, CalendarFormat format) {
//     print('$first $last');
//   }

//   Future getcheckInandOutData(DateTime now) async {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//     String formattedTime = DateFormat('hh:mm:ss').format(now);
//     String query = globals.applictionRootUrl +
//         'API/CheckInOUTHistory?DBName=' +
//         globals.databaseName +
//         '&UserId=' +
//         globals.userId.toString() +
//         '&Date=' +
//         formattedDate +
//         '&Time=' +
//         formattedTime.toString();

//     final http.Response response = await http.post(
//       Uri.parse(query),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       var list = jobject;

//       var mainList = list.map((e) => LocationModel.fromJson(e)).toList();

//       // if (globals.isEmployee) {
//       //   _selecteddatetime.forEach((element) {
//       //     _selecteddatetimeList.add(element["Loginstatus"] +
//       //         "  :  " +
//       //         element["LoginoutDate"] +
//       //         " - " +
//       //         element["LoginoutTime"]);
//       //   });
//       // } else {
//       //   _selecteddatetime.forEach((element) {
//       //     locateuseradminLat = jobject["lat"];
//       //     locateuseradminLong = jobject["longitude"];

//       //     _selecteddatetimeList.add(element["EmployeeName"] +
//       //         "  :  " +
//       //         element["Loginstatus"] +
//       //         "  :  " +
//       //         element["LoginoutDate"] +
//       //         " - " +
//       //         element["LoginoutTime"]);
//       //   });
//       // }
//       if (mounted) {
//         setState(() {
//           // mainLeaveList = List<LeaveModel>.from(mainList);
//           _selecteddatetimeList = List<LocationModel>.from(mainList);
//           datetimelist = _selecteddatetimeList;
//           // isLoaded = true;
//         });
//       }
//     }
//   }

//   void showInSnackBar(String value) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(value),
//       duration: const Duration(seconds: 5),
//       behavior: SnackBarBehavior.floating,
//     ));
//   }

//   onSearchTextChanged(String text) async {
//     searchList.clear();
//     // if (text.isEmpty) {
//     //   setState(() {});
//     //   return;
//     // }
//     // isSearch = true;
//     for (var detail in datetimelist) {
//       if (detail.empname.toLowerCase().contains(text)) searchList.add(detail);
//     }
//     if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
//       _selecteddatetimeList = searchList;
//     } else {
//       _selecteddatetimeList = datetimelist;
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     //Timer.periodic(Duration(seconds: 1),(Timer t) => );

//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           color: Colors.blue[500],
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: <Widget>[
//               Container(
//                 color: Theme.of(context).primaryColor,
//                 child: Padding(
//                   padding: const EdgeInsets.all(3.0),
//                   child: Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.search),
//                       title: TextField(
//                         autofocus: false,
//                         controller: searchcontroller,
//                         decoration: const InputDecoration(
//                             hintText: 'Search', border: InputBorder.none),
//                         onChanged: onSearchTextChanged,
//                       ),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.cancel),
//                         onPressed: () {
//                           // isSearch = false;
//                           searchcontroller.clear();
//                           onSearchTextChanged('');
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // _buildTableCalendarWithBuilders(),
//               const SizedBox(height: 8.0),
//               const SizedBox(height: 8.0),
//               Expanded(child: _buildEventList()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTableCalendarWithBuilders() {
//     return TableCalendar(
//       locale: 'en_US',
//       calendarController: _calendarController,
//       events: _events,
//       holidays: _holidays,
//       initialCalendarFormat: CalendarFormat.month,
//       formatAnimation: FormatAnimation.slide,
//       startingDayOfWeek: StartingDayOfWeek.sunday,
//       availableGestures: AvailableGestures.all,
//       availableCalendarFormats: const {
//         CalendarFormat.month: '',
//         CalendarFormat.week: '',
//       },
//       calendarStyle: CalendarStyle(
//         outsideDaysVisible: true,
//         weekdayStyle: const TextStyle().copyWith(color: Colors.white),
//         weekendStyle: const TextStyle().copyWith(color: Colors.grey),
//         holidayStyle: const TextStyle().copyWith(color: Colors.white),
//         outsideWeekendStyle: const TextStyle().copyWith(color: Colors.grey),
//         outsideStyle: const TextStyle().copyWith(color: Colors.grey),
//       ),
//       daysOfWeekStyle: DaysOfWeekStyle(
//         weekdayStyle: const TextStyle().copyWith(color: Colors.white),
//         weekendStyle: const TextStyle().copyWith(color: Colors.white),
//       ),
//       headerStyle: const HeaderStyle(
//         leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white60),
//         rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white60),
//         titleTextStyle: TextStyle(
//             color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
//         centerHeaderTitle: true,
//         formatButtonVisible: false,
//       ),
//       builders: CalendarBuilders(
//         selectedDayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               margin: const EdgeInsets.all(4.0),
//               padding: const EdgeInsets.only(top: 11.0, left: 12.0),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.amber[500],
//               ),
//               width: 100,
//               height: 100,
//               child: Text(
//                 '${date.day}',
//                 style: const TextStyle().copyWith(
//                     fontSize: 18.0,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//           );
//         },
//         todayDayBuilder: (context, date, _) {
//           return Container(
//             margin: const EdgeInsets.all(4.0),
//             padding: const EdgeInsets.only(top: 11.0, left: 12.0),
//             width: 100,
//             height: 100,
//             child: Text(
//               '${date.day}',
//               style: const TextStyle().copyWith(
//                   fontSize: 18.0,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold),
//             ),
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color.fromRGBO(29, 209, 161, 1.0),
//             ),
//           );
//         },
//         markersBuilder: (context, date, events, holidays) {
//           final children = <Widget>[];

//           if (events.isNotEmpty) {
//             children.add(
//               Positioned(
//                 right: 1,
//                 bottom: 1,
//                 child: _buildEventsMarker(date, events),
//               ),
//             );
//           }

//           if (holidays.isNotEmpty) {
//             children.add(
//               Positioned(
//                 right: -2,
//                 top: -2,
//                 child: _buildHolidaysMarker(),
//               ),
//             );
//           }

//           return children;
//         },
//       ),
//       onDaySelected: (date, events, abc) {
//         // _onDaySelected(date, events);
//         getcheckInandOutData(date);
//         _animationController.forward(from: 0.0);
//       },
//       onVisibleDaysChanged: _onVisibleDaysChanged,
//     );
//   }

//   Widget _buildEventsMarker(DateTime date, List events) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: _calendarController.isSelected(date)
//             ? Colors.brown[500]
//             : _calendarController.isToday(date)
//                 ? Colors.brown[300]
//                 : Colors.blue[400],
//       ),
//       width: 16.0,
//       height: 16.0,
//       child: Center(
//         child: Text(
//           '${events.length}',
//           style: const TextStyle().copyWith(
//             color: Colors.white,
//             fontSize: 12.0,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHolidaysMarker() {
//     return const Icon(
//       Icons.weekend,
//       size: 20.0,
//       color: Colors.blueGrey,
//     );
//   }

//   Widget _buildEventList() {
//     return _selecteddatetimeList.isNotEmpty
//         ? ListView(
//             children: _selecteddatetimeList.reversed
//                 .map((event) => Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(width: 2, color: Colors.white),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 8.0, vertical: 7.0),
//                       child: ListTile(
//                         title: Text(
//                           (!globals.isEmployee
//                               ? event.empname +
//                                   "  :  " +
//                                   event.loginstatus +
//                                   "  :  " +
//                                   event.loginoutdate +
//                                   "  -  " +
//                                   event.logininouttime +
//                                   "         Remark : " +
//                                   event.remark
//                               : event.empname +
//                                   "  :  " +
//                                   event.loginstatus +
//                                   "  :  " +
//                                   event.loginoutdate +
//                                   "  -  " +
//                                   event.logininouttime +
//                                   "         Remark : " +
//                                   event.remark),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (BuildContext context) =>
//                                   LocateUserWidget(
//                                       latitude: event.latitude,
//                                       longitude: event.longitude)));
//                         },
//                       ),
//                     ))
//                 .toList(),
//           )
//         : Padding(
//             padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 100),
//             child: Text(
//               "No records found".toUpperCase(),
//               style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 20,
//                   fontFamily: "poppins-medium"),
//             ),
//           );
//   }
// }

// class LocationModel {
//   const LocationModel({
//     this.empname,
//     this.loginstatus,
//     this.loginoutdate,
//     this.logininouttime,
//     this.latitude,
//     this.longitude,
//     this.remark,
//   });
//   final String empname;
//   final String loginstatus;
//   final String loginoutdate;
//   final String logininouttime;
//   final double latitude;
//   final double longitude;
//   final String remark;
//   factory LocationModel.fromJson(Map<String, dynamic> json) {
//     return LocationModel(
//       empname: json['EmployeeName'] ?? "",
//       loginstatus: json['Loginstatus'] ?? "",
//       loginoutdate: json['LoginoutDate'] ?? "",
//       logininouttime: json['LoginoutTime'] ?? "",
//       latitude: json['lat'] == null ? 0 : json['lat'] + 0.0,
//       longitude: json['longitude'] == null ? 0 : json['longitude'] + 0.0,
//       remark: json['remark'] ?? "",
//     );
//   }
// }
