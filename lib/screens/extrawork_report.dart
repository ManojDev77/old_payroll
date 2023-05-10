// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'globals.dart' as globals;
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart' as dateformat;

// class EXReportPage extends StatefulWidget {
//   static const title = 'Leave';
//   static const androidIcon = Icon(Icons.receipt);

//   @override
//   EXReportPageState createState() => EXReportPageState();
// }

// class EXReportPageState extends State<EXReportPage>
//     with WidgetsBindingObserver {
//   Color primaryColor = const Color.fromRGBO(30, 144, 255, 1);
//   List<InvoiceListModel> mainInvoiceList = [];
//   TextEditingController searchcontroller = TextEditingController();
//   List<InvoiceListModel> searchList = [];
//   List<InvoiceListModel> invoiceList = [];
//   bool isLoaded = false;
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey();

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   @override
//   void initState() {
//     _getLeaveData();
//     // _getTDSValue();
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _getLeaveData();
//     }
//   }

//   String accountValue = "";
//   DateTime selectedDate = DateTime.now();

//   List<DropdownMenuItem<String>> accountList = [];
//   String runningBalan = "";
//   Future _getLeaveData() async {
//     String query = globals.applictionRootUrl +
//         'API/EmployeeExtraWorkReport?DBName=' +
//         globals.databaseName +
//         '&UserId=' +
//         globals.userId.toString() +
//         '&LeaveCode=' +
//         '&Session=' +
//         '&EmpName=' +
//         '&FromDate=';
//     final http.Response response = await http.post(
//       Uri.parse(query),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       var list = jobject["ExtraWorkingSearchList"];

