import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import '../constants/style.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'salaryconfig.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'upcoming_holidays.dart';

class SalaryDetailspage extends StatefulWidget {
  const SalaryDetailspage({Key? key}) : super(key: key);

  @override
  _SalaryDetailspageState createState() => _SalaryDetailspageState();
}

class _SalaryDetailspageState extends State<SalaryDetailspage>
    with WidgetsBindingObserver {
  Color primaryColor = const Color.fromRGBO(30, 144, 255, 1);
  List<MonthListModel> mainSalaryDetailsList = [];
  String empValue = "";
  TextEditingController searchcontroller = TextEditingController();
  List<MonthListModel> searchList = [];
  List<MonthListModel> salaryList = [];
  List<MonthModel> mainMonthList = [];
  List<SalaryConfiguration> mainSalaryConfigList = [];
  List<SalaryConfigurationStruct> mainSalaryConfigListStruct = [];
  var mainEmployeeList = [];
  List<DropdownMenuItem<String>> dropDownItems = [];
  String? currentItem;
  List<String> empList = [];
  bool isLoaded = false;
  bool issalloaded = false;
  String monthListValue = "";
  String yearListValue = "";
  int? cleckedindex;
  bool loaded = false;
  bool issalclicked = false;
  bool salaryclickedstruct = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List items1 = [];
  List items11 = [];
  int finallength = 0;
  List<DropdownMenuItem<String>> monthList = [];
  List<DropdownMenuItem<String>> yearList = [];
  List<dynamic> empitem = [];
  @override
  void initState() {
    _getEmployeeData();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getEmployeeData() async {
    salaryList.clear();
    mainMonthList.clear();
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
    await _getpayrollyearlist();
  }

  Future<void> salaryDetailsData(String monthListValue, int id) async {
    // mainSalaryDetailsList.clear();
    // salaryList.clear();
    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/GetSalaryDetails?DBName=' : 'API/LoginOFFGetSalaryDetails?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : "$id"}&MonthId=$monthListValue${!globals.employeelogin ? ("&EmpID=" "$id") : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => MonthListModel.fromJson(e)).toList();
      mainSalaryDetailsList = List<MonthListModel>.from(mainList);
      if (mounted) {
        salaryList.addAll(mainSalaryDetailsList);
        salaryList.sort((a, b) => b.monthid!.compareTo(a.monthid!));
      }
    }

    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  Future<void> _salarBreakup(String monthid, int id) async {
    setState(() {
      issalloaded = false;
    });

    String query =
        '${globals.applictionRootUrl}${globals.employeelogin ? 'API/MonthkySalaryBreakup?DBName=' : 'API/LoginOFFMonthkySalaryBreakup?DBName='}${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : id.toString()}&MonthID=$monthid${!globals.employeelogin ? ("&EmpID=" + mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid
            //getuseridfname(empValue).toString()
            ) : ""}';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list1 = jobject['Item1'];
      var list2 = jobject['Item2'];
      var list3 = jobject['Item3'];
      var list4 = jobject['Item4'];
      var list5 = jobject['Item5'];
      var list6 = jobject['Item6'];
      var list7 = jobject['Item7'];

      var value6 = list6.length;
      var value7 = list7.length;
      if (list1 != null && list3 != null && list4 != null) {
        items1.clear();
        items11.clear();

        setState(() {
          finallength = (12 + value6 + value7).toInt();
          issalloaded = true;
        });

        items1.add("Salary Days ");
        items11.add(list1);

        items1.add("LOP ");
        items11.add(list2);

        items1.add("");
        items11.add("");

        items1.add("Earnings");
        items11.add("");

        for (int i = 0; i < value6; i++) {
          items11.add(list6[i]["Text"]);
          items1.add(list6[i]["Value"]);
        }

        items1.add(
          "Total Earnings",
        );
        items11.add(list3);

        items1.add("");
        items11.add("");

        items1.add("Deductions");
        items11.add("");

        for (int i = 0; i < value7; i++) {
          items11.add(list7[i]["Text"]);
          items1.add(list7[i]["Value"]);
        }

        items1.add("Total Deductions");
        items11.add(list4);
        items1.add("");
        items11.add("");

        items1.add("Net Amount");
        items11.add(list5);
        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(60))),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => buildSheetSalaryDetails());
      }
    }
  }

  List<TableRow> _buildRow() {
    List<TableRow> rows = [];

    for (int i = 0; i < items1.length; i++) {
      rows.add(TableRow(
          decoration: BoxDecoration(
            color: (items1[i] == "Total Earnings" ||
                    items1[i] == "Total Deductions" ||
                    items1[i] == "Net Amount")
                ? const Color.fromARGB(255, 255, 250, 205)
                : Colors.white,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("${items1[i]}",
                  style: TextStyle(
                      color: (items1[i] == "Total Earnings" ||
                              items1[i] == "Total Deductions" ||
                              items1[i] == "Net Amount")
                          ? const Color.fromARGB(255, 89, 38, 20)
                          : Colors.black,
                      fontSize: 15,
                      fontWeight:
                          (items1[i] == "Earnings" || items1[i] == "Deductions")
                              ? FontWeight.bold
                              : null)),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("${items11[i]}",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: (items1[i] == "Total Earnings" ||
                              items1[i] == "Total Deductions" ||
                              items1[i] == "Net Amount")
                          ? const Color.fromARGB(255, 89, 38, 20)
                          : Colors.black,
                      fontSize: 15)),
            ),
          ]));
    }

    return rows;
  }

  Widget buildSheetSalaryDetails() => DraggableScrollableSheet(
        minChildSize: 0.1,
        maxChildSize: 0.9,
        initialChildSize: 0.1,
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
                const Text(
                  "Salary Details",
                  style: ThemeText.pageHeaderBlue,
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Employee",
                              style: ThemeText.pageHeaderBlack,
                            ),
                            Text(
                              " : " +
                                  ((globals.isEmployee
                                      ?
                                      // getusername(
                                      //     int.parse(globals.userId.toString()))
                                      mainEmployeeList
                                          .where((element) =>
                                              element.userid == globals.userId)
                                          .toList()[0]
                                          .empname
                                      : empValue)),
                              style: ThemeText.pageHeaderBlack,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Table(
                            border: TableBorder.all(color: Colors.grey),
                            columnWidths: const {
                              1: FlexColumnWidth(),
                              2: FixedColumnWidth(64),
                            },
                            children: _buildRow()),
                      ],
                    )),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      );

  _getpayrollyearlist() async {
    yearList.clear();
    yearList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));

    String query =
        '${globals.applictionRootUrl}API/GetPayrollYearList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var yearitems = jobject;
      if (response.body != "[]") {
        if (mounted) {
          setState(() {
            yearitems.forEach((item) {
              yearList.add(DropdownMenuItem(
                  value: item["Value"].toString(),
                  child: Text(item["Text"].toString())));
            });

            if (yearList.isNotEmpty) {
              yearListValue = yearList[1].value!;
              _getpayrollmonthlist();
            }
          });
        }
      }
    }
  }

  _getpayrollmonthlist() async {
    setState(() {
      salaryList.clear();
      mainMonthList.clear();
    });

    String query =
        '${globals.applictionRootUrl}API/GetPayrollYearWiseMonthList?DBName=${globals.databaseName}&UserId=${globals.userId}&YearId=$yearListValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => MonthModel.fromJson(e)).toList();
      if (mounted) {
        mainMonthList = List<MonthModel>.from(mainList);
      }
      int id = mainEmployeeList
          .where((element) => element.empname == empValue)
          .toList()[0]
          .userid;

      //getuseridfname(empValue).toString();

      salaryList.clear();

      for (var item in mainMonthList) {
        salaryDetailsData(item.monthid!, id);
      }
    }
  }

  String accountValue = "";
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text("Salary Details"),
        ),
        body: !isLoaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: SizedBox(
                width: MediaQuery.of(context).size.width - 10,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      !globals.isEmployee
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: DropdownSearch<String>(
                                  mode: Mode.MENU,
                                  showSearchBox:
                                      empList.length < 5 ? false : true,
                                  showAsSuffixIcons: true,
                                  maxHeight: empList.length > 5 ? 500 : 200,
                                  items: empList,
                                  label: "Employee",
                                  hint: "Select Employee",
                                  onChanged: (String? newValue) async {
                                    setState(() {
                                      empValue = newValue!;
                                      isLoaded = false;
                                    });

                                    await _getpayrollmonthlist();
                                  },
                                  selectedItem: empValue))
                          : Row(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('F.Y',
                                  style: ThemeText.pageHeaderBlack),
                              const SizedBox(width: 40),
                              DropdownButton<String>(
                                dropdownColor: const Color(0Xffeeeeee),
                                hint: const Text("Year"),
                                value: yearListValue,
                                elevation: 20,
                                style: ThemeText.text,
                                underline: Container(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    yearListValue = newValue!;
                                    salaryList.clear();
                                    isLoaded = false;
                                  });

                                  clicked = false;

                                  issalloaded = false;
                                  issalclicked = false;

                                  salaryList.clear();

                                  await _getpayrollmonthlist();
                                },
                                items: yearList,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SalaryConfig(
                                                  empvalue:
                                                      "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}"
                                                  // getuseridfname(empValue)
                                                  //     .toString()
                                                  ,
                                                )),
                                      );
                                    },
                                    child: const Text(
                                      "Salary Configuration",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ]),
                      ),
                      salaryList.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Table(
                                  columnWidths: const <int, TableColumnWidth>{},
                                  children: createTable()),
                            )
                          : const Center(
                              heightFactor: 10,
                              child: Text("No Record Found",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    letterSpacing: 3,
                                  ))),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              )),
      );
    });
  }

  List<TableRow> createTable() {
    List<TableRow> rows = [];
    rows.add(
      const TableRow(
        decoration: BoxDecoration(
          color: Color(0xfffaebd7),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 3, top: 8.0, bottom: 8.0),
            child: Text(
              "Month",
              textAlign: TextAlign.start,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              "Earnings",
              textAlign: TextAlign.end,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              "Deduction",
              textAlign: TextAlign.end,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 3),
            child: Text(
              "Net Amount",
              textAlign: TextAlign.end,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
        ],
      ),
    );

    for (int i = 0; i < salaryList.length; i++) {
      rows.add(TableRow(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              mainMonthList
                  .where((element) =>
                      element.monthid == "${salaryList[i].monthid}")
                  .toList()[0]
                  .year!
              //"${getmonth(salaryList[i].monthid)}"
              ,
              textAlign: TextAlign.start,
              style: ThemeText.text,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "${salaryList[i].totalearning}",
              textAlign: TextAlign.end,
              style: ThemeText.text,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "${salaryList[i].totaldeduction}",
              textAlign: TextAlign.end,
              style: ThemeText.text,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "${salaryList[i].netamount}",
              textAlign: TextAlign.end,
              style: ThemeText.text,
            ),
          ),
        ],
      ));

      rows.add(
        TableRow(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          children: <Widget>[
            const Text(""),
            const Text(""),
            const Text(""),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.file_download),
                    color: Colors.purple,
                    iconSize: 20.0,
                    onPressed: () {
                      showAlertDialog(context, salaryList[i]);
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.add_box),
                    color: Colors.purple,
                    iconSize: 20.0,
                    onPressed: () {
                      setState(() {
                        issalclicked = true;
                      });
                      _salarBreakup(
                          "${salaryList[i].monthid}",
                          mainEmployeeList
                              .where((element) =>
                                  element.empid == salaryList[i].id)
                              .toList()[0]
                              .userid
                          // getuserid(salaryList[i].id)
                          );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    return rows;
  }

  onSearchTextChanged(String text) async {
    searchList.clear();

    for (var detail in salaryList) {
      if (detail.empname!.toLowerCase().contains(text)) searchList.add(detail);
    }
    if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
      mainSalaryDetailsList = searchList;
    } else {
      mainSalaryDetailsList = salaryList;
    }
    setState(() {});
  }

  Widget buildMonthListAdmin(MonthModel data, int index) {
    return Expanded(
      child: ListView.builder(
        itemCount: mainMonthList.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 100,
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                      ),
                      child: Column(children: [
                        Text(mainMonthList[index].year!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              letterSpacing: 3,
                            )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  showAlertDialog(BuildContext context, MonthListModel modellist) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Download"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        _downloadPayslip(modellist.empname!, modellist.monthid!, modellist.id!);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Alert"),
      content: const Text("Are you sure want to Download?"),
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

  Future _downloadPayslip(String name, int monthid, int empId) async {
    await _requestPermission(Permission.storage);
    var dateTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    var filename = "${name.replaceAll("/", "_")}_payslip_$dateTime";

    File saveFile = File("/storage/emulated/0/Download/$filename.pdf");

    String query =
        '${globals.applictionRootUrl}API/PrintPayslips?DBName=${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() :
            // getuseridfname(empValue).toString()
            "${mainEmployeeList.where((element) => element.empname == empValue).toList()[0].userid}"}&Monthid=$monthid&Empid=$empId';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      try {
        var jobject = jsonDecode(response.body.toString());
        var data = jobject;

        saveFile.writeAsBytes(data['bytes'].cast<int>());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('File Downloaded Successfully!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFile.open(saveFile.path);
            },
          ),
        ));
      } catch (e) {}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Try Again Later'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}

class MonthListModel {
  const MonthListModel({
    this.id,
    this.monthid,
    this.empname,
    this.totalearning,
    this.totaldeduction,
    this.netamount,
  });

  final int? id;
  final int? monthid;
  final String? empname;
  final double? totalearning;
  final double? totaldeduction;
  final double? netamount;

  factory MonthListModel.fromJson(Map<String, dynamic> json) {
    return MonthListModel(
      id: json['EmployeeId'] ?? 0,
      monthid: json['MonthId'] ?? 0,
      empname: json['EmployeeName'] ?? "",
      totalearning: json['TotalEar'] == null ? "" : json['TotalEar'] + 0.0,
      totaldeduction: json['TotalDed'] == null ? "" : json['TotalDed'] + 0.0,
      netamount: json['GrossAmount'] == null ? "" : json['GrossAmount'] + 0.0,
    );
  }
}

class MonthModel {
  MonthModel({
    this.year,
    this.monthid,
  });

  final String? monthid;
  final String? year;

  factory MonthModel.fromJson(Map<String, dynamic> json) {
    return MonthModel(
      year: json['Text'] ?? "",
      monthid: json['Value'] ?? "",
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
    );
  }
}
