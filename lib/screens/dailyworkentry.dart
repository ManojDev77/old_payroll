import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class DailyWorkEntry extends StatefulWidget {
  const DailyWorkEntry({Key? key}) : super(key: key);

  @override
  _DailyWorkEntryState createState() => _DailyWorkEntryState();
}

class _DailyWorkEntryState extends State<DailyWorkEntry> {
  List<ReportModel> mainLeaveList = [];
  List<ReportModel> allmainLeaveList = [];
  List<ReportModelDelete> mainTaskDeleteList = [];

  String? valueitems;
  bool rememberMe = false;
  @override
  initState() {
    _wrkhrscontroller.clear();
    _remarkcontroller.clear();
    dailyreportrequest();
    dailyreportrequestdelete();
    super.initState();
  }

  final TextEditingController _wrkhrscontroller = TextEditingController();
  final TextEditingController _remarkcontroller = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  List<String> creationitems = [];
  DateTime? date;
  getdate() {
    if (date == null) {
      return '${DateTime.now().day.toString().padLeft(2, "0")}/${DateTime.now().month.toString().padLeft(2, "0")}/${DateTime.now().year}';
    }
    return '${date!.day.toString().padLeft(2, "0")}/${date!.month.toString().padLeft(2, "0")}/${date!.year}';
  }

  Future dailyreportrequest() async {
    setState(() {
      valueitems = "Select";
    });

    String query =
        '${globals.applictionRootUrl}API/DailyReportSearch?DBName=${globals.databaseName}&UserId=${globals.userId}&Task=&Date=';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["DailyReportData"]
          [rememberMe ? "PreviousIDList" : "TaskIDList"];
      var mainList = list.map((e) => ReportModel.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          allmainLeaveList = mainLeaveList = List<ReportModel>.from(mainList);
          if (globals.taskdate != "" && globals.taskidnew != "") {
            creationitems.add("Select");
            valueitems = globals.taskidnew;
            _wrkhrscontroller.text = "${globals.taskhours}";
            _remarkcontroller.text = globals.taskremark;
            creationitems.add(globals.taskidnew);

            date =
                DateTime.parse(globals.taskdate.split("/").reversed.join("-"));
          } else {
            creationitems.add("Select");
            for (int i = 0; i < mainLeaveList.length; i++) {
              if (!creationitems.contains(mainLeaveList[i].task)) {
                creationitems.add(mainLeaveList[i].task!);
              }
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text(
      //     "Daily Work Entry",
      //     style: TextStyle(color: Colors.white, fontSize: 20),
      //   ),
      //   leading: new IconButton(
      //     icon: new Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Row(
                  children: [
                    Container(
                        child: const Text(
                      "Previous Task",
                      style: ThemeText.pageHeaderBlack,
                    )),
                    const SizedBox(
                      width: 40.0,
                    ),
                    Container(
                      child: Checkbox(
                          value: rememberMe, onChanged: _onRememberMeChanged),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Task", style: ThemeText.pageHeaderBlack),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButton(
                      isExpanded: true,
                      elevation: 20,
                      style: ThemeText.text,
                      // underline: Container(height: 1, color: Colors.deepPurple),
                      items: creationitems.map(buildmenuitems).toList(),
                      onChanged: (value) {
                        setState(() {
                          valueitems = value;
                        });
                      },
                      value: valueitems!.isNotEmpty ? valueitems : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: const Text("Worked Hrs",
                          style: ThemeText.pageHeaderBlack),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLines: null,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Required';
                          } else {
                            return null;
                          }
                        },
                        controller: _wrkhrscontroller,
                        // decoration: InputDecoration(
                        //   hintText: "Enter Your Worked Hours Here",
                        //   border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(10.0),
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Row(
                  children: [
                    const Text("Date", style: ThemeText.pageHeaderBlack),
                    const SizedBox(
                      width: 95,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        datepicker(context);
                      },
                      child: Text(
                        getdate(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: const Text("Remarks",
                            style: ThemeText.pageHeaderBlack),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Required';
                            } else {
                              return null;
                            }
                          },
                          controller: _remarkcontroller,
                          // decoration: InputDecoration(
                          //   hintText: "Enter Your Remarks Here",
                          //   border: OutlineInputBorder(
                          //     borderRadius: BorderRadius.circular(10.0),
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 20.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        if (formkey.currentState!.validate() &&
                            valueitems != "Select" &&
                            getdate() != "Select Date") {
                          _savereportdata(
                              gettaskid(valueitems!), getid(valueitems!));
                        } else {
                          if (valueitems == "Select") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please Select Task")));
                          } else if (getdate() == "Select Date") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please Select Date")));
                          }
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget adminRow(ReportModelDelete report, int index) {
    // final String sessionnameis = sessionname(leave);

    // return Container(
    //   height: 100,
    //   margin: const EdgeInsets.only(left: 45.0, right: 20.0,bottom: 10,top:10),
    //   decoration: new BoxDecoration(
    //     color: Colors.blue,
    //     shape: BoxShape.rectangle,
    //     borderRadius: new BorderRadius.circular(8.0),
    //     boxShadow: <BoxShadow>[
    //       new BoxShadow(
    //           color: Colors.black,
    //           blurRadius: 10.0,
    //           offset: new Offset(0.0, 2.0))
    //     ],
    //   ),
    //   child: new Container(
    //     margin: const EdgeInsets.only(top: 8.0, left: 72.0),
    //     constraints: new BoxConstraints.expand(),
    //     child: new Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.max,
    //       children: <Widget>[
    //         new Text(report.task+"\n"+report.datereport+"\n"+report.wrkhr.toString()+"\n"+report.remark,
    //             style: TextStyle(
    //               color: Color(0xFFFFFFFF),
    //               fontFamily: 'poppins-medium',
    //               fontWeight: FontWeight.w600,
    //               fontSize: 18.0,
    //             ),
    //             ),

    //              RaisedButton(
    //                       color: Colors.blue[900],
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: new BorderRadius.circular(10.0),
    //                       ),
    //                       onPressed: () async {
    //                         // _showMyDialog(mainTaskDeleteList[index].taskid);
    //                         deletereport(mainTaskDeleteList[index].id);
    //                       },
    //                       textColor: Color(0x66FFFFFF),
    //                       child: Padding(
    //                         padding: const EdgeInsets.symmetric(vertical: 3),
    //                         child: Column(children: <Widget>[
    //                           Icon(Icons.delete, size: 15.0,
    //                           color: Colors.white),
    //                           Text(
    //                             'Delete',
    //                             style: TextStyle(
    //                                 color: Colors.white,
    //                                 fontFamily: 'poppins-medium',
    //                                 fontWeight: FontWeight.w600,
    //                                 fontSize: 10.0),
    //                           ),
    //                         ]),
    //                       ),
    //                     )
    //       ],
    //     ),
    //   ),
    //   );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "${index + 1}.",
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      report.task!,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      report.datereport!,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      report.wrkhr.toString(),
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              //  Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[
              //          Text(report.remark,
              //   style: TextStyle(
              //       color: Colors.blue,
              //       fontSize: 18.0,
              //       fontWeight: FontWeight.bold),
              //          ),
              //     ],
              //   ),
              // ),
            ],
          ),
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
      print("Deleted");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Deleted Successfully"),
        duration: Duration(seconds: 2),
      ));
      await Future.delayed(const Duration(seconds: 3), () {
        dailyreportrequestdelete();
      });

      print(iddelete);
    }
  }

  Future dailyreportrequestdelete() async {
    _wrkhrscontroller.text = "";
    _remarkcontroller.text = "";
    if (globals.tabid != 0) {
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
        var mainList = list.map((e) => ReportModelDelete.fromJson(e)).toList();
        if (mounted) {
          _wrkhrscontroller.text = "";
          _remarkcontroller.text = "";
          setState(() {
            mainTaskDeleteList = List<ReportModelDelete>.from(mainList);
            for (int i = 0; i < mainTaskDeleteList.length; i++) {
              if (mainTaskDeleteList[i].id == globals.tabid) {
                _wrkhrscontroller.text = mainTaskDeleteList[i].wrkhr.toString();
                _remarkcontroller.text = mainTaskDeleteList[i].remark!;
                date = DateFormat('dd/MM/yyyy')
                    .parse(mainTaskDeleteList[i].datereport!);
              }
            }
          });
        }
      }
    }
  }

