import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:async';
import '../constants/style.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class SalaryConfig extends StatefulWidget {
  final String? empvalue;
  const SalaryConfig({Key? key, this.empvalue}) : super(key: key);
  @override
  _SalaryConfigState createState() => _SalaryConfigState();
}

class _SalaryConfigState extends State<SalaryConfig> {
  List<SalaryConfiguration> mainSalaryConfigList = [];
  List<SalaryConfigurationStruct> mainSalaryConfigListStruct = [];
  int value = 0;
  String? compname;
  String? compvalue;
  bool onpressed = false;
  List items = [];
  List items2 = [];
  List<EmployeeId>? mainEmployeeList = [];
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();

    _salaryConfiguration();
  }

  Future<void> _salaryConfiguration() async {
    setState(() {
      isLoaded = false;
    });
    await _getEmployeeData();
    // LoginOFFSalaryConfiguration(string DBName, int UserId, int EmpID)
    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/SalaryConfiguration?DBName=' : 'API/LoginOFFSalaryConfiguration?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : widget.empvalue!}${!globals.employeelogin ? '&EmpID=' + widget.empvalue! : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => SalaryConfiguration.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainSalaryConfigList = List<SalaryConfiguration>.from(mainList);
          mainSalaryConfigList
              .sort((b, a) => b.frmmonth!.compareTo(a.frmmonth!));
          mainSalaryConfigList
              .sort((b, a) => b.frmmonth!.compareTo(a.frmmonth!));
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  Future _getEmployeeData() async {
    mainEmployeeList = await GetEmployee().getEmployeeData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _salaryConfigurationstruc(int salconfigid) async {
    items.clear();
    items2.clear();
    //LoginOFFSalaryConfigurationStructure(string DBName, int UserId, int SalaryConfigId, int EmpID)
    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/SalaryConfigurationStructure?DBName=' : 'API/LoginOFFSalaryConfigurationStructure?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : widget.empvalue!}&SalaryConfigId=$salconfigid${!globals.employeelogin ? '&EmpID=' + widget.empvalue! : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      var list = jobject["Item1"];
      var list2 = jobject["Item2"];

      if (list.length != 0) {
        items.add("Earnings");
        items2.add("");
        for (int i = 0; i < list.length; i++) {
          compname = list[i]["Value"];
          items.add(compname);
          compvalue = list[i]["Text"];
          items2.add(compvalue);
        }
      }

      if (list2.length != 0) {
        items.add("");
        items.add("Deductions");
        items2.add("");
        items2.add("");
        for (int i = 0; i < list2.length; i++) {
          compname = list2[i]["Value"];
          items.add(compname);
          compvalue = list2[i]["Text"];
          items2.add(compvalue);
        }
      }
      // if (items2.isNotEmpty) {
      //   setState(() {
      //     value = items2.length;
      //   });
      // }

      var mainList =
          list.map((e) => SalaryConfigurationStruct.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          mainSalaryConfigListStruct =
              List<SalaryConfigurationStruct>.from(mainList);
        });
      }
      showModalBottomSheet(
          enableDrag: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(60))),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => buildSheetLeaveBalance());
    }
  }

  List<TableRow> _buildRow() {
    List<TableRow> rows = [];
    for (int i = 0; i < items.length; i++) {
      rows.add(
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(items[i],
                style: TextStyle(
                    fontWeight:
                        items[i] == "Earnings" || items[i] == "Deductions"
                            ? FontWeight.bold
                            : null)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              items2[i],
              style: ThemeText.text,
              textAlign: TextAlign.end,
            ),
          ),
        ]),
      );
    }
    return rows;
  }

  Widget buildSheetLeaveBalance() => DraggableScrollableSheet(
        minChildSize: 0.1,
        maxChildSize: 0.7,
        initialChildSize: 0.1,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          //  color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              controller: controller,
              children: [
                const Text(
                  "Salary Details",
                  style: ThemeText.pageHeaderBlue,
                ),
                const SizedBox(
                  height: 10,
                ),
                items2.isNotEmpty
                    ? Row(
                        children: [
                          const Text(
                            "Employee",
                            style: ThemeText.pageHeaderBlack,
                          ),
                          Text(
                            " : "
                            "${mainEmployeeList!.where((element) => element.userid == (globals.isEmployee ? globals.userId : int.parse(widget.empvalue!))).toList()[0].empname}",
                            style: ThemeText.pageHeaderBlack,
                          ),
                        ],
                      )
                    : const Text(""),
                const SizedBox(
                  height: 15,
                ),
                items2.isNotEmpty
                    ? Table(
                        border: TableBorder.all(),
                        columnWidths: const <int, TableColumnWidth>{
                          // 0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(64),
                        },
                        children: _buildRow())
                    : const Center(
                        child: Text("No Records Found"),
                      ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text("Salary Configuration"),
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : mainSalaryConfigList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: mainSalaryConfigList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 55,
                        ),
                        child: Column(children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            color: const Color(0xffeeeeee),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                /// Add this
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      "Employee : "
                                      "${mainEmployeeList!.where((element) => element.userid == (globals.isEmployee ? globals.userId : int.parse(widget.empvalue!))).toList()[0].empname}",
                                      style: ThemeText.pageHeaderBlack),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "From Month ",
                                            style: ThemeText.text,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "To Month ",
                                            style: ThemeText.text,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ": ${mainSalaryConfigList[index].frmmonth!}",
                                            style: ThemeText.text,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            ": ${mainSalaryConfigList[index].tomonth!}",
                                            style: ThemeText.text,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    columnWidths: const <int, TableColumnWidth>{
                                      // 0: IntrinsicColumnWidth(),
                                      // 1: FlexColumnWidth(),
                                      2: FixedColumnWidth(64),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: <TableRow>[
                                      TableRow(
                                        children: <Widget>[
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Earnings",
                                              style: ThemeText.text,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8.0,
                                                right: 5),
                                            child: Text(
                                              "${mainSalaryConfigList[index].totalearning}",
                                              style: ThemeText.text,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: <Widget>[
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Deductions",
                                              style: ThemeText.text,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8.0,
                                                right: 5),
                                            child: Text(
                                              "${mainSalaryConfigList[index].totaldeuc}",
                                              textAlign: TextAlign.end,
                                              style: ThemeText.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: <Widget>[
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Net Amount",
                                              style: ThemeText.text,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8.0,
                                                right: 5),
                                            child: Text(
                                              "${mainSalaryConfigList[index].netamt}",
                                              textAlign: TextAlign.end,
                                              style: ThemeText.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      child: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 30,
                                      ),
                                      onTap: () {
                                        _salaryConfigurationstruc(
                                            mainSalaryConfigList[index]
                                                .salaryconfigid!);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]));
                  })
              : const Center(
                  child: Text(
                  "No Records Found",
                  style: TextStyle(fontSize: 30),
                )),
    );
  }
}

