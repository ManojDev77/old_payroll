import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddEmp extends StatefulWidget {
  final int? id;
  final int? empsetid;
  const AddEmp({Key? key, @required this.id, @required this.empsetid})
      : super(key: key);
  @override
  AddEmpState createState() => AddEmpState();
}

class AddEmpState extends State<AddEmp> {
  ProgressDialog? pr;
  List<String> ids = [];
  List<String> names = [];
  List<Employee> _selectedemployee = [];

  List<MeetingModal> mainMeetingList = [];
  List<MeetingModal> mainaddedMeetingList = [];
  List<MultiSelectItem<Employee>> _items = [];
  static List<Employee> employyelist = [];
  bool isLoaded = false;
  final _multiSelectKey = GlobalKey<FormFieldState>();

  String meeting = "";
  @override
  void initState() {
    addemployeedetails();

    pr = ProgressDialog(context, isDismissible: false);
    pr!.style(
        message: 'Assigning Employee...',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Employee"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: !isLoaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Text("Meeting Details ",
                            style: ThemeText.pageHeaderBlack),
                        Text(
                          " : $meeting",
                          style: ThemeText.pageHeaderBlack,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (globals.userId == widget.empsetid)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Employee",
                              style: ThemeText.pageHeaderBlack),
                          const SizedBox(
                            height: 15,
                          ),
                          MultiSelectBottomSheetField<Employee>(
                            key: _multiSelectKey,
                            initialChildSize: 0.8,
                            maxChildSize: 0.8,
                            title: const Text("Employee List"),
                            buttonText: const Text("Select"),
                            items: _items,
                            searchable: true,
                            validator: (values) {
                              if (values == null || values.isEmpty) {
                                return "Required";
                              }
                              ids = values.map((e) => e.id!).toList();
                              names = values.map((e) => e.name!).toList();

                              return null;
                            },
                            onConfirm: (values) {
                              setState(() {
                                _selectedemployee = values;
                              });
                              _multiSelectKey.currentState?.validate();
                            },
                            chipDisplay: MultiSelectChipDisplay(
                              onTap: (item) {
                                setState(() {
                                  _selectedemployee.remove(item);
                                });
                                _multiSelectKey.currentState?.validate();
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (globals.userId == widget.empsetid)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                if (!_multiSelectKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Select Employee')));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Please Wait...'),
                                    duration: Duration(seconds: 1),
                                  ));
                                  assignemployeetomeeting(
                                      ids, widget.id!, names);
                                }
                              },
                              child: const Text("Assign Employee")),
                        ],
                      ),
                    if (globals.userId == widget.empsetid)
                      const SizedBox(
                        height: 30,
                      ),
                    if (mainaddedMeetingList.isNotEmpty)
                      const Text("Assigned Employee List",
                          style: ThemeText.pageHeaderBlack),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: mainaddedMeetingList.isNotEmpty
                            ? SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                  ),
                                  columnWidths: <int, TableColumnWidth>{
                                    if (globals.userId == widget.empsetid)
                                      0: const IntrinsicColumnWidth(),
                                    1: const FlexColumnWidth(),
                                    // 2: const FixedColumnWidth(80),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: createTable(),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "No Employees Assigned",
                                  style: TextStyle(fontSize: 25),
                                ),
                              )),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> addemployeedetails() async {
    isLoaded = false;
    if (mounted) {
      setState(() {
        mainMeetingList.clear();
        mainaddedMeetingList.clear();
      });
    }

    String query =
        '${globals.applictionRootUrl}API/AddEmployeeToMeeting?DBName=${globals.databaseName}&UserId=${globals.userId}&MeetingId=${widget.id}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      meeting = jobject["MeetingName"];

      var listofemp = jobject["AddEmployeeMeetingDetailsData"]["EmpIDList"];
      var addedemplist = jobject["AddEmployeeMeetingDetailsList"];

      var mainListmeeting =
          listofemp.map((e) => MeetingModal.fromJson(e)).toList();
      var mainListaddmeeting =
          addedemplist.map((e) => MeetingModal.fromJson(e)).toList();
      mainaddedMeetingList = List<MeetingModal>.from(mainListaddmeeting);
      mainMeetingList = List<MeetingModal>.from(mainListmeeting);
      for (int i = 0; i < mainaddedMeetingList.length; i++) {
        mainMeetingList.removeWhere((element) =>
            (element.empname == mainaddedMeetingList[i].addempname));
      }
      employyelist.clear();
      for (int i = 0; i < mainMeetingList.length; i++) {
        employyelist.addAll([
          Employee(
              id: mainMeetingList[i].empid, name: mainMeetingList[i].empname)
        ]);
      }
      _items.clear();
      _items = employyelist
          .map((emp) => MultiSelectItem<Employee>(emp, emp.name!))
          .toList();
    }

    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  List<TableRow> createTable() {
    List<TableRow> rows = [];

    rows.add(TableRow(
      decoration: const BoxDecoration(
        color: Color(0xfffaebd7),
      ),
      children: <Widget>[
        if (globals.userId == widget.empsetid)
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Text('Action', style: ThemeText.pageHeaderBlack),
            ),
          ),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Text('Employee Name', style: ThemeText.pageHeaderBlack),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Text('Status', style: ThemeText.pageHeaderBlack),
          ),
        ),
      ],
    ));

    for (int i = 0; i < mainaddedMeetingList.length; ++i) {
      rows.add(TableRow(children: [
        if (globals.userId == widget.empsetid)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showAlertDlgDeleteEmp(context, mainaddedMeetingList[i].id!);
            },
          ),
        // if (globals.userId != widget.empsetid)
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            mainaddedMeetingList[i].addempname!,
            style: ThemeText.text,
          ),
        ),
        // if (globals.userId != widget.empsetid)
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            mainaddedMeetingList[i].satusid == 1
                ? "Pending"
                : mainaddedMeetingList[i].satusid == 2
                    ? "Approved"
                    : "Rejected",
            style: ThemeText.text,
          ),
        ),
      ]));
    }

    return rows;
  }

  showAlertDlgDeleteEmp(BuildContext context, int id) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        deleteaddedemp(id);
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

  Future<void> deleteaddedemp(int idemp) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleting Employee...'),
      duration: Duration(seconds: 2),
    ));
    String query =
        '${globals.applictionRootUrl}API/DeleteAddEmployeeToMeeting?DBName=${globals.databaseName}&UserId=${globals.userId}&Id=$idemp';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      addemployeedetails();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Employee Deleted'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> assignemployeetomeeting(
      List<String> empmeetids, int meetingid, List<String> empnames) async {
    pr!.show();

    http.Response? response;
    for (int i = 0; i < empmeetids.length; i++) {
      String query =
          '${globals.applictionRootUrl}API/SaveEmployeeToMeeting?DBName=${globals.databaseName}&UserId=${globals.userId}&MeetingId=$meetingid&EmployeeId=${empmeetids[i]}';
      response = await http.post(
        Uri.parse(query),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
    }
    if (response!.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Employee Assigned'),
        duration: Duration(seconds: 1),
      ));
      pr!.hide();

      addemployeedetails();
    } else {
      pr!.hide();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}

class MeetingModal {
  const MeetingModal(
      {this.empname,
      this.empid,
      this.addempname,
      this.addedempid,
      this.id,
      this.satusid});
  final String? empid;
  final String? empname;
  final String? addempname;
  final int? addedempid;
  final int? id;
  final int? satusid;
  factory MeetingModal.fromJson(Map<String, dynamic> json) {
    return MeetingModal(
        empname: json['Text'] ?? "",
        empid: json['Value'] ?? "",
        addempname: json['EmpIDName'] ?? "",
        addedempid: json['EmpId'] ?? 0,
        satusid: json['Status'] ?? 0,
        id: json['Id'] ?? 0);
  }
}

class Employee {
  final String? id;
  final String? name;

  Employee({
    this.id,
    this.name,
  });
}
