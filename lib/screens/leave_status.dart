import 'package:flutter/material.dart';
import '../screens/leave_application.dart';
import 'dart:convert';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class LeaveStatusWidget extends StatefulWidget {
  final String? empvalue;
  const LeaveStatusWidget({Key? key, @required this.empvalue, this.title})
      : super(key: key);
  final String? title;

  @override
  LeaveStatusWidgetState createState() => LeaveStatusWidgetState();
}

class LeaveStatusWidgetState extends State<LeaveStatusWidget> {
  List<String> DateListitems = [];
  List<ApproverModel> _approverlist = [];

  String dateListValue = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LeaveModel> mainLeaveList = [];
  List<LeaveModel> allmainLeaveList = [];
  // List<InvoiceListModel> mainInvoiceList = [];
  TextEditingController searchcontroller = TextEditingController();
  List<LeaveModel> searchList = [];
  List<LeaveModel> leaveList = [];
  bool isLoaded = false;
  String nextpage = '';
  @override
  void initState() {
    _requestLeaveData();

    super.initState();
  }

  Future _requestLeaveData() async {
    isLoaded = false;
    String query =
        '${globals.applictionRootUrl}API/GetLeaveStatusList?DBName=${globals.databaseName}&userId=${globals.isEmployee ? globals.userId.toString() : widget.empvalue}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => LeaveModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          allmainLeaveList = mainLeaveList = List<LeaveModel>.from(mainList);
          leaveList = mainLeaveList;
          isLoaded = true;
          filterList(1);
          loadDateDropdowns();
        });
      }
      if (mounted) {
        setState(() {
          isLoaded = true;
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

  getLeaveApprover() async {
    _approverlist.clear();
    //GetApproverList(string DBName, int UserId)

    String query =
        '${globals.applictionRootUrl}API/GetApproverList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      var approver = jobject;

      var mainList = approver.map((e) => ApproverModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          _approverlist = List<ApproverModel>.from(mainList);
        });
      }
    }
  }

  Future _deleteLeave(int index) async {
    await getLeaveApprover();

    int id = mainLeaveList[index].id!;
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/LeaveRequestRemove?DBName=${globals.databaseName}&userId=${globals.userId}&ReqId=$id'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      if (jobject) {
        // for (int i = 0; i < _approverlist.length; i++) {
        //   SendNotification.sendMessage(
        //       globals.databaseName,
        //       _approverlist[i].userid.toString(),
        //       "Leave Request Deleted",
        //       "Payroll");
        // }
        _requestLeaveData();
        showInSnackBar("Leave Deleted Successfully");
      } else {
        showInSnackBar("Something Went Wrong!");
      }
    }
  }

  void deleteRecord(int index) {
    setState(() {
      _deleteLeave(index);
    });
  }

  void filterList(int status) {
    print(status);
    setState(() {
      if (status == 0) {
        mainLeaveList = allmainLeaveList;
      } else {
        mainLeaveList = allmainLeaveList
            .where((element) => element.status == status)
            .toList();
      }
    });
  }

  showAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        deleteRecord(index);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Alert!"),
      content: const Text("Are you sure you want to delete?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final _currentitem = "Select Date";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Leave Status'.toUpperCase()),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _requestLeaveData,
              child: Column(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
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
                              // isSearch = false;
                              searchcontroller.clear();
                              onSearchTextChanged('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 5, color: Colors.blue)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.clear_all,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                              )),
                          onTap: () {
                            filterList(0);
                          },
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 5, color: Colors.orange)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.hourglass_empty,
                                  size: 30,
                                  color: Colors.orange,
                                ),
                              )),
                          onTap: () {
                            filterList(1);
                          },
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 5, color: Colors.green)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.check,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              )),
                          onTap: () {
                            filterList(2);
                          },
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 5, color: Colors.red)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              )),
                          onTap: () {
                            filterList(3);
                          },
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                      ],
                    ),
                  ),
                  leaveeList(),
                ],
              ),
            ),
    );
  }

  void loadDateDropdowns() {
    for (var detail in leaveList) {
      DateListitems.add(detail.fromdate!);
      if (!DateListitems.contains(detail.todate)) {
        DateListitems.add(detail.todate!);
      }
    }
  }
