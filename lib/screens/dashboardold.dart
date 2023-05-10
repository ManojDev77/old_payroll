// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'globals.dart' as globals;
// import 'package:http/http.dart' as http;
// import 'package:payroll/screens/approveList.dart';
// import 'package:payroll/screens/leave_application.dart';
// import 'package:payroll/screens/payslip.dart';
// import 'package:payroll/screens/coloredcard.dart';
// import 'package:payroll/screens/leave_status.dart';
// import 'package:payroll/screens/attendance_summary.dart';
// import 'package:payroll/screens/document_request.dart';
// import 'package:payroll/screens/docStatus.dart';
// import 'package:payroll/screens/database.dart';
// import 'package:payroll/screens/login.dart';
// import 'package:payroll/screens/loginmodel.dart';
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:payroll/sharedpreferences.dart' as sharedpreferences;
// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';

// ProgressDialog prPleaseWait;
// const _myListOfRandomColors = [
//   Colors.red,
//   Colors.blue,
//   Colors.teal,
//   Colors.amber,
//   Colors.deepOrange,
//   Colors.green,
//   Colors.indigo,
//   Colors.pink,
//   Colors.orange,
//   Colors.purple,
//   Colors.brown,
// ];

// final _random = Random();
// List<Color> colors = [];
// List<DropdownMenuItem<String>> companyDropdownitems = [];
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// sharedpreferences.SharedPreferencesTest sharedpref =
//     sharedpreferences.SharedPreferencesTest();
// List<AppListModel> applist = [];
// List<LoginProfile> loginList = [];
// String companydropdownValue = '';
// String appdropdownValue = '';

// class LandingPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Payroll',
//       theme: ThemeData(fontFamily: 'VarelaRound'),
//       home: BuildLandingPage(),
//     );
//   }
// }

// class BuildLandingPage extends StatelessWidget {
//   @override
//   Widget build(context) {
//     // Either Material or Cupertino widgets work in either Material or Cupertino
//     // Apps.
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: const Text("Payroll"),
//       ),
//       drawer: _AndroidDrawer(),
//       body: Container(
//         child: MyHomePage(),
//       ),
//     );
//     // return MaterialApp(
//     //   title: 'Contacts App',
//     //   theme: ThemeData(
//     //     // Use the green theme for Material widgets.
//     //     primarySwatch: Colors.blue,
//     //   ),
//     //   builder: (context, child) {
//     //     return CupertinoTheme(
//     //       // Instead of letting Cupertino widgets auto-adapt to the Material
//     //       // theme (which is green), this app will use a different theme
//     //       // for Cupertino (which is blue by default).
//     //       data: CupertinoThemeData(),
//     //       child: Material(child: child),
//     //     );
//     //   },
//     //   home: PlatformAdaptingHomePage(),
//     // );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   bool isLoaded = false;
//   int employeeCount = 0;
//   int holyInMonth = 0;
//   int newlyJoined = 0;
//   int leftEmployee = 0;
//   int leaveRqstCount = 0;
//   int todayLeave = 0;
//   int upLeaveCount = 0;
//   int pendingDocRqstCount = 0;
//   String nextpage = '';
//   @override
//   void initState() {
//     _getDashboardData();
//     loadLoginProfiles();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future loadLoginProfiles() async {
//     loginList.clear();
//     loginList = await DBProvider.db.getAllLoginProfile();
//   }

//   Future _notificationTokenSubmit(String token) async {
//     String query = globals.applictionRootUrl +
//         'API/NotificationTokenSubmit?DBName=' +
//         globals.databaseName +
//         '&UserId=' +
//         globals.userId.toString() +
//         '&TokenId=' +
//         token;
//     final http.Response response = await http.post(
//       Uri.parse(query),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());

//       setState(() {});
//     }
//   }

//   Future _notificationTokenDelete(String token) async {
//     String query = globals.applictionRootUrl +
//         'API/NotificationTokenSubmit?DBName=' +
//         globals.databaseName +
//         '&UserId=' +
//         globals.userId.toString() +
//         '&TokenId=' +
//         token;
//     final http.Response response = await http.post(
//       Uri.parse(query),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());

//       setState(() {});
//     }
//   }

//   Future _getDashboardData() async {
//     monthList.clear();
//     monthList.add(const DropdownMenuItem(
//       child: Text("Select"),
//       value: "",
//     ));
//     setState(() {
//       isLoaded = false;
//     });
//     String query = globals.applictionRootUrl +
//         'API/AdminOnLoadDashboardData?DBName=' +
//         globals.databaseName +
//         '&userId=' +
//         globals.userId.toString();
//     final http.Response response = await http.post(
//       Uri.parse(query),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());

//       // var balance = jobject["DashboardData"]["totalBalance"];