//       //var receiptbal = jobject["DashboardData"]["totalExp"];
//       var mainList = list.map((e) => InvoiceListModel.fromJson(e)).toList();
//       // var s = list.map((e) => e["RelationType"].toString()).toList();
//       // List responseJson = json.decode(list);
//       if (mounted) {
//         setState(() {
//           mainInvoiceList = List<InvoiceListModel>.from(mainList);
//           invoiceList = mainInvoiceList;
//           isLoaded = true;
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

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(builder: (context, snapshot) {
//       return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: const Text("Employee Extrawork Report"),
//         ),
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               // Padding(
//               //   padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
//               //   child: new Row(children: <Widget>[
//               //     Text('Report',
//               //         style: TextStyle(
//               //             color: Colors.black.withOpacity(0.7),
//               //             fontWeight: FontWeight.bold,
//               //             fontSize: 32.0)),
//               //     Padding(
//               //       padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
//               //     ),
//               //     Material(
//               //       borderRadius: BorderRadius.circular(100.0),
//               //       // color: Colors.blue.withOpacity(0.8),
//               //       child: IconButton(
//               //         padding: EdgeInsets.all(0.0),
//               //         icon: Icon(Icons.refresh),
//               //         color: Colors.blue,
//               //         iconSize: 27.0,
//               //         onPressed: () {
//               //           _getLeaveData();
//               //         },
//               //       ),
//               //     ),
//               //   ]),
//               // ),

//               // Padding(
//               //   padding: EdgeInsets.symmetric(horizontal: 25.0),
//               //   child: Container(
//               //     width: double.infinity,
//               //     height: 120.0,
//               //     decoration: BoxDecoration(
//               //         color: primaryColor,
//               //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
//               //         boxShadow: [
//               //           BoxShadow(
//               //               color: Colors.black.withOpacity(0.1),
//               //               offset: Offset(0.0, 0.3),
//               //               blurRadius: 15.0)
//               //         ]),
//               //     child: Column(
//               //       children: <Widget>[
//               //         Padding(
//               //           padding: EdgeInsets.symmetric(
//               //               horizontal: 25.0, vertical: 25.0),
//               //           child: Row(
//               //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //             children: <Widget>[
//               //               Column(
//               //                 crossAxisAlignment: CrossAxisAlignment.start,
//               //                 mainAxisSize: MainAxisSize.min,
//               //                 children: <Widget>[
//               //                   Text(
//               //                     mainInvoiceList.length.toString(),
//               //                     // runningBalan.toString(),
//               //                     style: TextStyle(
//               //                         color: Colors.white,
//               //                         fontSize: 30.0,
//               //                         fontWeight: FontWeight.bold),
//               //                   ),
//               //                   SizedBox(height: 15.0),
//               //                   Text(
//               //                     'Total Report',
//               //                     style: TextStyle(
//               //                       color: Colors.white,
//               //                       fontSize: 14.0,
//               //                     ),
//               //                   )
//               //                 ],
//               //               ),
//               //               IconButton(
//               //                 icon: Icon(Icons.library_add),
//               //                 onPressed: () {
//               //                   // _downloadInvoice();
//               //                 },
//               //                 color: Colors.white,
//               //                 iconSize: 30.0,
//               //               )
//               //             ],
//               //           ),
//               //         ),
//               //         //chartWidget
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 color: Theme.of(context).primaryColor,
//                 child: Padding(
//                   padding: const EdgeInsets.all(3.0),
//                   child: Card(
//                     child: ListTile(
//                       leading: Icon(Icons.search),
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
//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 25.0, right: 25.0, top: 20.0, bottom: 20),
//                 child: Text(
//                   'Extrawork Report List',
//                   style: TextStyle(
//                       color: Colors.black.withOpacity(0.7),
//                       fontSize: 20.0,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: mainInvoiceList.length,
//                   itemBuilder: (context, index) {
//                     return SafeArea(
//                       child: buildInvoiceList(mainInvoiceList[index], index),
//                     );
//                     // Just a bunch of boxes that simulates loading song choices.
//                     //return ExpenseTile();s
//                   },
//                 ),
//               ),
//               //buildList(context),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   onSearchTextChanged(String text) async {
//     searchList.clear();
//     // if (text.isEmpty) {
//     //   setState(() {});
//     //   return;
//     // }
//     // isSearch = true;
//     for (var detail in invoiceList) {
//       if (detail.billNo.toLowerCase().contains(text) ||
//           detail.reason.toString().toLowerCase().contains(text) ||
//           detail.type.toString().toLowerCase().contains(text) ||
//           detail.billdate.toString().toLowerCase().contains(text) ||
//           detail.partyname.toString().toLowerCase().contains(text)) {
//         searchList.add(detail);
//       }
//     }
//     if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
//       mainInvoiceList = searchList;
//     } else {
//       mainInvoiceList = invoiceList;
//     }
//     setState(() {});
//   }

//   Widget buildInvoiceList(InvoiceListModel data, int index) {
//     return Slidable(
//       actionPane: const SlidableDrawerActionPane(),
//       actionExtentRatio: 0.25,
//       child: SizedBox(
//         height: 100,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//           child: Column(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5.0),
//                 child: Row(
//                   children: <Widget>[
//                     Material(
//                       borderRadius: BorderRadius.circular(5),
//                       color: Colors.blueGrey.withOpacity(0.1),
//                       child: Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Text(
//                           data.billNo,
//                           style: const TextStyle(
//                               color: Colors.blue,
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 25.0),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             data.partyname,
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           ),

//                           Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text(
//                                   data.billdate,
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 Text(
//                                   "Type: " + data.type.toString(),
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ]),
//                           Text(
//                             data.reason.toString(),
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           )
//                           // Text(
//                           //   data.account,
//                           //   style: TextStyle(
//                           //     fontSize: 15.0,
//                           //   ),
//                           // )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: <Widget>[
//         IconSlideAction(
//           caption: 'View',
//           color: Colors.blue,
//           icon: Icons.remove_red_eye,
//           onTap: () => {
//             // Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //         builder: (context) => SalesInvoiceForm(
//             //               mainId: mainInvoiceList[index].id,
//             //             )))
//           },
//         ),
//         // new IconSlideAction(
//         //   caption: 'TDS',
//         //   color: Colors.blue,
//         //   icon: Icons.remove_red_eye,
//         //   onTap: () => {
//         //     Navigator.push(
//         //         context,
//         //         MaterialPageRoute(
//         //             builder: (context) => TDSListPage(
//         //                   mainId: mainInvoiceList[index].id,
//         //                 )))
//         //   },
//         // ),
//       ],
//     );
//   }