//     dateListValue = '';
//     DateListitems.clear();

//     DateListitems.add(new DropdownMenuItem(
//       child: new Text("Select Date"),
//       value: "",
//     ));

//     final http.Response response = await http.post(
//       globals.ofcRootUrl + 'API/GetLeaveRequestList?DBName=' + globals.userId.toString(),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );

//     List<String> companyDdnitems = new List<String>();
//     if (response.statusCode == 200) {
//       var jobject = jsonDecode(response.body.toString());
//       List responseJson = json.decode(jobject);
//       if (responseJson.isNotEmpty) {
//         companyDdnitems =responseJson.map((e) => e["FDate"].toString()).toList();
//       }
//     }
//     dateListValue = '';
//     companyDdnitems.forEach((item) {
//       DateListitems.add(new DropdownMenuItem(
//         child: new Text(item.toString()),
//         value: item,
//       ));
//     });

//   }

  Widget leaveeList() {
    return mainLeaveList.isNotEmpty
        ? Flexible(
            child: Container(
              color: Colors.white,
              child: FutureBuilder(
                  // future: leaveDatabase.getLeaveListBasedOnUID(widget.user.uid),
                  // ignore: missing_return
                  builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: mainLeaveList.length,
                  itemExtent: 190.0,
                  itemBuilder: (context, index) {
                    return leaveRow(mainLeaveList[index], index);
                  },
                );
                // switch (snapshot.connectionState) {
                //   case ConnectionState.none:
                //     return Text(
                //       'Press the button to fetch data',
                //       textAlign: TextAlign.center,
                //     );

                //   case ConnectionState.active:
                //   case ConnectionState.waiting:
                //     return Center(
                //       child: CircularProgressIndicator(
                //           valueColor: AlwaysStoppedAnimation<Color>(dashBoardColor)),
                //     );

                //   case ConnectionState.done:
                //     if (snapshot.hasError)
                //       return Center(
                //         child: Text(
                //           'Error:\n\n${snapshot.error}',
                //           textAlign: TextAlign.center,
                //         ),
                //       );

                // }
              }),
            ),
          )
        : Center(
            heightFactor: 10,
            child: Text(
              "No Records Found".toUpperCase(),
              style:
                  const TextStyle(fontSize: 30, fontFamily: "poppins-medium"),
            ),
          );
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    final txt = text.toString().toLowerCase();
    // if (text.isEmpty) {
    //   setState(() {});
    //   return;
    // }
    // isSearch = true;
    for (var detail in leaveList) {
      if (detail.reason!.toLowerCase().contains(txt) ||
          detail.status.toString().toLowerCase().contains(txt) ||
          detail.empname!.toLowerCase().contains(txt) ||
          detail.leavename!.toLowerCase().contains(txt) ||
          detail.id.toString().toLowerCase().contains(txt) ||
          detail.empID.toString().toLowerCase().contains(txt) ||
          detail.fromdate!.toLowerCase().contains(txt) ||
          detail.todate.toString().toLowerCase().contains(txt)) {
        searchList.add(detail);
      }

      DateListitems.add(detail.fromdate!);
      if (DateListitems.contains(detail.todate)) {
        DateListitems.add(detail.todate!);
      }
    }

    if (txt.isNotEmpty || searchcontroller.text.isNotEmpty) {
      mainLeaveList = searchList;
    } else {
      mainLeaveList = leaveList;
    }
    setState(() {});
  }

  String sessionname(LeaveModel leavee) {
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

  Widget leaveRow(LeaveModel leave, int index) {
    final String sessionnameis = sessionname(leave);
    final thumbnail = Container(
      alignment: const FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 15.0),
      child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(width: 5, color: getColor(leave.status!))),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: getIcon(leave.status!),
          )),
    );
    final leaveCard = Container(
      height: 250,
      margin: const EdgeInsets.only(left: 45.0, right: 20.0),
      decoration: BoxDecoration(
        color: Colors.blue,
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
                    ' For' +
                    ' ' +
                    sessionnameis +
                    " " ')',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'poppins-medium',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                )),
            Text("${leave.fromdate} - ${leave.todate}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'poppins-medium',
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                )),
//            Container(
//              color: Colors.white70,
//              width: 170.0,
//              height: 1.0,
//              margin: const EdgeInsets.symmetric(vertical: 8.0),
//            ),
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
                leave.status == 2 || leave.status == 3
                    // leave.withdrawalStatus == true
                    ? Container(
                        height: 30,
                      )
                    : Column(children: <Widget>[
                        globals.userId == leave.empID
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    color: Color(0x66FFFFFF),
                                  ),
                                  backgroundColor: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          LeaveApplicationWidget(
                                            mainId: mainLeaveList[index].id,
                                            empname: '',
                                          )));
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Column(children: const <Widget>[
                                    Icon(Icons.edit,
                                        size: 15.0, color: Colors.white),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'poppins-medium',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.0),
                                    ),
                                  ]),
                                ),
                              )
                            : Row(),
                        globals.userId == leave.empID
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    color: Color(0x66FFFFFF),
                                  ),
                                  backgroundColor: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () async {
                                  showAlertDialog(context, index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 1),
                                  child: Column(children: const <Widget>[
                                    Icon(Icons.delete,
                                        size: 15.0, color: Colors.white),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'poppins-medium',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.0),
                                    ),
                                  ]),
                                ),
                              )
                            : Row(),
                      ]),
              ],
            ),
            if (leave.status == 3)
              Text(
                "Reason : ${leave.rejectReason}",
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'poppins-medium',
                    fontWeight: FontWeight.w300,
                    fontSize: 14.0),
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
    // case LeaveStatus.approved:
    case 2:
      return listOfIcons[0];
      break;

    // case LeaveStatus.pending:
    case 1:
      return listOfIcons[1];
      break;

    // case LeaveStatus.rejected:
    case 3:
      return listOfIcons[2];
      break;

    // case LeaveStatus.undetermined:
    case 4:
      return listOfIcons[2];
      break;
  }
  return listOfIcons[2];
}