  gettaskid(String valitem) {
    for (int i = 0; i < mainLeaveList.length; i++) {
      if (mainLeaveList[i].task == valitem) {
        return mainLeaveList[i].taskid;
      }
    }
  }

  getid(String valitem) {
    for (int i = 0; i < mainLeaveList.length; i++) {
      if (mainLeaveList[i].task == valitem) {
        return mainLeaveList[i].id;
      }
    }
  }

  Future _savereportdata(String itemval, int id) async {
    String query = globals.applictionRootUrl +
        'API/DailyReportSave?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&DailaryReportId=' +
        "${globals.tabid}" +
        '&TaskId=' +
        itemval +
        '&WorkedHours=' +
        _wrkhrscontroller.text +
        '&Remarks=' +
        _remarkcontroller.text +
        '&WorkedDate=' +
        getdate().toString().split('/').reversed.join("/");
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      globals.taskidnew = "";
      globals.taskdate = "";
      globals.taskhours = 0.0;
      globals.taskremark = "";
      globals.tabid = 0;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daily Work Saved Successfully")));
      setState(() {});

      _wrkhrscontroller.clear();
      _remarkcontroller.clear();
    }
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
  }

  DropdownMenuItem<String> buildmenuitems(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  void _onRememberMeChanged(bool? newValue) => setState(() {
        rememberMe = newValue!;

        if (rememberMe) {
          creationitems.clear();
          dailyreportrequest();
        } else {
          creationitems.clear();
          dailyreportrequest();
        }
      });
}

class ReportModel {
  ReportModel({this.task, this.taskid, this.id});
  String? task;
  final String? taskid;
  int? id;
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
        task: json['Text'] ?? "",
        id: json['Id'] ?? 0,
        taskid: json['Value'] ?? "0");
  }
}

class ReportModelDelete {
  ReportModelDelete(
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
  factory ReportModelDelete.fromJson(Map<String, dynamic> json) {
    return ReportModelDelete(
      task: json['TaskIDName'] ?? "",
      id: json['Id'] ?? 0,
      datereport: json['WDate'] ?? "",
      wrkhr: json['WorkedHours'] ?? 0.0,
      remark: json['Remarks'] ?? "",
      previuos: json['PreviousTask'] ?? false,
    );
  }
}
