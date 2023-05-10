import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';
import 'dart:async';
import '../constants/style.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'leave_report.dart';
import 'leave_status.dart';
import 'monthly_leave_report.dart';

class LeaveDetails extends StatefulWidget {
  const LeaveDetails({Key? key}) : super(key: key);

  @override
  LeaveApplicationWidgetState createState() => LeaveApplicationWidgetState();
}

class LeaveApplicationWidgetState extends State<LeaveDetails>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoaded = false;
  List<LeaveBalance> mainLeavebalanceList = [];
  String yearListValue = "";
  ProgressDialog? pr;
  List<DropdownMenuItem<String>> monthList = [];
  List<DropdownMenuItem<String>> yearList = [];
  String empValue = "";
  List<String> empList = [];
  var mainEmployeeList = [];
  List<dynamic> empitem = [];

  @override
  void initState() {
    _getEmployeeData();

    super.initState();
  }

  Future _getEmployeeData() async {
    empList.clear();
    setState(() {
      isLoaded = false;
    });
    mainEmployeeList = await GetEmployee().getEmployeeData();
    if (mounted) {
      for (var item in mainEmployeeList) {
        empList.add(item.empname ?? "");
      }
      try {
        empValue = mainEmployeeList
                .where((element) => element.userid == globals.userId)
                .toList()[0]
                .empname ??
            empList[0];
      } catch (e) {
        empValue = empList[0];
      }
      setState(() {});
    }
    await _getpleaveyearlist();
  }

  leaveBalance() async {
    setState(() {
      mainLeavebalanceList.clear();
    });

    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/LeaveBalance?DBName=' : 'API/LoginOFFLeaveBalance?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() :
            // getuseridfname(empValue).toString()
            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}"}${!globals.employeelogin ? ("&EmpID="
            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].empid}") : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["LeaveEntry_dgrDataLeaveList"];

      var mainList = list.map((e) => LeaveBalance.fromJson(e)).toList();

      mainLeavebalanceList = List<LeaveBalance>.from(mainList);
      setState(() {});
    }
  }

  _getpleaveyearlist() async {
    yearList.clear();
    yearList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));

    String query =
        '${globals.applictionRootUrl}API/GetLeaveYearList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var yearitems = jobject;
      if (mounted) {
        yearitems.forEach((item) {
          yearList.add(DropdownMenuItem(
              value: item["Text"].toString(),
              child: Text(item["Text"].toString())));
        });
        yearList.reversed.toList();

        if (yearList.length > 1) {
          yearListValue = yearList[1].value!;
          leaveBalanceSummary();
        }

        setState(() {});
      }
    }
  }

  leaveBalanceSummary() async {
    setState(() {
      mainLeavebalanceList.clear();
    });

    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/LeaveSummaryDetails?DBName=' : 'API/LoginOFFLeaveSummaryDetails?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() :
            //getuseridfname(empValue).toString()
            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}"}&fy=${yearListValue.substring(0, 4)}${!globals.employeelogin ? ("&EmpID="
            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}") : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => LeaveBalance.fromJson(e)).toList();
      if (mounted) {
        mainLeavebalanceList = List<LeaveBalance>.from(mainList);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  !globals.isEmployee
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSearchBox: empList.length < 5 ? false : true,
                              showAsSuffixIcons: true,
                              maxHeight: empList.length > 5 ? 500 : 200,
                              items: empList,
                              label: "Employee",
                              hint: "Select Employee",
                              onChanged: (String? newValue) async {
                                setState(() {
                                  empValue = newValue!;
                                });
                              },
                              selectedItem: empValue))
                      : Row(),
                ]),
                SizedBox(
                  height: 500,
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: <Widget>[
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Leavedownload(
                                        empvalue:
                                            //  getuseridfname(empValue).toString()
                                            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}",
                                        empName: empValue,
                                      )),
                            );
                          },
                          child: const Center(
                              child: Text("Leave Download",
                                  textAlign: TextAlign.center)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: ElevatedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Loading....")));
                            _getpleaveyearlist();
                            await leaveBalanceSummary();
                            Future.delayed(const Duration(seconds: 2), () {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(60))),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return buildSheet();
                                  });
                            });
                          },
                          child: const Center(
                              child: Text("Leave Summary",
                                  textAlign: TextAlign.center)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LeaveReportPage(
                                        empid:
                                            // getuseridfname(empValue).toString()
                                            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].empid}",
                                      )),
                            );
                          },
                          child: const Center(
                              child: Text("Leave Report",
                                  textAlign: TextAlign.center)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LeaveStatusWidget(
                                        empvalue:
                                            // getuseridfname(empValue).toString()
                                            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}",
                                      )),
                            );
                          },
                          child: const Center(
                              child: Text("Leave Status",
                                  textAlign: TextAlign.center)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: ElevatedButton(
                          onPressed: () {
                            leaveBalance();
                            Future.delayed(const Duration(seconds: 2), () {
                              showModalBottomSheet(
                                  enableDrag: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(60))),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) =>
                                      buildSheetLeaveBalance());
                            });
                          },
                          child: const Center(
                              child: Text("Leave Balance",
                                  textAlign: TextAlign.center)),
                        ),
                      ),
                    ],
                  ),
                ),
              ]))),
    );
  }

  // int getuseridfname(String idname) {
  //   int idemp = 0;

  //   for (int i = 0; i < mainEmployeeList.length; i++) {
  //     if (mainEmployeeList[i].empname == idname) {
  //       idemp = mainEmployeeList[i].userid;

  //       return idemp;
  //     }
  //   }
  //   return idemp;
  // }

  Widget buildSheet() {
    return DraggableScrollableSheet(
        minChildSize: 0.3,
        maxChildSize: 0.6,
        initialChildSize: 0.3,
        builder: (_, controller) => Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  shrinkWrap: true,
                  controller: controller,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        globals.yearType == 0 ? 'Calendar Year' : 'F.Y',
                        style: ThemeText.pageHeaderBlack,
                      ),
                      const SizedBox(width: 30),
                      DropdownButton<String>(
                        style: ThemeText.text,
                        hint: const Text("Year"),
                        value: yearListValue,
                        elevation: 0,
                        onChanged: (String? newValue) async {
                          setState(() {
                            yearListValue = newValue!;
                          });

                          Navigator.pop(context);
                          await leaveBalanceSummary();
                          Future.delayed(const Duration(seconds: 1), () {
                            showModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(60))),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return buildSheet();
                                });
                          });
                        },
                        items: yearList,
                      ),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    mainLeavebalanceList.isNotEmpty
                        ? Table(
                            border: TableBorder.all(color: Colors.grey),
                            columnWidths: const <int, TableColumnWidth>{
                              1: FlexColumnWidth(),
                              2: FixedColumnWidth(64),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: createSummaryTable())
                        : const Center(
                            heightFactor: 3,
                            child: Text("No Records Found",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                )),
                          )
                  ],
                ),
              ),
            ));
  }

  List<TableRow> createLeaveBalance() {
    List<TableRow> rows = [];
    rows.add(const TableRow(
        decoration: BoxDecoration(
          color: Color(0xfffaebd7),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Type",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "O.B",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Taken",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Balance",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
        ]));
    for (int i = 0; i < mainLeavebalanceList.length; i++) {
      rows.add(TableRow(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mainLeavebalanceList[i].leave!,
                style: ThemeText.text, textAlign: TextAlign.center)),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${mainLeavebalanceList[i].openingbalance}",
                style: ThemeText.text, textAlign: TextAlign.end)),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mainLeavebalanceList[i].leavetaken!,
                style: ThemeText.text, textAlign: TextAlign.end)),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mainLeavebalanceList[i].balance!,
                style: ThemeText.text, textAlign: TextAlign.end)),
      ]));
    }
    return rows;
  }

  List<TableRow> createSummaryTable() {
    List<TableRow> rows = [];

    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("O.B", style: ThemeText.text),
      ),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(mainLeavebalanceList[0].ob!,
              style: ThemeText.text, textAlign: TextAlign.end)),
    ]));
    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Alloted", style: ThemeText.text),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(mainLeavebalanceList[0].alloted!,
            style: ThemeText.text, textAlign: TextAlign.end),
      ),
    ]));
    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Leave", style: ThemeText.text),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(mainLeavebalanceList[0].leavesum!,
            style: ThemeText.text, textAlign: TextAlign.end),
      ),
    ]));
    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Encash", style: ThemeText.text),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(mainLeavebalanceList[0].encah!,
            style: ThemeText.text, textAlign: TextAlign.end),
      ),
    ]));
    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Lapsed", style: ThemeText.text),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(mainLeavebalanceList[0].lapsed!,
            style: ThemeText.text, textAlign: TextAlign.end),
      ),
    ]));
    rows.add(TableRow(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Ex", style: ThemeText.text),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(mainLeavebalanceList[0].ex!,
            style: ThemeText.text, textAlign: TextAlign.end),
      ),
    ]));
    rows.add(TableRow(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 255, 250, 205)),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Balance",
              style: ThemeText.resultText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mainLeavebalanceList[0].balance!,
                style: ThemeText.resultText, textAlign: TextAlign.end),
          ),
        ]));

    return rows;
  }

  Widget buildSheetLeaveBalance() => DraggableScrollableSheet(
        initialChildSize: 0.3,
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
            child: mainLeavebalanceList.isNotEmpty
                ? Table(
                    border: TableBorder.all(),
                    columnWidths: const <int, TableColumnWidth>{
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(64),
                    },
                    children: createLeaveBalance())
                : const Center(
                    heightFactor: 5,
                    child: Text(
                      "No Records Found",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
          ),
        ),
      );
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
      this.leavesum,
      this.openingbalance});
  String? leave;
  String? leavesum;
  String? leavetaken;
  String? balance;
  String? ob;
  String? alloted;
  String? encah;
  String? lapsed;
  String? ex;
  double? openingbalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leave: json['leave'] == null ? "" : json['leave'].toString(),
      leavesum: json['Leave'] == null ? "" : json['Leave'].toString(),
      leavetaken:
          json['leavetaken'] == null ? "" : json['leavetaken'].toString(),
      balance: json['balance'] == null ? "" : json['balance'].toString(),
      ob: json['Ob'] == null ? "" : json['Ob'].toString(),
      openingbalance: json['openingbalance'] ?? 0.0,
      alloted: json['alloted'] == null ? "" : json['alloted'].toString(),
      encah: json['Encash'] == null ? "" : json['Encash'].toString(),
      lapsed: json['Lapse'] == null ? "" : json['Lapse'].toString(),
      ex: json['extraworking'] == null ? "" : json['extraworking'].toString(),
    );
  }
}
