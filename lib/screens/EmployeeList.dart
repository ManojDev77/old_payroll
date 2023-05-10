import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'EmployeeListLogDetails.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  EmployeeListState createState() => EmployeeListState();
}

class EmployeeListState extends State<EmployeeList>
    with TickerProviderStateMixin {
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();

    _getEmployeeData();
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController searchcontroller = TextEditingController();
  List<LacationModel> searchList = [];
  List<LacationModel> empList = [];

  List<LacationModel> _selecteddatetimeList = [];

  String empValue = "";

  Future _getEmployeeData() async {
    String query =
        '${globals.applictionRootUrl}API/GetLoggedEmployeeList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());

      var list = jobject;

      var mainList = list.map((e) => LacationModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          _selecteddatetimeList = List<LacationModel>.from(mainList);
          empList = _selecteddatetimeList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Employee List",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blue,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(height: 8.0),
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
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
                          searchcontroller.clear();
                          onSearchTextChanged('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildEventList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return _selecteddatetimeList.isNotEmpty
        ? ListView(
            children: _selecteddatetimeList
                .map((event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          event.empname!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: const Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EmployeeLog(
                                        mainId: event.userID!,
                                        empName: event.empname!,
                                      )));
                        },
                      ),
                    ))
                .toList(),
          )
        : const Center(
            heightFactor: 10,
            child: Text(
              "No Records Found",
              style: TextStyle(fontSize: 35, color: Colors.white),
            ));
  }

  onSearchTextChanged(String text) async {
    searchList.clear();

    for (var detail in empList) {
      if (detail.empname!.toLowerCase().contains(text)) searchList.add(detail);
    }
    if (text.isNotEmpty || searchcontroller.text.isNotEmpty) {
      _selecteddatetimeList = searchList;
    } else {
      _selecteddatetimeList = empList;
    }
    setState(() {});
  }
}

class LacationModel {
  const LacationModel({
    this.empname,
    this.userID,
  });
  final String? empname;
  final int? userID;

  factory LacationModel.fromJson(Map<String, dynamic> json) {
    return LacationModel(
      empname: json['EmpName'] ?? "",
      userID: json['UserID'] ?? "",
    );
  }
}