//       // var recieptamount = jobject["DashboardData"]["totalRec"];
//       // var expamount = jobject["DashboardData"]["totalExp"];
//       // List responseJson =
//       //     json.decode(jobject["DashboardData"]["PettyAccountList"]);
//       // if (responseJson.isNotEmpty) {
//       //   accountitem = responseJson
//       //       .map((e) => e["DashboardData"]["PettyAccountList"].toString())
//       //       .toList();
//       // }
//       var monthitem = jobject["Monthlist"];
//       var balance = jobject["TotalEmployeeCount"];
//       var leaverqstCount = jobject["PendingLeaveRequestCount"];
//       var todayOnLv = jobject["TodayOnLeaveCount"];
//       var upLeaveCt = jobject["UpcomingLeaveCount"];
//       var pendingDocrqstCount = jobject["PendingDocumentRequestCount"];
//       // accountitem = new List<String>.from(streetsFromJson["Text"]);
//       setState(() {
//         employeeCount = balance;
//         leaveRqstCount = leaverqstCount;
//         todayLeave = todayOnLv;
//         upLeaveCount = upLeaveCt;
//         pendingDocRqstCount = pendingDocrqstCount;

//         monthitem.forEach((item) {
//           monthList.add(DropdownMenuItem(
//               child: Text(item["MonthYearName"].toString()),
//               value: item["MonthID"].toString()));
//         });

//         if (monthList.isNotEmpty) {
//           if (monthList.length == 2) {
//             monthValue = monthList[1].value;
//           } else {
//             monthValue = monthList[0].value;
//           }
//         }
//         isLoaded = true;
//       });
//     }
//   }

//   String monthValue = "";
//   List<DropdownMenuItem<String>> monthList = [];
//   Future _getFilterDashboardData() async {
//     isLoaded = false;

//     final http.Response response = await http.post(
//       Uri.parse(globals.applictionRootUrl +
//           'API/AdminOnSelectionDashboardData?DBName=' +
//           globals.databaseName +
//           '&UserId=' +
//           globals.userId.toString() +
//           '&MonthId=' +
//           monthValue),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       var holidayInMonth = jobject["HolidaysInMonth"];
//       var todayOnLeave = jobject["TodayOnLeaveCount"];
//       var pendingDocreq = jobject["PendingDocumentRequestCount"];
//       var upcommingLeaveCount = jobject["PendingDocumentRequestCount"];
//       var newjoined = jobject["NewlyJoined"];
//       var leftEmp = jobject["LeftEmployees"];

//       //     json.decode(jobject["DashboardData"]["PettyAccountList"]);
//       // if (responseJson.isNotEmpty) {
//       //   accountitem = responseJson
//       //       .map((e) => e["DashboardData"]["PettyAccountList"].toString())
//       //       .toList();
//       // }
//       // accountitem = new List<String>.from(streetsFromJson["Text"]);
//       setState(() {
//         isLoaded = true;
//         holyInMonth = holidayInMonth;
//         newlyJoined = newjoined;

//         leftEmployee = leftEmp;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color primaryColor = Colors.blue;

