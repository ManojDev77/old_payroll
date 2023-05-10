import 'package:flutter/material.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class ApproveLeaveList extends StatefulWidget {
  const ApproveLeaveList({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  ApproveLeaveListState createState() => ApproveLeaveListState();
}

class ApproveLeaveListState extends State<ApproveLeaveList> {
  int y = 4;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LeaveApproveModel> mainLeaveList = [];
  List<LeaveApproveModel> allmainLeaveList = [];
  TextEditingController reasonController = TextEditingController();
  TextEditingController searchcontroller = TextEditingController();
  List<LeaveApproveModel> searchList = [];
  List<LeaveApproveModel> leaveList = [];
  bool isLoaded = false;
  String nextpage = '';
  ProgressDialog? pr;
  @override
  void initState() {
    _requestLeaveData();
    pr = ProgressDialog(context, isDismissible: false);

    pr?.style(
        message: 'Loading...',
        borderRadius: 5.0,
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 5.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.1,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400));
    super.initState();
  }

  Future _requestLeaveData() async {
    isLoaded = false;
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/GetLeaveRequestList?DBName=${globals.databaseName}&userId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => LeaveApproveModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          allmainLeaveList = List<LeaveApproveModel>.from(mainList);
          mainLeaveList =
              allmainLeaveList.where((element) => element.status == 1).toList();
          leaveList = mainLeaveList;
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future _approveLeave(int idapprove) async {
    pr?.show();

    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/ApproveLeave?DBName=${globals.databaseName}&userId=${globals.userId}&ReqId=$idapprove'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      if (jobject == true) {
        pr?.hide();
        showInSnackBar("Request Approved");
        _requestLeaveData();
      } else {
        pr?.hide();
        showInSnackBar("Something Went Wrong!");
      }
    }
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    final txt = text.toString().toLowerCase();

    for (var detail in leaveList) {
      if (detail.reason!.toLowerCase().contains(txt) ||
          detail.status!.toString().toLowerCase().contains(txt) ||
          detail.empname!.toLowerCase().contains(txt) ||
          detail.leavename!.toLowerCase().contains(txt) ||
          detail.id.toString().toLowerCase().contains(txt) ||
          detail.empID.toString().toLowerCase().contains(txt) ||
          detail.fromdate!.toLowerCase().contains(txt) ||
          detail.todate.toString().toLowerCase().contains(txt)) {
        searchList.add(detail);
      }
    }
    if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
      mainLeaveList = searchList;
    } else {
      mainLeaveList = leaveList;
    }
    setState(() {});
  }

  Future _rejectLeave(int id) async {
    if (reasonController.text.isEmpty) {
      showInSnackBar("Enter Remark");
      return;
    }
    pr?.show();

    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/RejectLeave?DBName=${globals.databaseName}&userId=${globals.userId}&ReqId=$id&RejectionRemark=${reasonController.text}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      if (jobject == true) {
        showInSnackBar("Request Rejected");
        _requestLeaveData();
      } else {
        showInSnackBar("Something Went Wrong!");
      }
    }
    reasonController.clear();
    pr?.hide();
  }

  void approveLeaveRqst(int id) {
    setState(() {
      _approveLeave(id);
    });
  }

  void rejectLeaveRqst(int id) {
    setState(() {
      _rejectLeave(id);
    });
  }

  showAlertDialog(BuildContext context, int id) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Approve"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        approveLeaveRqst(id);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Alert!"),
      content: const Text("Are you sure you want to Approve Leave?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogRej(BuildContext context, int id) async {
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: false,
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Remark",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                reasonController.clear();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              }),
          TextButton(
              child: const Text('Reject'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                rejectLeaveRqst(id);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: !isLoaded
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Container(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.search),
                          title: TextField(
                            autofocus: false,
                            controller: searchcontroller,
                            decoration: const InputDecoration(
                                hintText: 'Search', border: InputBorder.none),
                            onChanged: onSearchTextChanged,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              searchcontroller.clear();
                              onSearchTextChanged('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  leaveeList(),
                ],
              ));
  }

  Widget leaveeList() {
    return mainLeaveList.isNotEmpty
        ? Flexible(
            child: Container(
              color: Colors.white,
              child: FutureBuilder(builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: mainLeaveList.length,
                  itemExtent: 200.0,
                  itemBuilder: (context, index) {
                    return leaveRow(mainLeaveList[index], index);
                  },
                );
              }),
            ),
          )
        : const Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 70),
            child: Text(
              "NO RECORDS FOUND",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontFamily: "poppins-medium"),
            ),
          );
  }

  String sessionname(LeaveApproveModel leavee) {
    String sessionnameis = '';
    if (leavee.session == 0) {
      sessionnameis = "Fullday";
    } else if (leavee.session == 1) {
      sessionnameis = "First Half";
    } else {
      sessionnameis = "Second Half";
    }
    return sessionnameis;
  }

  Widget leaveRow(LeaveApproveModel leave, int index) {
    final String sessionnameis = sessionname(leave);
    final thumbnail = Container(
      alignment: const FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 15.0),
      child: Hero(
          tag: leave.id!,
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(width: 5, color: getColor(leave.status!))),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: getIcon(leave.status!),
              ))),
    );
    final leaveCard = Container(
      height: 200,
      margin: const EdgeInsets.only(left: 45.0, right: 20.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 2.0))
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 8.0, left: 72.0),
        constraints: const BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
                leave.empname! +
                    ' (' " " +
                    leave.leavename! +
                    ' For ' +
                    '' +
                    sessionnameis +
                    ' )',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'poppins-medium',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                )),
            Text("${leave.fromdate} - ${leave.todate}",
                style: const TextStyle(
                  color: Color(0x66FFFFFF),
                  fontFamily: 'poppins-medium',
                  fontWeight: FontWeight.w300,
                  fontSize: 14.0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(0),
                  child: Icon(Icons.calendar_today,
                      size: 14.0, color: Color(0x66FFFFFF)),
                ),
                Text(
                  getStatus(leave.status!),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'poppins-medium',
                      fontWeight: FontWeight.w300,
                      fontSize: 14.0),
                ),
                const SizedBox(
                  width: 70.0,
                  height: 0,
                ),
                if (leave.status == 1)
                  Column(children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        textStyle: const TextStyle(
                          color: Color(0x66FFFFFF),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        showAlertDialog(context, leave.id!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Column(children: const <Widget>[
                          Icon(Icons.check,
                              size: 15.0, color: Color(0x66FFFFFF)),
                          Text(
                            'Approve',
                            style: TextStyle(
                                color: Color(0x66FFFFFF),
                                fontFamily: 'poppins-medium',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.0),
                          ),
                        ]),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        textStyle: const TextStyle(
                          color: Color(0x66FFFFFF),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        showAlertDialogRej(context, leave.id!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 1),
                        child: Column(children: const <Widget>[
                          Icon(Icons.cancel,
                              size: 15.0, color: Color(0x66FFFFFF)),
                          Text(
                            'Reject',
                            style: TextStyle(
                                color: Color(0x66FFFFFF),
                                fontFamily: 'poppins-medium',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.0),
                          ),
                        ]),
                      ),
                    ),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
    return Container(
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Stack(
        children: <Widget>[
          leaveCard,
          thumbnail,
        ],
      ),
    );
  }
}