Color getColor(int leaveStatus) {
  switch (leaveStatus) {
    // case LeaveStatus.approved:
    case 2:
      return listOfColors[0];
      break;

    // case LeaveStatus.pending:
    case 1:
      return listOfColors[1];
      break;

    // case LeaveStatus.rejected:
    case 3:
      return listOfColors[2];
      break;

    // case LeaveStatus.undetermined:
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

String getDoubleDigit(String value) {
  if (value.length >= 2) return value;
  return "0$value";
}

String getFormattedDate(DateTime day) {
  String formattedDate =
      "${getDoubleDigit(day.day.toString())}-${getDoubleDigit(day.month.toString())}-${getDoubleDigit(day.year.toString())}";
  return formattedDate;
}

class LeaveModel {
  const LeaveModel(
      {this.id,
      this.empID,
      this.fromdate,
      this.todate,
      this.empname,
      this.leavename,
      this.status,
      this.duration,
      this.reason,
      this.session,
      this.rejectReason});
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
  final String? rejectReason;
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
        id: json['Id'] ?? 0,
        empID: json['EmpID'] ?? 0,
        leavename: json['LeaveName'] ?? "",
        fromdate: json['FDate'] ?? 0,
        todate: json['TDate'] ?? 0,
        empname: json['EmployeeName'] ?? 0,
        status: json['Status'] ?? "",
        reason: json['Reason'] ?? "",
        session: json['LeaveSession'] ?? "",
        rejectReason: json['RejectRemark'] ?? "");
  }
}