//     return FutureBuilder(builder: (context, snapshot) {
//       if (!isLoaded) {
//         return const Center(
//           child: CircularProgressIndicator(backgroundColor: Colors.green),
//         );
//       } else {
//         return Scaffold(
//           backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       color: primaryColor,
//                       border: Border.all(color: primaryColor)),
//                 ),
//                 Stack(
//                   children: <Widget>[
//                     ClipPath(
//                       clipper: CustomShapeClipper(),
//                       child: Container(
//                         height: 350.0,
//                         decoration: BoxDecoration(color: primaryColor),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 25.0, vertical: 20.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 employeeCount.toString(),
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 30.0,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 15.0),
//                               const Text(
//                                 'Total Employees',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 14.0),
//                               )
//                             ],
//                           ),
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Material(
//                                   elevation: 1.0,
//                                   borderRadius: BorderRadius.circular(100.0),
//                                   color: Colors.blue[300],
//                                   child: MaterialButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 Payslipdownload()),
//                                       );
//                                     },
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 10.0, horizontal: 20.0),
//                                     child: const Text(
//                                       'PAYSLIP',
//                                       // MarkAttendance
//                                       style: TextStyle(
//                                           fontSize: 16.0, color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   // padding: EdgeInsets.all(0.0),
//                                   icon: const Icon(Icons.refresh),
//                                   color: Colors.white,
//                                   iconSize: 26.0,
//                                   onPressed: () {
//                                     _getDashboardData();
//                                   },
//                                 )
//                               ]),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 120.0, right: 25.0, left: 25.0),
//                       child: Container(
//                         width: double.infinity,
//                         height: globals.isEmployee ? 170.0 : 370.0,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(20.0)),
//                             boxShadow: [
//                               BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   offset: const Offset(0.0, 3.0),
//                                   blurRadius: 15.0)
//                             ]),
//                         child: Column(
//                           children: <Widget>[
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10.0, vertical: 35.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: <Widget>[
//                                   Column(
//                                     children: <Widget>[
//                                       Material(
//                                         borderRadius:
//                                             BorderRadius.circular(100.0),
//                                         color: Colors.purple.withOpacity(0.1),
//                                         child: IconButton(
//                                           padding: const EdgeInsets.all(7.0),
//                                           icon: const Icon(Icons.person_add),
//                                           color: Colors.purple,
//                                           iconSize: 35.0,
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const LeaveApplicationWidget(
//                                                         mainId: 0,
//                                                         empname: '',
//                                                       )),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(height: 11.0),
//                                       const Text('Leave/EX Request',
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontWeight: FontWeight.bold))
//                                     ],
//                                   ),
//                                   Column(
//                                     children: <Widget>[
//                                       Material(
//                                         borderRadius:
//                                             BorderRadius.circular(100.0),
//                                         color: Colors.blue.withOpacity(0.1),
//                                         child: IconButton(
//                                           padding: const EdgeInsets.all(7.0),
//                                           icon: const Icon(Icons.art_track),
//                                           color: Colors.blue,
//                                           iconSize: 35.0,
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const LeaveStatusWidget(
//                                                         empvalue: '',
//                                                       )),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10.0),
//                                       const Text('Leave Status',
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontWeight: FontWeight.bold))
//                                     ],
//                                   ),
//                                   Column(
//                                     children: <Widget>[
//                                       Material(
//                                         borderRadius:
//                                             BorderRadius.circular(100.0),
//                                         color:
//                                             Colors.deepPurple.withOpacity(0.1),
//                                         child: IconButton(
//                                           padding: const EdgeInsets.all(7.0),
//                                           icon: const Icon(Icons.beach_access),
//                                           color: Colors.deepPurple,
//                                           iconSize: 35.0,
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const AttendanceSummary()),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10.0),
//                                       const Text('  Holidays    ',
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontWeight: FontWeight.bold))
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                             // Padding(
//                             //   padding: EdgeInsets.symmetric(
//                             //       horizontal: 10.0, vertical: 10),
//                             //   child: Row(
//                             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             //     children: <Widget>[
//                             //       Column(
//                             //         children: <Widget>[
//                             //           Material(
//                             //             borderRadius: BorderRadius.circular(100.0),
//                             //             color: Colors.pink.withOpacity(0.1),
//                             //             child: IconButton(
//                             //               padding: EdgeInsets.all(7.0),
//                             //               icon: Icon(Icons.check_circle),
//                             //               color: Colors.pink,
//                             //               iconSize: 35.0,
//                             //               onPressed: () {
//                             //                 Navigator.of(context).push(
//                             //                     MaterialPageRoute(
//                             //                         builder:
//                             //                             (BuildContext context) =>
//                             //                                 ApproveLeaveList()));
//                             //               },
//                             //             ),
//                             //           ),
//                             //           SizedBox(height: 10.0),
//                             //           Text('Leave/EX Approval',
//                             //               style: TextStyle(
//                             //                   color: Colors.black54,
//                             //                   fontWeight: FontWeight.bold))
//                             //         ],
//                             //       ),
//                             //       Column(
//                             //         children: <Widget>[
//                             //           Material(
//                             //             borderRadius: BorderRadius.circular(100.0),
//                             //             color: Colors.purpleAccent.withOpacity(0.1),
//                             //             child: IconButton(
//                             //               padding: EdgeInsets.all(7.0),
//                             //               icon: Icon(Icons.credit_card),
//                             //               color: Colors.purpleAccent,
//                             //               iconSize: 35.0,
//                             //               onPressed: () {
//                             //                 Navigator.of(context).push(
//                             //                     MaterialPageRoute(
//                             //                         builder:
//                             //                             (BuildContext context) =>
//                             //                                 DocumentRequestWidget(
//                             //                                   mainId: 0,
//                             //                                 )));
//                             //               },
//                             //             ),
//                             //           ),
//                             //           SizedBox(height: 10.0),
//                             //           Text('Doc Request',
//                             //               style: TextStyle(
//                             //                   color: Colors.black54,
//                             //                   fontWeight: FontWeight.bold))
//                             //         ],
//                             //       ),
//                             //       Column(
//                             //         children: <Widget>[
//                             //           Material(
//                             //             borderRadius: BorderRadius.circular(100.0),
//                             //             color: Colors.orange.withOpacity(0.1),
//                             //             child: IconButton(
//                             //               padding: EdgeInsets.all(7.0),
//                             //               icon: Icon(Icons.list),
//                             //               color: Colors.orange,
//                             //               iconSize: 35.0,
//                             //               onPressed: () {
//                             //                 Navigator.of(context).push(
//                             //                     MaterialPageRoute(
//                             //                         builder:
//                             //                             (BuildContext context) =>
//                             //                                 AproveDocList()));
//                             //               },
//                             //             ),
//                             //           ),
//                             //           SizedBox(height: 10.0),
//                             //           Text('   Doc List    ',
//                             //               style: TextStyle(
//                             //                   color: Colors.black54,
//                             //                   fontWeight: FontWeight.bold))
//                             //         ],
//                             //       )
//                             //     ],
//                             //   ),
//                             // ),
//                             // SizedBox(height: 15.0),
//                             // Divider(),
//                             // SizedBox(height: 15.0),
//                             // Padding(
//                             //   padding: EdgeInsets.symmetric(horizontal: 25.0),
//                             //   child: Column(
//                             //     children: <Widget>[
//                             //       Padding(
//                             //           padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
//                             //           child: Text("Select Month",
//                             //               style: TextStyle(
//                             //                   color: Colors.blue,
//                             //                   fontSize: 16,
//                             //                   fontWeight: FontWeight.bold))),
//                             //       DropdownButton<String>(
//                             //         value: monthValue,
//                             //         isExpanded: true,

//                             //         // icon: Icon(
//                             //         //   Icons.arrow_drop_down,
//                             //         // ),
//                             //         // iconSize: 30,
//                             //         elevation: 20,

