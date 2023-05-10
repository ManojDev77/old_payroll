import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';
import 'dart:async';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'leave_approve_request.dart';
import 'leave_status.dart';

class LeaveApplicationWidget extends StatefulWidget {
  const LeaveApplicationWidget(
      {Key? key, @required this.mainId, this.empname, this.title})
      : super(key: key);
  final String? title;
  final int? mainId;
  final String? empname;

  @override
  LeaveApplicationWidgetState createState() => LeaveApplicationWidgetState();
}

class LeaveApplicationWidgetState extends State<LeaveApplicationWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController sessionController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _date1 = TextEditingController();
  var session = 0;
  String empValue = "";
  String reason = '';
  bool isyearclicked = false;
  bool isLoaded = false;
  bool ishalfday = false;
  bool isFullDay = true;
  bool monVal = false;
  bool isSelected = false;
  String _fromdate = "Select";
  String _fromdispdate = "Select";
  String _todate = "Select";
  String _todispdate = "Select";
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  String nlydate = "";
  String yearListValue = "";
  var date = DateTime.now();
  ProgressDialog? pr;
  int cnt = 0;
  List<DropdownMenuItem<String>> empList = [];
  List<DropdownMenuItem<String>> yearList = [];
  List<DropdownMenuItem<String>> monthList = [];
  List<DropdownMenuItem<String>> leaveList = [];
  List<DropdownMenuItem<String>> accountList = [];
  List<DropdownMenuItem<String>> leaveTypeList = [];
  int val = 1;
  String leaveTypeValue = "";
  int leaveIndex = -1;
  int mainId = 0;
  String accountValue = "";
  List<Widget> list = [];
  List<String> _checked = ["Full Day"];

  List<dynamic> empitem = [];
  List<String> leaveType = [
    "Full Day",
    "First Half",
    "Second Half",
  ];
  var leaveApproveRequestedList = [];
  bool inBetweenDatesPresent = false;

  @override
  void initState() {
    _leaveEditData();
    approvedRequestedLeaveData();
    pr = ProgressDialog(context, isDismissible: false);

    pr?.style(
        message: 'Submitting...',
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

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      nlydate = DateFormat("yyyy/MM/dd").format(picked);
      String nlydatedisp = DateFormat("dd/MM/yyyy").format(picked);
      _fromdate = nlydate;
      _fromdispdate = nlydatedisp;
      _todate = nlydate;
      _todispdate = nlydatedisp;
      _date.value = TextEditingValue(text: nlydate.toString());
      setState(() {});
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    if (_fromdispdate == "Select") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select from date'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDateTo) {
      String nlydate = DateFormat("yyyy/MM/dd").format(picked);
      String nlydatedisp = DateFormat("dd/MM/yyyy").format(picked);

      if (picked.difference(selectedDate).isNegative) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('To date should be higher than from date'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      _todate = nlydate;
      _todispdate = nlydatedisp;
      _date1.value = TextEditingValue(text: nlydate.toString());
      setState(() {});
    }
  }

  Future<void> requestLeave() async {
    if (leaveTypeValue.trim().isEmpty) {
      showInSnackBar("Select Leave Type");
      return;
    }
    if (_checked.isEmpty) {
      showInSnackBar("Select Session");
      return;
    }
    if (_fromdispdate.trim() == "Select") {
      if (isFullDay) {
        showInSnackBar("Select From Date");
        return;
      } else {
        showInSnackBar("Select Date");
        return;
      }
    }

    if (reasonController.text.trim() == "") {
      showInSnackBar("Enter Reason");
      return;
    }
    checkLeaveAlreadyRequestedApproved(_fromdate, _todate);
    if (inBetweenDatesPresent) {
      showInSnackBar("Leave already requested");
      return;
    }
    _requestLeaveData(mainId.toString());
  }

  Future approvedRequestedLeaveData() async {
    isLoaded = false;
    String query =
        '${globals.applictionRootUrl}API/GetLeaveStatusList?DBName=${globals.databaseName}&userId=${globals.userId.toString()}';
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

      leaveApproveRequestedList = List<LeaveModel>.from(mainList);

      if (mounted) {
        setState(() {});
      }
    }
  }

  checkLeaveAlreadyRequestedApproved(String fromDate, String toDate) {
    setState(() {
      inBetweenDatesPresent = false;
    });
    DateTime startDate = DateTime.parse(fromDate.replaceAll("/", "-"));
    DateTime endDate = DateTime.parse(toDate.replaceAll("/", "-"));

    for (int i = 0; i < leaveApproveRequestedList.length; i++) {
      if (leaveApproveRequestedList[i].status.toString().trim() == "2" ||
          leaveApproveRequestedList[i].status.toString().trim() == "1") {
        if (startDate.isAfter(DateTime.parse(leaveApproveRequestedList[i]
                .fromdate
                .toString()
                .trim()
                .split("/")
                .reversed
                .join("/")
                .replaceAll("/", "-"))) &&
            endDate.isBefore(DateTime.parse(leaveApproveRequestedList[i]
                .todate
                .toString()
                .trim()
                .split("/")
                .reversed
                .join("/")
                .replaceAll("/", "-")))) {
          setState(() {
            inBetweenDatesPresent = true;
          });
        }
      }
    }
  }

  List<DateTime> getDaysInBeteween(String fromDate, String toDate) {
    DateTime startDate = DateTime.parse(fromDate.replaceAll("/", "-"));
    DateTime endDate = DateTime.parse(toDate.replaceAll("/", "-"));
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(DateTime(
          startDate.year,
          startDate.month,
          // In Dart you can set more than. 30 days, DateTime will do the trick
          startDate.day + i));
    }
    return days;
  }

  Future _requestLeaveData(String id) async {
    pr?.show();
    String query =
        '${globals.applictionRootUrl}API/LeaveRequestSubmit?DBName=${globals.databaseName}&userId=${globals.userId}&LeaveType=$leaveTypeValue&ReqId=${widget.mainId}&FromDate=$_fromdate&Todate=$_todate&Duration=$session&Reason=${reasonController.text.trim()}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var res = jobject["result"];
      var message = jobject["msg"];
      if (res == true) {
        showInSnackBar("Leave Request Submitted");
        popleaverequest();
      } else {
        showInSnackBar(message);
      }
    } else {
      showInSnackBar("Only employee can request a leave");
    }
    pr?.hide();
  }

  void popleaverequest() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const LeaveAproveRequest()));
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future _leaveEditData() async {
    leaveTypeList.clear();
    leaveTypeList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));
    isLoaded = false;
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/LeaveRequestEdit?DBName=${globals.databaseName}&userId=${globals.userId}&ReqId=${widget.mainId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveTypeitem = jobject["LeaveType"];
      leaveTypeitem.forEach((item) {
        leaveTypeList.add(DropdownMenuItem(
            value: item["LeaveId"].toString(),
            child: Text(item["LeaveCode"].toString())));
      });
      session = jobject["result"]["LeaveSession"] ?? 0;
      String fromdate = jobject["result"]["FDate"] ?? "Select";
      String todate = jobject["result"]["TDate"] ?? "Select";

      if (widget.mainId != 0) {
        _checked.clear();
        var sessiondesc = jobject["result"]["SessionDescription"];
        _checked = [sessiondesc];

        var ltype = jobject["result"]["Leave"];
        if (leaveTypeList.isNotEmpty) {
          leaveTypeValue =
              "${leaveTypeitem.where((element) => element['LeaveId'] == ltype).toList()[0]['LeaveId']}";
        }

        _fromdate = DateFormat("yyyy/MM/dd")
            .format(DateTime.parse(fromdate.split("/").reversed.join("-")));
        _fromdispdate = DateFormat("dd/MM/yyyy")
            .format(DateTime.parse(fromdate.split("/").reversed.join("-")));
        _todate = DateFormat("yyyy/MM/dd")
            .format(DateTime.parse(todate.split("/").reversed.join("-")));
        _todispdate = DateFormat("dd/MM/yyyy")
            .format(DateTime.parse(todate.split("/").reversed.join("-")));
        var reason = jobject["result"]["Reason"];
        reasonController.text = reason;
      }

      if (mounted) {
        setState(() {
          isLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: Container(
        height: 700,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Text(
                        "Leave Type",
                        style: ThemeText.pageHeaderBlack,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      DropdownButton<String>(
                        value: leaveTypeValue,
                        elevation: 0,
                        style: ThemeText.text,
                        onChanged: (String? newValue) {
                          setState(() {
                            leaveTypeValue = newValue!;
                          });
                        },
                        items: leaveTypeList,
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: const Text(
                      "Session",
                      style: ThemeText.pageHeaderBlack,
                    )),
                CheckboxGroup(
                  orientation: GroupedButtonsOrientation.VERTICAL,
                  margin: const EdgeInsets.only(left: 12.0),
                  onSelected: (selected) => setState(() {
                    if (selected.length > 1) {
                      selected.removeAt(0);
                    }
                    if (selected[0] == "Full Day") {
                      isFullDay = true;
                      session = 0;
                    } else if (selected[0] == "First Half") {
                      isFullDay = false;
                      session = 1;
                    } else {
                      isFullDay = false;
                      session = 2;
                    }
                    _checked = selected;
                  }),
                  labels: leaveType,
                  checked: _checked,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isFullDay ? "From" : "Date",
                      style: ThemeText.pageHeaderBlack,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            elevation: 4.0,
                          ),
                          onPressed: () => _selectFromDate(context),
                          child: Container(
                            alignment: Alignment.center,
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            _fromdispdate,
                                            style: ThemeText.text,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 25,
                    ),
                    Visibility(
                      visible: isFullDay,
                      child: const Text(
                        'To',
                        style: ThemeText.pageHeaderBlack,
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Visibility(
                      visible: isFullDay,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              elevation: 4.0,
                            ),
                            onPressed: () => _selectToDate(context),
                            child: Container(
                              alignment: Alignment.center,
                              height: 50.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              _todispdate,
                                              style: ThemeText.text,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )),
                    )
                  ],
                ),
                const Text(
                  "Reason",
                  style: ThemeText.pageHeaderBlack,
                ),
                TextField(
                  autofocus: false,
                  controller: reasonController,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: ElevatedButton(
                          onPressed: () {
                            requestLeave();
                          },
                          child: const Text('Submit',
                              style: TextStyle(color: Colors.white)))),
                ]),
              ]),
        ),
      ),
    );
  }
}