class SalaryConfiguration {
  SalaryConfiguration(
      {this.frmmonth,
      this.netamt,
      this.refno,
      this.tomonth,
      this.totaldeuc,
      this.totalearning,
      this.compvalue,
      this.printname,
      this.salaryconfigid});
  String? frmmonth;
  String? tomonth;
  String? refno;
  double? totalearning;
  double? totaldeuc;
  double? netamt;
  double? compvalue;
  String? printname;
  int? salaryconfigid;
  factory SalaryConfiguration.fromJson(Map<String, dynamic> json) {
    return SalaryConfiguration(
      frmmonth: json['From_MonthYearName'] ?? "",
      tomonth: json['To_MonthYearName'] ?? "",
      refno: json['refNo'] ?? "",
      totalearning: json['TotalEarnings'] ?? 0.0,
      totaldeuc: json['TotalDeduction'] ?? 0.0,
      netamt: json['NetAmount'] ?? 0.0,
      compvalue: json['ComponentValue'] ?? 0.0,
      salaryconfigid: json['SalaryConfigID'] ?? 0,
      // printname: json['PrintNAme'] == null ? 0.0 : json['PrintNAme'],
    );
  }
}

class SalaryConfigurationStruct {
  SalaryConfigurationStruct({this.basic, this.hra, this.da});
  String? basic;
  String? hra;
  String? da;

  factory SalaryConfigurationStruct.fromJson(Map<String, dynamic> json) {
    return SalaryConfigurationStruct(
      basic: json['Text'] ?? 0.0,
      hra: json['Text'] ?? 0.0,
      da: json['Text'] ?? 0,
    );
  }
}
