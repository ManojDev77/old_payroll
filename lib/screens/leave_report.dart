import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/style.dart';
import 'dart:convert';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as dateformat;

class LeaveReportPage extends StatefulWidget {
  final String? empid;
  const LeaveReportPage({Key? key, @required this.empid}) : super(key: key);

  static const androidIcon = Icon(Icons.receipt);

  @override
  _LeaveReportPageState createState() => _LeaveReportPageState();
}

class _LeaveReportPageState extends State<LeaveReportPage>
    with WidgetsBindingObserver {
  Color primaryColor = const Color.fromRGBO(30, 144, 255, 1);
  List<LeaveReportModel> mainInvoiceList = [];
  List<LeaveReportModel> mainInvoiceList2 = [];
  TextEditingController searchcontroller = TextEditingController();
  List<LeaveReportModel> searchList = [];
  List<LeaveReportModel> leaveReportList = [];
  bool isLoaded = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _getLeaveData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getLeaveData() async {
    isLoaded = false;

    String query = globals.applictionRootUrl +
        'API/EmployeeLeaveReport?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        "&EmpId=" +
        widget.empid! +
        '&LeaveCode=' +
        '&EmpName=' +
        '&Session=' +
        '&Date=';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["EmployeeLeaveDetailsList"];
      var mainList = list.map((e) => LeaveReportModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainInvoiceList = List<LeaveReportModel>.from(mainList);

          final idReport = <dynamic>{};
          mainInvoiceList.retainWhere((x) => idReport.add(x.fromdate));
          leaveReportList = mainInvoiceList;
        });
      }
      _getExtraData();
    }
  }

  Future _getExtraData() async {
    //EmployeeExtraWorkReport(string DBName, int UserId,int EmpId, string LeaveCode = "",
    // string Session = "", string EmpName = "", string FromDate = "")
    String query = globals.applictionRootUrl +
        'API/EmployeeExtraWorkReport?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        "&EmpId=" +
        widget.empid! +
        '&LeaveCode=' +
        '&Session=' +
        '&EmpName=' +
        '&FromDate=';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["ExtraWorkingSearchList"];
      var mainList = list.map((e) => LeaveReportModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainInvoiceList2 = List<LeaveReportModel>.from(mainList);
          mainInvoiceList.addAll(mainInvoiceList2);
          final idReport = <dynamic>{};
          mainInvoiceList.retainWhere((x) => idReport.add(x.fromdate));

          mainInvoiceList.sort((a, b) => DateFormat('dd/MM/yyyy')
              .parse(b.fromdate!)
              .compareTo(DateFormat('dd/MM/yyyy').parse(a.fromdate!)));
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
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text("Leave Report"),
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.search),
                        title: TextField(
                            autofocus: false,
                            controller: searchcontroller,
                            decoration: const InputDecoration(
                                hintText: 'Search', border: InputBorder.none),
                            onChanged: onSearchTextChanged),
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
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: mainInvoiceList.isNotEmpty
                        ? ListView.builder(
                            itemCount: mainInvoiceList.length,
                            itemBuilder: (context, index) {
                              return buildLeaveListAdmin(
                                  mainInvoiceList[index], index);
                            },
                          )
                        : const Center(
                            child: Text(
                              "No Records Found",
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  onSearchTextChanged(String text) async {
    searchList.clear();

    String textsearch = text.toLowerCase();
    for (var detail in leaveReportList) {
      if (detail.leavecode!.toLowerCase().contains(textsearch) ||
          detail.reason.toString().toLowerCase().contains(textsearch) ||
          detail.type.toString().toLowerCase().contains(textsearch) ||
          detail.fromdate!.toLowerCase().contains(textsearch) ||
          detail.empname.toString().toLowerCase().contains(textsearch)) {
        searchList.add(detail);
      }
    }
    if (textsearch.isNotEmpty) {
      mainInvoiceList = searchList;
    } else {
      mainInvoiceList = leaveReportList;
    }
    setState(() {});
  }

  onSearchTextChangedemp(String text) async {
    searchList.clear();
    String textsearch = text.toLowerCase();
    for (var detail in leaveReportList) {
      if (detail.leavecode!.toLowerCase().contains(textsearch) ||
          detail.reason.toString().toLowerCase().contains(textsearch) ||
          detail.type.toString().toLowerCase().contains(textsearch) ||
          detail.fromdate.toString().toLowerCase().contains(textsearch) ||
          detail.empname.toString().toLowerCase().contains(textsearch)) {
        searchList.add(detail);
      }
    }
    if (textsearch.isNotEmpty) {
      mainInvoiceList = searchList;
    } else {
      mainInvoiceList = leaveReportList;
    }
    setState(() {});
  }

  Widget buildLeaveListAdmin(LeaveReportModel data, int index) {
    return Center(
      child: Card(
          color: const Color(0XffEEEEEE),
          margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(64),
            }, children: <TableRow>[
              TableRow(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    "Employee   : ",
                    style: ThemeText.pageHeaderBlack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    data.empname!,
                    style: ThemeText.pageHeaderBlack,
                  ),
                ),
              ]),
              TableRow(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    "Leave Date : ",
                    style: ThemeText.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    data.fromdate!,
                    style: ThemeText.text,
                  ),
                ),
              ]),
              TableRow(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    "Type            : ",
                    style: ThemeText.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    " (${data.leavecode}) ${data.type}",
                    style: ThemeText.text,
                  ),
                ),
              ]),
              TableRow(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    "Reason       : ",
                    style: ThemeText.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    data.reason!,
                    style: ThemeText.text,
                  ),
                )
              ]),
            ]),
          )),
    );
  }
}

class LeaveReportModel {
  const LeaveReportModel(
      {this.leavecode, this.fromdate, this.empname, this.reason, this.type});

  final String? leavecode;
  final String? fromdate;
  final String? empname;
  final String? reason;
  final String? type;
  factory LeaveReportModel.fromJson(Map<String, dynamic> json) {
    return LeaveReportModel(
      leavecode: json['leavecode'] == null ? "" : json['leavecode'].toString(),
      fromdate: json['fromdate'] == null
          ? ''
          : getdatefrommilisec(json['fromdate'].toString()),
      empname: json['empname'] ?? "",
      reason: json['reason'] ?? "",
      type: json['listdesc'] ?? "",
    );
  }
  static String getdatefrommilisec(String date) {
    var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
    var orDate = DateTime.fromMillisecondsSinceEpoch(oDate!);
    String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
    return orderDate;
  }
}