List<Icon> listOfIcons = [
  const Icon(
    Icons.check,
    size: 60,
    color: Colors.green,
  ),
  const Icon(
    Icons.hourglass_empty,
    size: 60,
    color: Colors.orange,
  ),
  const Icon(
    Icons.cancel,
    size: 60,
    color: Colors.red,
  )
];

List<Color> listOfColors = [Colors.green, Colors.orange, Colors.red];

Icon getIcon(int leaveStatus) {
  switch (leaveStatus) {
    case 2:
      return listOfIcons[0];
      break;

    case 1:
      return listOfIcons[1];
      break;

    case 3:
      return listOfIcons[2];
      break;

    case 4:
      return listOfIcons[2];
      break;
  }
  return listOfIcons[2];
}

Color getColor(int leaveStatus) {
  switch (leaveStatus) {
    case 2:
      return listOfColors[0];
      break;

    case 1:
      return listOfColors[1];
      break;

    case 3:
      return listOfColors[2];
      break;

    case 4:
      return listOfColors[2];
      break;
  }
  return listOfColors[2];
}

String getStatus(int leaveStatus) {
  switch (leaveStatus) {
    case 2:
      return "Approved";
      break;

    case 1:
      return "Pending";
      break;

    case 3:
      return "Rejected";
      break;

    case 4:
      return "Pending";
      break;
  }
  return "Pending";
}

class LeaveApproveModel {
  const LeaveApproveModel(
      {this.id,
      this.empID,
      this.fromdate,
      this.todate,
      this.empname,
      this.leavename,
      this.status,
      this.duration,
      this.reason,
      this.session});
  final int? id;
  final int? empID;
  final String? fromdate;
  final String? todate;
  final String? empname;
  final String? leavename;
  final int? status;
  final String? duration;
  final String? reason;
  final int? session;
  factory LeaveApproveModel.fromJson(Map<String, dynamic> json) {
    return LeaveApproveModel(
      id: json['Id'] ?? 0,
      empID: json['EmpID'] ?? 0,
      leavename: json['LeaveName'] ?? "",
      fromdate: json['FDate'] ?? 0,
      todate: json['TDate'] ?? 0,
      empname: json['EmployeeName'] ?? 0,
      status: json['Status'] ?? 0,
      reason: json['Reason'] ?? "",
      session: json['LeaveSession'] ?? 0,
    );
  }
}