//                             //         style: TextStyle(color: Colors.deepPurple),
//                             //         underline: Container(
//                             //           height: 2,
//                             //           color: Colors.deepPurpleAccent,
//                             //         ),
//                             //         onChanged: (String newValue) {
//                             //           setState(() {
//                             //             monthValue = newValue;
//                             //           });
//                             //           _getFilterDashboardData();
//                             //         },
//                             //         items: monthList,
//                             //       )
//                             //     ],
//                             //   ),
//                             // ),
//                             adminWidget()
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 10.0, right: 10, top: 10, bottom: 25.0),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 20.0),
//                     height: 220,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: <Widget>[
//                         cardWidget(),
//                         SizedBox(
//                           width: 320.0,
//                           child: ColoredCard(
//                             headerColor: const Color(0xFF4581c0),
//                             footerColor: const Color(0xFF6078dc),
//                             cardHeight: 220,
//                             borderRadius: 30,
//                             bodyColor: const Color(0xFF6c8df6),
//                             showHeader: true,
//                             showFooter: false,
//                             bodyGradient: LinearGradient(
//                               colors: [
//                                 const Color(0xFF82abe1).withOpacity(1),
//                                 const Color(0xFF4183cd),
//                                 const Color(0xFF166dbd),
//                               ],
//                               begin: Alignment.bottomLeft,
//                               end: Alignment.topRight,
//                               stops: const [0, 0.2, 1],
//                             ),
//                             headerBar: HeaderBar(
//                               title: const Text(
//                                 "Leave Details",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: "Poppins",
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               action: IconButton(
//                                 icon: const Icon(
//                                   Icons.account_balance_wallet,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () => print("header button"),
//                               ),
//                             ),
//                             bodyContent: Padding(
//                               padding: const EdgeInsets.only(
//                                 left: 30.0,
//                                 top: 30,
//                                 right: 30,
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       const Text(
//                                         "* Today on leave",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Poppins",
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       Text(
//                                         todayLeave.toString(),
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Poppins",
//                                           fontSize: 30,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       const Text(
//                                         "* Upcoming Leave Count",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Poppins",
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       Text(
//                                         upLeaveCount.toString(),
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Poppins",
//                                           fontSize: 30,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Container(
//                         //   width: 320.0,
//                         //   child: ColoredCard(
//                         //     headerColor: Color(0xFF4581c0),
//                         //     footerColor: Color(0xFF6078dc),
//                         //     cardHeight: 220,
//                         //     borderRadius: 30,
//                         //     bodyColor: Color(0xFF6c8df6),
//                         //     showHeader: true,
//                         //     showFooter: false,
//                         //     bodyGradient: LinearGradient(
//                         //       colors: [
//                         //         Color(0xFF82abe1).withOpacity(1),
//                         //         Color(0xFF4183cd),
//                         //         Color(0xFF166dbd),
//                         //       ],
//                         //       begin: Alignment.bottomLeft,
//                         //       end: Alignment.topRight,
//                         //       stops: [0, 0.2, 1],
//                         //     ),
//                         //     headerBar: HeaderBar(
//                         //       title: Text(
//                         //         "Document Request",
//                         //         style: TextStyle(
//                         //           color: Colors.white,
//                         //           fontWeight: FontWeight.bold,
//                         //           fontFamily: "Poppins",
//                         //           fontSize: 16,
//                         //         ),
//                         //       ),
//                         //       action: IconButton(
//                         //         icon: Icon(
//                         //           Icons.account_balance_wallet,
//                         //           color: Colors.white,
//                         //         ),
//                         //         onPressed: () => print("header button"),
//                         //       ),
//                         //     ),
//                         //     bodyContent: Padding(
//                         //       padding: const EdgeInsets.only(
//                         //         left: 30.0,
//                         //         top: 30,
//                         //         right: 30,
//                         //       ),
//                         //       child: Column(
//                         //         mainAxisAlignment: MainAxisAlignment.start,
//                         //         crossAxisAlignment: CrossAxisAlignment.start,
//                         //         children: <Widget>[
//                         //           SizedBox(
//                         //             height: 5,
//                         //           ),
//                         //           // Row(
//                         //           //   mainAxisAlignment:
//                         //           //       MainAxisAlignment.spaceBetween,
//                         //           //   crossAxisAlignment: CrossAxisAlignment.center,
//                         //           //   children: <Widget>[
//                         //           //     Text(
//                         //           //       "* Pending for approval",
//                         //           //       style: TextStyle(
//                         //           //         fontWeight: FontWeight.bold,
//                         //           //         fontFamily: "Poppins",
//                         //           //         fontSize: 16,
//                         //           //         color: Colors.white,
//                         //           //       ),
//                         //           //     ),
//                         //           //     Text(
//                         //           //       pendingDocRqstCount.toString(),
//                         //           //       style: TextStyle(
//                         //           //         fontWeight: FontWeight.bold,
//                         //           //         fontFamily: "Poppins",
//                         //           //         fontSize: 30,
//                         //           //         color: Colors.white,
//                         //           //       ),
//                         //           //     ),
//                         //           //   ],
//                         //           // ),
//                         //           Row(
//                         //             mainAxisAlignment:
//                         //                 MainAxisAlignment.spaceBetween,
//                         //             crossAxisAlignment:
//                         //                 CrossAxisAlignment.center,
//                         //             children: <Widget>[
//                         //               Text(
//                         //                 "* Pending submission",
//                         //                 style: TextStyle(
//                         //                   fontWeight: FontWeight.bold,
//                         //                   fontFamily: "Poppins",
//                         //                   fontSize: 16,
//                         //                   color: Colors.white,
//                         //                 ),
//                         //               ),
//                         //               Text(
//                         //                 '2',
//                         //                 style: TextStyle(
//                         //                   fontWeight: FontWeight.bold,
//                         //                   fontFamily: "Poppins",
//                         //                   fontSize: 30,
//                         //                   color: Colors.white,
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //         ],
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         // // Container(
//                         // //   width: 160.0,
//                         //   color: Colors.yellow,
//                         // ),
//                         // Container(
//                         //   width: 160.0,
//                         //   color: Colors.orange,
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//     });
//   }

//   Widget adminWidget() {
//     if (globals.isEmployee) {
//       return Container();
//     } else {
//       return Column(children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Column(
//                 children: <Widget>[
//                   Material(
//                     borderRadius: BorderRadius.circular(100.0),
//                     color: Colors.pink.withOpacity(0.1),
//                     child: IconButton(
//                       padding: const EdgeInsets.all(7.0),
//                       icon: const Icon(Icons.check_circle),
//                       color: Colors.pink,
//                       iconSize: 35.0,
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const ApproveLeaveList()),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   const Text('Leave/EX Approval',
//                       style: TextStyle(
//                           color: Colors.black54, fontWeight: FontWeight.bold))
//                 ],
//               ),
//               Column(
//                 children: <Widget>[
//                   Material(
//                     borderRadius: BorderRadius.circular(100.0),
//                     color: Colors.purpleAccent.withOpacity(0.1),
//                     child: IconButton(
//                       padding: const EdgeInsets.all(7.0),
//                       icon: const Icon(Icons.credit_card),
//                       color: Colors.purpleAccent,
//                       iconSize: 35.0,
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DocumentRequestWidget(
//                                     mainId: 0,
//                                   )),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   const Text('Doc Request',
//                       style: TextStyle(
//                           color: Colors.black54, fontWeight: FontWeight.bold))
//                 ],
//               ),
//               Column(
//                 children: <Widget>[
//                   Material(
//                     borderRadius: BorderRadius.circular(100.0),
//                     color: Colors.orange.withOpacity(0.1),
//                     child: IconButton(
//                       padding: const EdgeInsets.all(7.0),
//                       icon: const Icon(Icons.list),
//                       color: Colors.orange,
//                       iconSize: 35.0,
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DocStatusWidget()),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   const Text('   Doc Status    ',
//                       style: TextStyle(
//                           color: Colors.black54, fontWeight: FontWeight.bold))
//                 ],
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 15.0),
//         const Divider(),
//         const SizedBox(height: 15.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: Column(
//             children: <Widget>[
//               const Padding(
//                   padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
//                   child: Text("Month",
//                       style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold))),
//               DropdownButton<String>(
//                 value: monthValue,
//                 isExpanded: true,

//                 // icon: Icon(
//                 //   Icons.arrow_drop_down,
//                 // ),
//                 // iconSize: 30,
//                 elevation: 20,

//                 style: const TextStyle(color: Colors.deepPurple),
//                 underline: Container(
//                   height: 2,
//                   color: Colors.deepPurpleAccent,
//                 ),
//                 onChanged: (String newValue) {
//                   setState(() {
//                     monthValue = newValue;
//                   });
//                   _getFilterDashboardData();
//                 },
//                 items: monthList,
//               )
//             ],
//           ),
//         )
//       ]);
//     }
//   }

//   Widget cardWidget() {
//     if (globals.isEmployee) {
//       return const SizedBox.shrink();
//     } else {
//       return SizedBox(
//         width: 320.0,
//         child: ColoredCard(
//           headerColor: const Color(0xFF4581c0),
//           footerColor: const Color(0xFF6078dc),
//           cardHeight: 220,
//           borderRadius: 30,
//           bodyColor: const Color(0xFF6c8df6),
//           showHeader: true,
//           showFooter: false,
//           bodyGradient: LinearGradient(
//             colors: [
//               const Color(0xFF82abe1).withOpacity(1),
//               const Color(0xFF4183cd),
//               const Color(0xFF166dbd),
//             ],
//             begin: Alignment.bottomLeft,
//             end: Alignment.topRight,
//             stops: const [0, 0.2, 1],
//           ),
//           headerBar: HeaderBar(
//             title: const Text(
//               "Employee Details",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: "Poppins",
//                 fontSize: 16,
//               ),
//             ),
//             action: IconButton(
//               icon: const Icon(
//                 Icons.account_balance_wallet,
//                 color: Colors.white,
//               ),
//               onPressed: () => print("header button"),
//             ),
//           ),
//           bodyContent: Padding(
//             padding: const EdgeInsets.only(
//               left: 30.0,
//               top: 30,
//               right: 30,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     const Text(
//                       "* Total Employee",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       employeeCount.toString(),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 30,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     const Text(
//                       "* Newly Joined",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       newlyJoined.toString(),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 30,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     const Text(
//                       "* Left",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       leftEmployee.toString(),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Poppins",
//                         fontSize: 30,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//   }
// }

// class CustomShapeClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();

//     path.lineTo(0.0, 390.0 - 200);
//     path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
//     path.lineTo(size.width, 0.0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

// class UpcomingCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final Color color;

//   const UpcomingCard({this.title, this.value, this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 15.0),
//       child: Container(
//         width: 120.0,
//         decoration: BoxDecoration(
//             color: color,
//             borderRadius: const BorderRadius.all(Radius.circular(25.0))),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
//           child: Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text(title,
//                     style: const TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 30.0),
//                 Text('$value',
//                     style: const TextStyle(
//                         fontSize: 22.0,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold))
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AndroidDrawer extends StatelessWidget {
//   List<String> alreadysmslistmodel = [];
//   final TextEditingController _textFieldController = TextEditingController();
//   final mainTabKey = GlobalKey();
//   Future _getuserRole() async {
//     final http.Response response = await http.post(
//       Uri.parse(globals.applictionRootUrl +
//           'API/GetUserRole?DBName=' +
//           globals.databaseName +
//           '&userId=' +
//           globals.userId.toString()),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       var role = jobject;

//       // accountitem = new List<String>.from(streetsFromJson["Text"]);

//       if (role.toString() == "2") {
//         globals.isEmployee = true;
//         sharedpref.setBoolExtra("isEmployee", true);
//       } else {
//         sharedpref.setBoolExtra("isEmployee", false);
//       }

//       // var mainList =
//       //     leaveTypeitem.map((e) => new LeaveModel.fromJson(e)).toList();
//       // var s = list.map((e) => e["RelationType"].toString()).toList();
//       // List responseJson = json.decode(list);

//     }
//   }

//   void openApp(BuildContext context, int index) {
//     Navigator.pop(context);
//     var login = loginList[index];
//     _getuserRole();
//     globals.isLoggedIn = true;

//     sharedpref.setIntExtra("UserId", loginList[index].loginid);
//     sharedpref.setBoolExtra("IsLoggedIn", true);
//     sharedpref.setStringExtra("DatabaseName", loginList[index].databasename);

//     LoginProfile lg = LoginProfile();
//     lg.loginid = loginList[index].loginid;
//     lg.appid = loginList[index].appid;
//     lg.databasename = loginList[index].databasename;
//     lg.emaild = loginList[index].emaild;
//     lg.isdefault = true;

//     globals.userId = loginList[index].loginid;
//     globals.databaseName = loginList[index].databasename;
//     globals.databaseId = loginList[index].appid.toString();

//     DBProvider.db.updateDefaultLogin(lg);
//     loadagainLoginProfiles();
//     //  ContactTab();
//     // Navigator.of(context).push(
//     //     MaterialPageRoute(builder: (BuildContext context) => LandingPage()));
//     //  Navigator.pushReplacementNamed(context, '/homepage');
//     //  (context as Element).reassemble();
//   }

//   void openAppFromApplist(BuildContext context, int index) {
//     Navigator.pop(context);
//     var app = applist[index];

//     globals.isLoggedIn = true;

//     sharedpref.setBoolExtra("IsLoggedIn", true);
//     sharedpref.setStringExtra("DatabaseName", applist[index].databasename);

//     // globals.userId = loginList[index].loginid;
//     globals.databaseName = applist[index].databasename;

//     // Navigator.of(context).push(
//     //     MaterialPageRoute(builder: (BuildContext context) => LandingPage()));
//   }

//   List<MaterialColor> getRandomColorsheere(int amount) {
//     return List<MaterialColor>.generate(amount, (index) {
//       return _myListOfRandomColors[
//           _random.nextInt(_myListOfRandomColors.length)];
//     });
//   }

//   void displayloginDialog(BuildContext context) async {
//     await loadagainLoginProfiles();
//     _displayAllLoginsDialog(context);
//   }

//   Future loadagainLoginProfiles() async {
//     loginList.clear();
//     loginList = await DBProvider.db.getAllLoginProfile();

//     colors = getRandomColorsheere(loginList.length);
//   }

//   void removeLoginOrLogout(BuildContext context) async {
//     int userID = globals.userId;
//     DBProvider.db.deleteLogin(userID);
//     await loadagainLoginProfiles();
//     if (loginList.isNotEmpty) {
//       displayloginDialog(context);
//       globals.isLoggedIn = true;
//       sharedpref.setIntExtra("UserId", 0);
//       sharedpref.setBoolExtra("IsLoggedIn", true);
//       sharedpref.setStringExtra("DatabaseName", "");

//       globals.userId = 0;
//       globals.databaseName = "";
//     } else {
//       globals.isLoggedIn = false;
//       sharedpref.setIntExtra("UserId", 0);
//       sharedpref.setBoolExtra("IsLoggedIn", false);
//       sharedpref.setStringExtra("DatabaseName", "");

//       globals.userId = 0;
//       globals.databaseName = "";
//       // Navigator.pushNamedAndRemoveUntil(
//       //     context, "/login", (Route<dynamic> route) => false);
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const MyLoginPage()));
//     }
//   }

//   Future loadCompanyDropdowns(BuildContext contxt) async {
//     companydropdownValue = '';
//     companyDropdownitems.clear();

//     companyDropdownitems.add(const DropdownMenuItem(
//       child: Text("Select Company"),
//       value: "",
//     ));

//     final http.Response response = await http.post(
//       Uri.parse(globals.ofcRootUrl +
//           'GetCompanyData?UserId=' +
//           globals.userId.toString()),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );

//     List<String> companyDdnitems = <String>[];
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       List responseJson = json.decode(jobject);
//       if (responseJson.isNotEmpty) {
//         companyDdnitems =
//             responseJson.map((e) => e["CompanyName"].toString()).toList();
//       }
//     }
//     companydropdownValue = '';
//     for (var item in companyDdnitems) {
//       companyDropdownitems.add(DropdownMenuItem(
//         child: Text(item.toString()),
//         value: item,
//       ));
//     }

//     if (companyDdnitems.isNotEmpty) {
//       companydropdownValue = "";
//     }
//     _displayDialog(contxt);
//   }

//   void _changecompanydropdownval(BuildContext context, String val) {
//     companydropdownValue = val;
//     if (companydropdownValue != '') {
//       Navigator.pop(context);
//       loadApplist(context);
//     }
//   }

//   Future loadApplist(BuildContext context) async {
//     // prPleaseWait.show();
//     // appDrodownitems.clear();
//     final http.Response response = await http.post(
//       Uri.parse(globals.ofcRootUrl +
//           'GetApplicationData?CompanyName=' +
//           companydropdownValue +
//           '&AppId=2' +
//           '&UserId=' +
//           globals.userId.toString()),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject1 = jsonDecode(response.body.toString());
//       List responseJson1 = json.decode(jobject1);
//       if (responseJson1.isNotEmpty) {
//         applist = responseJson1.map((e) => AppListModel.fromJson(e)).toList();
//       }
//     }

//     // prPleaseWait.hide();

//     _displayDialog(context);
//   }

//   _displayDialog(BuildContext context) async {
//     return showDialog(
//         context: _scaffoldKey.currentContext,
//         builder: (context) {
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20.0))),
//                 title: const Text('Switch Login'),
//                 content: Container(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Container(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Padding(
//                                 padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//                                 child: Text("Select Company",
//                                     style: TextStyle(color: Colors.blue[400]))),
//                             DropdownButton<String>(
//                               value: companydropdownValue,
//                               isExpanded: true,
//                               // icon: Icon(Icons.arrow_downward),
//                               // iconSize: 15,
//                               elevation: 16,
//                               style: const TextStyle(color: Colors.black),
//                               underline: Container(
//                                 height: 2,
//                                 color: Colors.blue,
//                               ),
//                               items: companyDropdownitems,
//                               onChanged: (String newValue) {
//                                 setState(() {
//                                   _changecompanydropdownval(context, newValue);

