import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'locate_user.dart';

class EmployeeLog extends StatefulWidget {
  final int? mainId;
  final String? empName;
  final String? title;
  const EmployeeLog(
      {Key? key, required this.mainId, this.title, required this.empName})
      : super(key: key);

  @override
  EmployeeListState createState() => EmployeeListState();
}

class EmployeeListState extends State<EmployeeLog>
    with TickerProviderStateMixin {
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();

    _getEmployeeLogData();
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController searchcontroller = TextEditingController();

  List<LocationModel> _selecteddatetimeList = [];

  String empValue = "";

  Future _getEmployeeLogData() async {
    String date;
    if (getdate() == "Select Date") {
      var currentDate = DateTime.now();
      date = DateFormat('yyyy-MM-dd').format(currentDate);
    } else {
      date = getdate().split('-').reversed.join("-");
    }

    String query =
        '${globals.applictionRootUrl}API/GPSLogDetailsHistoryUpdated?DBName=${globals.databaseName}&UserId=${widget.mainId}&Date=$date';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => LocationModel.fromJson(e)).toList();

      setState(() {
        _selecteddatetimeList = List<LocationModel>.from(mainList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Log Info",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!globals.isEmployee)
                Row(
                    mainAxisAlignment: widget.empName != ""
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Text(
                        "Employee : ${widget.empName!}",
                        style: ThemeText.pageHeaderBlack,
                      ),
                    ]),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  const Text(
                    "Select",
                    style: ThemeText.pageHeaderBlack,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      datepicker(context);
                    },
                    child: Text("${getdate()}"),
                  ),
                ],
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
    _getEmployeeLogData();
  }

  Widget _buildEventList() {
    return _selecteddatetimeList.isNotEmpty
        ? ListView(
            children: _selecteddatetimeList
                .map((event) => GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => LocateUserWidget(
                              latitude: event.lat!, longitude: event.long!)));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.blue),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Latitude",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Longitude",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Date",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(": " "${event.lat}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    ": "
                                    "${event.long}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(": ${event.logdate} ${event.logtime}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )))
                .toList(),
          )
        : Center(
            child: Text(
              "No Records Found".toUpperCase(),
              style:
                  const TextStyle(fontSize: 25, fontFamily: "poppins-medium"),
            ),
          );
  }
}

class LocationModel {
  const LocationModel({
    this.empname,
    this.logtime,
    this.logdate,
    this.lat,
    this.long,
  });
  final String? empname;
  final String? logtime;
  final String? logdate;
  final double? lat;
  final double? long;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      empname: json['EmployeeName'] ?? "",
      logtime: json['LoginoutTime'] ?? "",
      logdate: json['LoginoutDate'] ?? "",
      lat: json['lat'] ?? "",
      long: json['longitude'] ?? "",
    );
  }
}