class LeaveBalance {
  LeaveBalance(
      {this.balance,
      this.leave,
      this.leavetaken,
      this.alloted,
      this.encah,
      this.ob,
      this.ex,
      this.lapsed,
      this.leavesum});
  String? leave;
  String? leavesum;
  String? leavetaken;
  String? balance;
  String? ob;
  String? alloted;
  String? encah;
  String? lapsed;
  String? ex;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leave: json['leave'] == null ? "" : json['leave'].toString(),
      leavesum: json['Leave'] == null ? "" : json['Leave'].toString(),
      leavetaken:
          json['leavetaken'] == null ? "" : json['leavetaken'].toString(),
      balance: json['balance'] == null ? "" : json['balance'].toString(),
      ob: json['balance'] == null ? "" : json['balance'].toString(),
      alloted: json['balance'] == null ? "" : json['balance'].toString(),
      encah: json['balance'] == null ? "" : json['balance'].toString(),
      lapsed: json['balance'] == null ? "" : json['balance'].toString(),
      ex: json['balance'] == null ? "" : json['balance'].toString(),
    );
  }
}

class ApproverModel {
  ApproverModel({this.userid});
  int? userid;
  factory ApproverModel.fromJson(Map<String, dynamic> json) {
    return ApproverModel(
      userid: json['UserID'] ?? 0,
    );
  }
}