//   Widget _buildItem(InvoiceListModel user) {
//     return const Text('s');
//     // return Column(
//     //   children: <Widget>[
//     //     Padding(
//     //       padding: const EdgeInsets.symmetric(vertical: 5.0),
//     //       child: Row(
//     //         children: <Widget>[
//     //           Material(
//     //             borderRadius: BorderRadius.circular(100.0),
//     //             color: Colors.purple.withOpacity(0.1),
//     //             child: Padding(
//     //               padding: EdgeInsets.all(15.0),
//     //               child: Text(
//     //                 'JO',
//     //                 style: TextStyle(
//     //                     color: Colors.purple,
//     //                     fontSize: 24.0,
//     //                     fontWeight: FontWeight.bold),
//     //               ),
//     //             ),
//     //           ),
//     //           SizedBox(width: 25.0),
//     //           Expanded(
//     //             child: Column(
//     //               crossAxisAlignment: CrossAxisAlignment.start,
//     //               children: <Widget>[
//     //                 Text(
//     //                   'Load Actinity',
//     //                   style: TextStyle(
//     //                       color: Colors.black,
//     //                       fontSize: 18.0,
//     //                       fontWeight: FontWeight.bold),
//     //                 ),
//     //                 Text(
//     //                   'Sent Money',
//     //                   style: TextStyle(
//     //                       color: Colors.black.withOpacity(0.8),
//     //                       fontSize: 16.0,
//     //                       fontWeight: FontWeight.bold),
//     //                 )
//     //               ],
//     //             ),
//     //           ),
//     //           Text(
//     //             '- 240.0',
//     //             style: TextStyle(
//     //                 color: Colors.black,
//     //                 fontSize: 18.0,
//     //                 fontWeight: FontWeight.bold),
//     //           )
//     //         ],
//     //       ),
//     //     ),
//     //     Padding(
//     //       padding: EdgeInsets.symmetric(horizontal: 25.0),
//     //       child: Divider(),
//     //     ),
//     //   ],
//     // );
//   }
// }

// class InvoiceListModel {
//   const InvoiceListModel(
//       {this.id,
//       this.billNo,
//       this.billdate,
//       this.partyname,
//       this.reason,
//       this.type});

//   final int id;
//   final String billNo;
//   final String billdate;
//   final String partyname;
//   final String reason;
//   final String type;
//   factory InvoiceListModel.fromJson(Map<String, dynamic> json) {
//     return InvoiceListModel(
//       id: json['BillID'] ?? 0,
//       billNo: json['leavecode'] == null ? "" : json['leavecode'].toString(),
//       billdate: json['fromdate'] == null
//           ? ''
//           : getdatefrommilisec(json['fromdate'].toString()),
//       // receipt: json['m_name'] == null ? "" : json['m_name'],
//       partyname: json['empname'] ?? "",
//       reason: json['reason'] ?? "",
//       type: json['listdesc'] ?? "",
//     );
//   }
//   static String getdatefrommilisec(String date) {
//     var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
//     var orDate = DateTime.fromMillisecondsSinceEpoch(oDate);
//     String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
//     return orderDate;
//   }
// }

// // List<ItemListModel> initialListData = [
// //   ItemListModel(
// //     itemcode: '10/5/2020',
// //     itemrate: 'adithya',
// //     itemrate: 5000.00,
// //   ),
// //   ItemListModel(
// //     date: '10/5/2020',
// //     receipt: 'harsha',
// //     amount: 9000.00,
// //   ),
// //   ItemListModel(
// //     date: '10/5/2020',
// //     receipt: 'vishnu',
// //     amount: 6000.00,
// //   ),
// // ];
