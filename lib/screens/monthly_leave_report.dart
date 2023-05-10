import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

bool permissionGranted = false;
ProgressDialog? pr;
List<MonthModel> mainMonthList = [];

class Leavedownload extends StatefulWidget {
  final String empvalue;
  final String empName;

  const Leavedownload({Key? key, required this.empvalue, required this.empName})
      : super(key: key);
  @override
  LeavedownloadState createState() => LeavedownloadState();
}

class LeavedownloadState extends State<Leavedownload> {
  Directory? directory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic monthitem;
  List<EmployeeId> mainEmployeeList = [];
  bool isLoaded = false;

  @override
  void initState() {
    _getMonthYearData();
    _getEmployeeData();

    super.initState();
  }

  String monthValue = "";

  List<DropdownMenuItem<String>> monthList = [];
  Future _getMonthYearData() async {
    monthList.clear();
    setState(() {
      monthList.add(const DropdownMenuItem(
        value: "",
        child: Text("Select"),
      ));
    });
    String query =
        '${globals.applictionRootUrl}API/GetLeaveYearList?DBName=${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : widget.empvalue}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      if (response.body != "[]") {
        var jobject = jsonDecode(response.body.toString());

        monthitem = jobject;
        var monthms = jobject;

        setState(() {
          for (var item in monthms) {
            monthList.add(DropdownMenuItem(
                value: item["Value"].toString(),
                child: Text(item["Text"].toString())));
          }

          if (monthList.isNotEmpty) {
            if (monthList.length > 2) {
              monthValue = monthList[1].value!;
              _getleavemonthlist();
            }
            monthValue = monthList[1].value!;
            _getleavemonthlist();
          }
        });
      } else {
        setState(() {
          isLoaded = true;
        });
      }
    }
  }

  _getleavemonthlist() async {
    setState(() {
      isLoaded = false;
    });
    String query =
        '${globals.applictionRootUrl}API/GetLeaveYearWiseMonthList?DBName=${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : widget.empvalue}&YearId=$monthValue';
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
        setState(() {
          mainMonthList = List<MonthModel>.from(mainList);
        });
      }
    }
    setState(() {
      isLoaded = true;
    });
  }

  List<dynamic> empitem = [];
  String empValue = "";
  String empName = "";
  String empCode = "";
  List<DropdownMenuItem<String>> empList = [];
  Future _getEmployeeData() async {
    String query =
        '${globals.applictionRootUrl}API/TotalEmployeeList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var empitems = jobject;
      var mainList = empitems.map((e) => EmployeeId.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainEmployeeList = List<EmployeeId>.from(mainList);
        });
      }
    }
  }

  getuserid(int userid) {
    int? iduser;
    for (int i = 0; i < mainEmployeeList.length; i++) {
      if (mainEmployeeList[i].userid == int.parse(widget.empvalue)) {
        iduser = mainEmployeeList[i].empid!;
        print(iduser);
      }
    }
    return iduser;
  }

  Future<Future<File>> writeToFile(ByteData data, String path) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _downloadLeaveReport(String empname, String mnthname, int empid) {
    showAlertDialog(context, empname, mnthname, empid);
  }

  String monthname = "";

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

  _downloadLeaveReport1(String namemployee, String monname, int empid) async {
    Directory appDocDirectory;
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        appDocDirectory = (await getExternalStorageDirectory())!;
        print(appDocDirectory);
      } else {
        return false;
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        appDocDirectory = await getTemporaryDirectory();
      } else {
        return false;
      }
    }
    print(appDocDirectory);
    var dateTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    var filename = "${widget.empName.replaceAll("/", "_")}_LM_$dateTime";

    File saveFile = File("/storage/emulated/0/Download/$filename.pdf");

    String query = globals.applictionRootUrl +
        'API/MonthlyLeaveReport?DBName=' +
        globals.databaseName +
        '&UserId=' +
        (globals.isEmployee ? globals.userId.toString() : widget.empvalue) +
        '&tId=' +
        "$empid" +
        '&Monthyear=' +
        monname;

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  showAlertDialog(
      BuildContext context, String nameemp, String mntname, int empid) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "Download",
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        _downloadLeaveReport1(nameemp, mntname, empid);
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

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Download Leave Report'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Employee : ${widget.empName}",
                            style: ThemeText.pageHeaderBlack),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                globals.yearType == 0 ? 'Calendar Year' : 'F.Y',
                                style: ThemeText.pageHeaderBlack),
                            const SizedBox(
                              width: 50,
                            ),
                            DropdownButton<String>(
                              underline: DropdownButtonHideUnderline(
                                  child: Container()),
                              value: monthValue,
                              style: ThemeText.text,
                              onChanged: (String? newValue) {
                                setState(() {
                                  monthValue = newValue!;
                                  monthname = monthitem
                                      .where((element) =>
                                          element['Text'].toString() ==
                                          monthValue)
                                      .first['Value'];
                                  print(monthname);
                                });
                                _getleavemonthlist();
                              },
                              items: monthList,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        mainMonthList.isNotEmpty
                            ? Table(
                                border: TableBorder.all(),
                                columnWidths: const <int, TableColumnWidth>{
                                  1: FlexColumnWidth(),
                                  2: FixedColumnWidth(64),
                                },
                                children: createLeaveTable())
                            : const Center(
                                heightFactor: 15,
                                child: Text(
                                  "No Records Found",
                                  style: TextStyle(fontSize: 30),
                                )),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  List<TableRow> createLeaveTable() {
    List<TableRow> rows = [];
    rows.add(const TableRow(
        decoration: BoxDecoration(
          color: Color(0xfffaebd7),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Month/Year",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Action",
              style: ThemeText.pageHeaderBlack,
              textAlign: TextAlign.center,
            ),
          ),
        ]));
    for (int i = 0; i < mainMonthList.length; i++) {
      rows.add(TableRow(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            mainMonthList[i].year!,
            textAlign: TextAlign.left,
            style: ThemeText.text,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
              onTap: () {
                _downloadLeaveReport(
                    globals.userId.toString(),
                    mainMonthList[i].year.toString(),
                    getuserid(globals.userId));
              },
              child: const Icon(Icons.file_download)),
        ),
      ]));
    }
    return rows;
  }
}

void showDialogTemplate(BuildContext context, String title, String subtitle,
    String gif, Color color, String buttonText) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 40,
        child: AlertDialog(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                gif,
                width: 175,
              ),
              Text(subtitle, style: const TextStyle(color: Colors.white60)),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class PayModel {
  const PayModel(
      {this.empid, this.monthid, this.empname, this.netamount, this.depmt});

  final int? empid;
  final int? monthid;
  final String? empname;
  final double? netamount;
  final String? depmt;
  factory PayModel.fromJson(Map<String, dynamic> json) {
    return PayModel(
      empid: json['empid'] ?? 0,
      monthid: json['monthid'] ?? 0,
      empname: json['empname'] ?? "",
      netamount: json['netamount'] ?? 0,
      depmt: json['department'] ?? "",
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

class EmployeeId {
  EmployeeId({this.empid, this.userid});
  int? empid;
  int? userid;

  factory EmployeeId.fromJson(Map<String, dynamic> json) {
    return EmployeeId(
      empid: json['EmpID'] ?? 0,
      userid: json['UserID'] ?? 0,
    );
  }
}
