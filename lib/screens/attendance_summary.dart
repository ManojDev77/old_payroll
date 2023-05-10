import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/style.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'locate_user.dart';

class AttendanceSummary extends StatefulWidget {
  const AttendanceSummary({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _AttendanceSummaryState createState() => _AttendanceSummaryState();
}

class _AttendanceSummaryState extends State<AttendanceSummary>
    with TickerProviderStateMixin {
  List<LocationModel> _selecteddatetimeList = [];
  TextEditingController searchcontroller = TextEditingController();
  List<LocationModel> searchList = [];
  List<LocationModel> datetimelist = [];
  double? locateuseradminLat;
  double? locateuseradminLong;
  double? locateuseremp;
  String empValue = "";
  List<DropdownMenuItem<String>> empList = [];
  var mainEmployeeList = [];
  List<dynamic> empitem = [];
  bool isLoaded = false;
  @override
  void initState() {
    _getEmployeeData();
    initializeDateFormatting();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getcheckInandOutData(empValue) async {
    isLoaded = false;
    String formattedDate = "";
    String formattedTime;
    setState(() {});

    if (getdate() == "Select Date") {
      formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      formattedTime = DateFormat('hh:mm:ss').format(DateTime.now());
    } else {
      formattedDate = getdate().split('-').reversed.join("-");
      formattedTime = DateFormat('hh:mm:ss').format(DateTime.now());
    }

    // String userid = "";

    // if (globals.isEmployee) {
    //   setState(() {
    //     userid = globals.userId.toString();
    //   });
    // } else {
    //   if (empValue == "") {
    //     userid = globals.userId.toString();
    //   } else {
    //     setState(() {
    //       userid = empValue;
    //     });
    //   }
    // }

    String query =
        '${'${globals.applictionRootUrl}${empValue == "-1" ? 'API/CheckInOUTHistory?DBName=' : 'API/CheckInOUTHistoryUpdated?DBName='}${globals.databaseName}&UserId=' + (empValue == "-1" ? globals.userId.toString() : empValue)}&Date=$formattedDate&Time=$formattedTime';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    _selecteddatetimeList.clear();
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;

      var mainList = list.map((e) => LocationModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          _selecteddatetimeList = List<LocationModel>.from(mainList);
          datetimelist = _selecteddatetimeList;
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

//CheckInOUTHistoryWithPhoto(string DBName, int UserId, int Id)
  Future<void> getpicks(int id) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Loading....'),
      duration: Duration(seconds: 1),
    ));
    String query =
        '${globals.applictionRootUrl}API/CheckInOUTHistoryWithPhoto?DBName=${globals.databaseName}&UserId=${globals.isEmployee ? globals.userId.toString() : empValue}&Id=$id';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var filename = list['Item1'];

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
                imageBytes: list['imgdata'].cast<int>(),
                imageName: filename,
              )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No Image To Display"),
          duration: Duration(seconds: 1)));
    }
  }

  Future _getEmployeeData() async {
    setState(() {
      mainEmployeeList.clear();
      empList.clear();
      empList.add(const DropdownMenuItem(
        value: "",
        child: Text("Select"),
      ));
    });

    mainEmployeeList = await GetEmployee().getEmployeeData();
    empList.add(const DropdownMenuItem(value: "-1", child: Text("All")));
    for (var item in mainEmployeeList) {
      empList.add(
          DropdownMenuItem(value: "${item.userid}", child: Text(item.empname)));
    }

    try {
      empValue =
          "${mainEmployeeList.where((element) => element.userid == globals.userId).toList()[0].userid}";
    } catch (e) {
      empValue = empList[1].value!;
    }

    getcheckInandOutData(empValue);
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    for (var detail in datetimelist) {
      if (detail.empname!.toLowerCase().contains(text)) searchList.add(detail);
    }
    if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
      _selecteddatetimeList = searchList;
    } else {
      _selecteddatetimeList = datetimelist;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                color: Colors.white10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                datepicker(context);
                              },
                              child: Text("${getdate()}"),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            !globals.isEmployee
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text('Employee',
                                          style: ThemeText.pageHeaderBlack),
                                      const SizedBox(width: 10),
                                      DropdownButton<String>(
                                        hint: const Text("Employee"),
                                        value: empValue,
                                        // isDense: true,
                                        // isExpanded: true,
                                        elevation: 10,
                                        style: ThemeText.text,
                                        underline: Container(
                                          height: 1,
                                          color: Colors.grey,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            empValue = newValue!;
                                          });
                                          getcheckInandOutData(empValue);
                                        },
                                        items: empList,
                                      ),
                                    ],
                                  )
                                : Row(),
                          ]),
                    ),
                    const SizedBox(height: 8.0),
                    const SizedBox(height: 8.0),
                    Expanded(child: _buildEventList()),
                  ],
                ),
              ),
            ),
    );
  }

  DateTime? date;
  getdate() {
    if (date == null) {
      return '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
    }
    return '${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}';
  }

  Future datepicker(BuildContext context) async {
    final initialdate = date ?? DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialdate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (newDate == null) return;

    setState(() {
      date = newDate;
    });
    getcheckInandOutData(empValue);
  }

  Widget _buildEventList() {
    return _selecteddatetimeList.isNotEmpty
        ? ListView(
            children: _selecteddatetimeList.reversed
                .map((event) => GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => LocateUserWidget(
                              latitude: event.latitude!,
                              longitude: event.longitude!)));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 7.0),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Table(
                              // border: TableBorder.all(),
                              columnWidths: const <int, TableColumnWidth>{
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(64),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                TableRow(children: <Widget>[
                                  const Text("Employee",
                                      style: ThemeText.pageHeaderBlack),
                                  Text(": ${event.empname}",
                                      style: ThemeText.pageHeaderBlack),
                                ]),
                                TableRow(children: <Widget>[
                                  const Text("Status", style: ThemeText.text),
                                  Text(": ${event.loginstatus}",
                                      style: ThemeText.text),
                                ]),
                                TableRow(children: <Widget>[
                                  const Text("Date", style: ThemeText.text),
                                  Text(
                                      ": ${event.loginoutdate} ${event.logininouttime}",
                                      style: ThemeText.text),
                                ]),
                                TableRow(children: <Widget>[
                                  const Text("Remark", style: ThemeText.text),
                                  Text(": ${event.remark}",
                                      style: ThemeText.text),
                                ]),
                                if (globals.loginphotocap)
                                  TableRow(children: <Widget>[
                                    const Text("Captured Image  ",
                                        style: ThemeText.text),
                                    Row(
                                      children: [
                                        const Text(":"),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: GestureDetector(
                                              onTap: () {
                                                getpicks(event.id!);
                                              },
                                              child: const Icon(Icons.photo)),
                                        ),
                                      ],
                                    ),
                                  ]),
                                if (((globals.isBiometricEnabled ||
                                        globals.isLeaveBiometricEnabled) ||
                                    (globals.isLoginInWebAllowed ||
                                        globals.leaveisLoginInWebAllowed)))
                                  TableRow(children: <Widget>[
                                    const Text("Logged From",
                                        style: ThemeText.text),
                                    Text(
                                        ": ${event.isFromBiometric! ? "Biometric" : (event.isloggedfromweb! ? "Laptop" : "Mobile")}",
                                        style: ThemeText.text)
                                  ]),
                              ]),
                        ))))
                .toList(),
          )
        : Center(
            heightFactor: 10,
            child: Text(
              "No records found".toUpperCase(),
              style:
                  const TextStyle(fontSize: 30, fontFamily: "poppins-medium"),
            ),
          );
  }
}