//                                   companydropdownValue = newValue;
//                                 });
//                               },
//                             ),
//                             Padding(
//                                 padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
//                                 child: Text("Select App",
//                                     style: TextStyle(color: Colors.blue[400]))),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: applist.length,
//                           itemBuilder: (context, index) {
//                             if (applist.isNotEmpty) {
//                               return Container(
//                                 child:
//                                     _buildItem(context, applist[index], index),
//                               );
//                             } else {
//                               return Container(
//                                 child: const Text("No Apps"),
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         });
//   }

//   Widget _buildItem(BuildContext context, AppListModel app, [int index]) {
//     return ListTile(
//       contentPadding: const EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 0.0),
//       key: ValueKey<AppListModel>(app),
//       title: Text(app.appname),
//       // leading: CircleAvatar(
//       //   child: Icon(Icons.exit_to_app),
//       //   backgroundColor: Colors.grey[300],

//       // ),
//       dense: false,

//       trailing: IconButton(
//         icon: const Icon(Icons.exit_to_app, color: Colors.blue),
//         onPressed: () => openAppFromApplist(context, index),
//         // onLongPress: () => deleteUser(index),
//       ),
//     );
//   }

//   _displayAllLoginsDialog(BuildContext context) async {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 insetPadding: const EdgeInsets.symmetric(horizontal: 0),
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20.0))),
//                 title: const Text('Switch Login'),
//                 content: SizedBox(
//                   width: 100.0,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Container(
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: loginList.length,
//                           itemBuilder: (context, index) {
//                             if (loginList.isNotEmpty) {
//                               return Container(
//                                 child: _buildLoginsItem(
//                                     context, loginList[index], index),
//                               );
//                             } else {
//                               return Container(
//                                 child: const Text("No Apps"),
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                       const Divider(color: Colors.black, height: 20),
//                       ElevatedButton(
//                         onPressed: () => {
//                           globals.userId = 0,
//                           globals.databaseName = "",
//                           globals.isLoggedIn = false,
//                           Navigator.pushNamedAndRemoveUntil(context, "/login",
//                               (Route<dynamic> route) => false),
//                         },
//                         textColor: Colors.blue,
//                         padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             side: const BorderSide(color: Colors.blue)),
//                         color: Colors.white,
//                         child: Text("Add New Login".toUpperCase(),
//                             style: const TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.w900)),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         });
//   }

