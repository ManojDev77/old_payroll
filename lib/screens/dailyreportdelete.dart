import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class DailyWorkReportDelete extends StatefulWidget {
  final TabController tabController;

  const DailyWorkReportDelete({Key? key, required this.tabController})
      : super(key: key);

  @override
  _DailyWorkReportDeleteState createState() => _DailyWorkReportDeleteState();
}

class _DailyWorkReportDeleteState extends State<DailyWorkReportDelete> {
  List<ReportModel> mainTaskDeleteList = [];
  bool isLoaded = false;
  @override
  void initState() {
    globals.taskidnew = "";
    globals.taskdate = "";
    globals.taskhours = 0.0;
    globals.taskremark = "";
    globals.tabid = 0;
    dailyreportrequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : mainTaskDeleteList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        1: FlexColumnWidth(),
                        //2: FixedColumnWidth(64),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: createTableEntryDelete()),
                )
              : Center(
                  child: Text(
                    "No Records Found".toUpperCase(),
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontFamily: "poppins-medium"),
                  ),
                ),
    );
  }

  List<TableRow> createTableEntryDelete() {
    List<TableRow> rows = [];
    rows.add(const TableRow(
        decoration: BoxDecoration(color: Color(0xfffaebd7)),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "Action",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "Task",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "Date",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "Hours",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "Remarks",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
        ]));
    for (int i = 0; i < mainTaskDeleteList.length; i++) {
      rows.add(TableRow(children: <Widget>[
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                  onTap: () {
                    globals.taskidnew = mainTaskDeleteList[i].task!;
                    globals.taskdate = mainTaskDeleteList[i].datereport!;
                    globals.taskhours = mainTaskDeleteList[i].wrkhr!;
                    globals.taskremark = mainTaskDeleteList[i].remark!;
                    globals.tabid = mainTaskDeleteList[i].id!;
                    widget.tabController.animateTo(1);
                  },
                  child: const Icon(
                    Icons.edit,
                    size: 15,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                  onTap: () {
                    showAlertDlgDeleteEmp(context, mainTaskDeleteList[i].id!);
                  },
                  child: const Icon(
                    Icons.delete,
                    size: 15,
                  )),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            mainTaskDeleteList[i].task!,
            style: ThemeText.text,
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            mainTaskDeleteList[i].datereport!,
            style: ThemeText.text,
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            mainTaskDeleteList[i].wrkhr.toString(),
            style: ThemeText.text,
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            mainTaskDeleteList[i].remark.toString(),
            style: ThemeText.text,
            textAlign: TextAlign.start,
          ),
        ),
      ]));
    }

    return rows;
  }

  showAlertDlgDeleteEmp(BuildContext context, int iddelete) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        deletereport(iddelete);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Alert!",
      ),
      content: const Text(
        "Are you sure to delete?",
        style: ThemeText.text,
      ),
      actions: [
        cancelButton,
        okButton,
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

  Widget adminlist() {
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mainTaskDeleteList.length,
        itemBuilder: (context, index) {
          return adminRow(mainTaskDeleteList[index], index);
        },
      ),
    );
  }

  Widget adminRow(ReportModel report, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 2.0, right: 2.0, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    report.task!,
                    style: ThemeText.text,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    report.datereport!,
                    style: ThemeText.text,
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text(
                    report.wrkhr.toString(),
                    style: ThemeText.text,
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: 20,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            deletereport(report.id!);
                          },
                          child: const Icon(
                            Icons.delete,
                            size: 15,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          const Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  deletereport(int iddelete) async {
    String query =
        '${globals.applictionRootUrl}API/DeleteDailyReport?DBName=${globals.databaseName}&UserId=${globals.userId}&Id=$iddelete';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Deleted Successfully"),
        duration: Duration(seconds: 2),
      ));

      dailyreportrequest();
    }
  }

  Future dailyreportrequest() async {
    String query =
        '${globals.applictionRootUrl}API/DailyReportSearch?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      var list = jobject["DailyReportList"];
      var mainList = list.map((e) => ReportModel.fromJson(e)).toList();

      mainTaskDeleteList = List<ReportModel>.from(mainList);
    }

    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }
}

class ReportModel {
  ReportModel(
      {this.task,
      this.id,
      this.datereport,
      this.wrkhr,
      this.remark,
      this.previuos});
  String? task;
  int? id;
  String? datereport;
  double? wrkhr;
  String? remark;
  bool? previuos;
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      task: json['TaskIDName'] ?? "",
      id: json['Id'] ?? 0,
      datereport: json['WDate'] ?? "",
      wrkhr: json['WorkedHours'] ?? 0.0,
      remark: json['Remarks'] ?? "",
      previuos: json['PreviousTask'] ?? false,
    );
  }
}