class LocationModel {
  const LocationModel(
      {this.empname,
      this.loginstatus,
      this.loginoutdate,
      this.logininouttime,
      this.latitude,
      this.longitude,
      this.remark,
      this.id,
      this.isloggedfromweb,
      this.isFromBiometric});
  final String? empname;
  final String? loginstatus;
  final String? loginoutdate;
  final String? logininouttime;
  final double? latitude;
  final double? longitude;
  final String? remark;
  final int? id;
  final bool? isloggedfromweb;
  final bool? isFromBiometric;
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
        empname: json['EmployeeName'] ?? "",
        loginstatus: json['Loginstatus'] ?? "",
        loginoutdate: json['LoginoutDate'] ?? "",
        logininouttime: json['LoginoutTime'] ?? "",
        latitude: json['lat'] == null ? 0 : json['lat'] + 0.0,
        longitude: json['longitude'] == null ? 0 : json['longitude'] + 0.0,
        remark: json['remark'] ?? "",
        isloggedfromweb: json['IsLoginFromLaptop'] ?? false,
        isFromBiometric: json['IsFromBiometric'] ?? false,
        id: json["Id"] ?? 0);
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

class DisplayPictureScreen extends StatefulWidget {
  final List<int> imageBytes;
  final String imageName;
  const DisplayPictureScreen(
      {Key? key, required this.imageBytes, required this.imageName})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.imageName)),
      body: Stack(children: [
        Image.memory(
          Uint8List.fromList(widget.imageBytes),
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.35,
          bottom: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 35,
                )),
            IconButton(
                onPressed: () async {
                  await _requestPermission(Permission.storage);
                  File saveFile =
                      File("/storage/emulated/0/Download/${widget.imageName}");
                  saveFile.writeAsBytes(widget.imageBytes);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('${widget.imageName} Downloaded Successfully!'),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        OpenFile.open(saveFile.path);
                      },
                    ),
                  ));
                },
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 35,
                )),
            const SizedBox(
              width: 20,
            ),
          ]),
        ),
      ]),
    );
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