//   Widget _buildLoginsItem(BuildContext context, LoginProfile app, [int index]) {
//     return ListTile(
//       onTap: () => {openApp(context, index)},
//       contentPadding: const EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
//       key: ValueKey<LoginProfile>(app),
//       title: Text(
//         app.emaild,
//         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//       ),
//       leading: CircleAvatar(
//         child: app.isdefault
//             ? IconButton(
//                 icon: const Icon(
//                   Icons.done,
//                   color: Colors.white,
//                   size: 25,
//                 ),
//                 onPressed: () => {},
//                 // onLongPress: () => deleteUser(index),
//               )
//             : Text(
//                 loginList[index].emaild.substring(0, 1).toUpperCase(),
//                 style: const TextStyle(color: Colors.white),
//               ),
//         backgroundColor: colors[index],
//       ),
//       dense: true,

//       // trailing:
//       // app.isdefault? new IconButton(
//       //   icon: new Icon(Icons.assignment_turned_in,color: Colors.blue,size: 15),
//       //   onPressed:  () => {},
//       //     // onLongPress: () => deleteUser(index),
//       //       ) : Text(""),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (globals.isEmployee) {
//       return Drawer(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.blue),
//               child: Column(
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Icon(
//                       Icons.account_circle,
//                       color: Colors.blue.shade800,
//                       size: 96,
//                     ),
//                   ),
//                   const Text(
//                     "Payroll",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             // ListTile(
//             //   leading: Icon(Icons.home),
//             //   title: Text("Home"),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //     Navigator.push<void>(context,
//             //         MaterialPageRoute(builder: (context) => LandingPage()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: GeneralContact.androidIcon,
//             //   title: Text(GeneralContact.title),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //     Navigator.push<void>(
//             //         context, MaterialPageRoute(builder: (context) => GeneralContact()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.account_balance_wallet),
//             //   title: Text("new Expense"),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //     Navigator.push<void>(context,
//             //         MaterialPageRoute(builder: (context) => NotesTab()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.account_balance_wallet),
//             //   title: Text("Holidays"),
//             //   onTap: () {
//             //     // Navigator.pop(context);
//             //     // Navigator.push<void>(
//             //     //     context,
//             //     //     MaterialPageRoute(
//             //     //         builder: (context) => NewExpense(mainId: 0)));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.receipt),
//             //   title: Text("Empoloyees on Leave today"),
//             //   onTap: () {
//             //     // Navigator.pop(context);
//             //     // Navigator.push<void>(
//             //     //     context,
//             //     //     MaterialPageRoute(
//             //     //         builder: (context) => NewReceipt(
//             //     //               mainId: 0,
//             //     //             )));
//             //   },
//             // ),
//             // Long drawer contents are often segmented.
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person_pin),
//               title: const Text("Switch Login"),
//               onTap: () {
//                 displayloginDialog(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.swap_horizontal_circle),
//               title: const Text("Switch App"),
//               onTap: () {
//                 loadCompanyDropdowns(context);
//                 applist.clear();
//                 // Toast.show("Option to Switch App", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
//                 // _displayDialog(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.power_settings_new),
//               title: const Text("Logout"),
//               onTap: () {
//                 removeLoginOrLogout(context);
//               },
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Drawer(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.blue),
//               child: Column(
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Icon(
//                       Icons.account_circle,
//                       color: Colors.blue.shade800,
//                       size: 96,
//                     ),
//                   ),
//                   const Text(
//                     "Payroll",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             // ListTile(
//             //   leading: Icon(Icons.home),
//             //   title: Text("Home"),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //   },
//             // ),
//             // ListTile(
//             //   leading: GeneralContact.androidIcon,
//             //   title: Text(GeneralContact.title),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //     Navigator.push<void>(
//             //         context, MaterialPageRoute(builder: (context) => GeneralContact()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.account_balance_wallet),
//             //   title: Text("new Expense"),
//             //   onTap: () {
//             //     Navigator.pop(context);
//             //     Navigator.push<void>(context,
//             //         MaterialPageRoute(builder: (context) => NotesTab()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.account_balance_wallet),
//             //   title: Text("Upcoming Holidays"),
//             //   onTap: () {
//             //     Navigator.of(context).push(MaterialPageRoute(
//             //         builder: (BuildContext context) => AttendanceSummary()));
//             //   },
//             // ),
//             // ListTile(
//             //   leading: new Icon(Icons.receipt),
//             //   title: Text("Approve/Reject Status"),
//             //   onTap: () {
//             //     // Navigator.pop(context);
//             //     // Navigator.push<void>(
//             //     //     context,
//             //     //     MaterialPageRoute(
//             //     //         builder: (context) => NewReceipt(
//             //     //               mainId: 0,
//             //     //             )));
//             //   },
//             // ),
//             // Long drawer contents are often segmented.
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person_pin),
//               title: const Text("Switch Login"),
//               onTap: () {
//                 displayloginDialog(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.swap_horizontal_circle),
//               title: const Text("Switch App"),
//               onTap: () {
//                 loadCompanyDropdowns(context);
//                 applist.clear();
//                 // Toast.show("Option to Switch App", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.power_settings_new),
//               title: const Text("Logout"),
//               onTap: () {
//                 removeLoginOrLogout(context);
//               },
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
