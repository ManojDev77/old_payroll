import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../constants/style.dart';
import 'adminempmeetinglog.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as dateformat;

ProgressDialog? pr;
List<MeetingModal> mainMeetingList = [];
List<EmpListModel> mainMeetingListids = [];
TabController? _tabController;

class AdminempMeeting extends StatefulWidget {
  final int? meetid;
  final int? tabController;

  const AdminempMeeting({Key? key, this.meetid, this.tabController})
      : super(key: key);

  @override
  _AdminempMeeting createState() => _AdminempMeeting();
}

class _AdminempMeeting extends State<AdminempMeeting>
    with TickerProviderStateMixin {
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.index == 0) {
        setState(() {
          date = datemeeting = DateTime.now();
          _agendacontroller.text = "";
          _remarkcontroller.text = "";
        });
      }
      if (_tabController!.index == 0 && globals.meetingTabId != 0) {
        meetingempadmin();
      }
    });

    pr = ProgressDialog(context, isDismissible: false);
    pr!.style(
        message: 'Saving Meeting...',
        borderRadius: 5.0,
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 5.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400));

    super.initState();
  }

  final TextEditingController _agendacontroller = TextEditingController();
  final TextEditingController _remarkcontroller = TextEditingController();
  String agenda = "";
  String remark = "";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DateTime? date;
  DateTime? datemeeting;

  TimeOfDay? time;
  getdate() {
    if (date == null) {
      return '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
    }

    return '${date!.day}/${date!.month}/${date!.year}';
  }

  getdatemeeting() {
    if (datemeeting == null) {
      return '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
    }

    return '${datemeeting!.day}/${datemeeting!.month}/${datemeeting!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFEEEEEE),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text(
              "Meeting",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(controller: _tabController, tabs: const [
              Tab(
                text: "Meeting",
              ),
              Tab(
                text: "Meeting Details",
              ),
            ]),
          ),
          body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: [
                          Table(
                            columnWidths: const <int, TableColumnWidth>{},
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: <TableRow>[
                              TableRow(
                                children: <Widget>[
                                  const Text(
                                    "Date",
                                    style: ThemeText.pageHeaderBlack,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      datepicker(context);
                                    },
                                    child: Text(getdate()),
                                  ),
                                ],
                              ),
                              const TableRow(
                                children: <Widget>[
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  const Text("Meeting Date",
                                      style: ThemeText.pageHeaderBlack),
                                  ElevatedButton(
                                    onPressed: () {
                                      meetingdatepicker(context);
                                    },
                                    child: Text(getdatemeeting()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Form(
                            key: formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                const Text("Subject",
                                    style: ThemeText.pageHeaderBlack),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: _agendacontroller,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'Required';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                const Text("Description",
                                    style: ThemeText.pageHeaderBlack),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'Required';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _remarkcontroller,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if (getdate() == "Select Date") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Please Select The Date")));
                                  return;
                                } else if (getdatemeeting() ==
                                    "Select Meeting Date") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please Select Meeting Date")));
                                  return;
                                } else if (formkey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  savemeetingdetails();
                                }
                              },
                              child: const Text("Set Meeting")),
                        ]))),
                Tab(
                    child: AdminempMeetingLog(
                  tabController: _tabController!,
                )),
              ]),
        ));
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

  Future meetingdatepicker(BuildContext context) async {
    final initialdate = datemeeting ?? DateTime.now();
    final newDatemeeting = await showDatePicker(
        context: context,
        initialDate: initialdate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (newDatemeeting == null) return;
    setState(() {
      datemeeting = newDatemeeting;
    });
  }

  Future timepicker(BuildContext context) async {
    final inititaltime = time ?? const TimeOfDay(hour: 10, minute: 00);
    final newTime =
        await showTimePicker(context: context, initialTime: inititaltime);
    if (newTime == null) return;
    setState(() {
      time = newTime;
    });
  }

  Future<void> savemeetingdetails() async {
    pr?.style(
        message: 'Setting Meeting...',
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));
    pr?.show();

    String datenoti = getdate().split("/").reversed.join("/");
    String datemeet = getdatemeeting().split("/").reversed.join("/");
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/MeetingDetailsSave?DBName=${globals.databaseName}&UserId=${globals.userId}&MeetingId=${globals.meetingTabId}&NoticeDate=$datenoti&MeetingDate=$datemeet&Subject=${_agendacontroller.text.trim()}&Description=${_remarkcontroller.text.trim()}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Meeting has been set")));
        setState(() {
          globals.meetingTabId = 0;
          globals.subject = "";
          globals.desc = "";
          globals.meetingDate = "";
          globals.noticeDate = "";
          date = datemeeting = DateTime.now();
          _agendacontroller.clear();
          _remarkcontroller.clear();
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something Went Wrong")));
    }
    pr?.hide();
  }

  Future<void> meetingempadmin() async {
    print("object");
    if (globals.meetingTabId != 0) {
      setState(() {
        date = DateTime.parse(globals.noticeDate.split("/").reversed.join("-"));
        datemeeting =
            DateTime.parse(globals.meetingDate.split("/").reversed.join("-"));
        _agendacontroller.text = globals.desc;
        _remarkcontroller.text = globals.subject;
      });
    }
  }
}

class MeetingModal {
  MeetingModal(
      {this.desc,
      this.sub,
      this.noticedate,
      this.meetingdate,
      this.empcnt,
      this.id});
  String? desc;
  String? sub;
  String? noticedate;
  String? meetingdate;
  final int? empcnt;
  final int? id;
  factory MeetingModal.fromJson(Map<String, dynamic> json) {
    return MeetingModal(
      desc: json['Description'] ?? "",
      sub: json['Subject'] ?? "",
      noticedate: json['NotiDate'] == null
          ? getdatefrommilisec(json['NoticeDate'])
          : getdatefrommilisec(json['NoticeDate']),
      meetingdate: json['MeeDate'] == null
          ? getdatefrommilisec(json['MeetingDate'])
          : getdatefrommilisec(json['MeetingDate']),
      empcnt: json['EmployeeCount'] ?? 0,
      id: json['Id'] ?? 0,
    );
  }
}

String getdatefrommilisec(String date) {
  var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
  var orDate = DateTime.fromMillisecondsSinceEpoch(oDate!);
  String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
  return orderDate;
}

class EmpListModel {
  EmpListModel({this.meetid, this.userid});
  int? meetid;
  int? userid;
  factory EmpListModel.fromJson(Map<String, dynamic> json) {
    return EmpListModel(
      meetid: json['Id'] ?? 0,
      userid: json['UserID'] ?? 0,
    );
  }
}
