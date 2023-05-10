import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:progress_dialog/progress_dialog.dart';
import '../constants/style.dart';
import 'addemptomeeting.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as dateformat;

List<MeetingModal> mainMeetingList = [];
List<EmpListModel> mainMeetingListids = [];
final _formKey = GlobalKey<FormState>();
final remarkController = TextEditingController();
ProgressDialog? pr;
bool isLoaded = false;

class AdminempMeetingLog extends StatefulWidget {
  final TabController tabController;
  const AdminempMeetingLog({Key? key, required this.tabController})
      : super(key: key);

  @override
  AdminempMeetingLogState createState() => AdminempMeetingLogState();
}

class AdminempMeetingLogState extends State<AdminempMeetingLog> {
  @override
  void initState() {
    meetingempadmin();
    super.initState();
  }

  bool clicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: RefreshIndicator(
                  onRefresh: meetingempadmin,
                  child: mainMeetingList.isNotEmpty
                      ? Container(
                          child: ListView.builder(
                            itemCount: mainMeetingList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return adminempmeetingmsg(mainMeetingList, index);
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                          "No Records Found",
                          style: TextStyle(fontSize: 30),
                        ))),
            ),
    );
  }

  adminempmeetingmsg(List<MeetingModal> meetinglist, int meetindex) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 40,
        ),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: meetinglist[meetindex].status == 3
              ? Colors.red.shade100
              : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Table(columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(64),
                }, children: <TableRow>[
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        "Subject            :",
                        style: ThemeText.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        meetinglist[meetindex].sub!.trim(),
                        style: ThemeText.text,
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        "Description     :",
                        style: ThemeText.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        meetinglist[meetindex].desc!.trim(),
                        style: ThemeText.text,
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        "Meeting Date  :",
                        style: ThemeText.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        meetinglist[meetindex]
                            .meetingdate!
                            .split("/")
                            .join("-"),
                        style: ThemeText.text,
                      ),
                    ),
                  ]),
                ]),
              ),
              if (meetinglist[meetindex].status == 3)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You have rejected this meeting.",
                      ),
                      Text(
                        "Reason              : "
                        " ${meetinglist[meetindex].remark}",
                      ),
                    ],
                  ),
                ),
              if (meetinglist[meetindex].status == 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            const Text("Approve"),
                            const SizedBox(
                              width: 2,
                            ),
                            GestureDetector(
                              child: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              onTap: () {
                                approverejectDialog(
                                    context, 1, meetinglist[meetindex].id!);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            const Text("Reject"),
                            const SizedBox(
                              width: 2,
                            ),
                            GestureDetector(
                              child: const Icon(Icons.cancel_rounded,
                                  color: Colors.red),
                              onTap: () {
                                approverejectDialog(
                                    context, 2, meetinglist[meetindex].id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (meetinglist[meetindex].userid == globals.userId ||
                  meetinglist[meetindex].status != 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (meetinglist[meetindex].userid == globals.userId)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                            onTap: () {
                              globals.meetingTabId = meetinglist[meetindex].id!;
                              globals.subject = meetinglist[meetindex].sub!;
                              globals.desc = meetinglist[meetindex].desc!;
                              globals.meetingDate =
                                  meetinglist[meetindex].meetingdate!;
                              globals.noticeDate =
                                  meetinglist[meetindex].noticedate!;
                              widget.tabController.animateTo(0);
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                            )),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (meetinglist[meetindex].userid == globals.userId
                    // meetinglist[meetindex].status != 3
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                            onTap: () {
                              showAlertDlgDelete(
                                  context, meetinglist[meetindex].id!);
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                            )),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    if ((meetinglist[meetindex].userid == globals.userId) ||
                        meetinglist[meetindex].status != 0 &&
                            meetinglist[meetindex].status != 1 &&
                            meetinglist[meetindex].status != 3)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text("Loading..."),
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            behavior: SnackBarBehavior.floating,
                          ));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEmp(
                                      id: meetinglist[meetindex].id,
                                      empsetid: meetinglist[meetindex].userid,
                                    )),
                          ).then((value) => meetingempadmin());
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 8.0, bottom: 8.0),
                          child: Row(children: [
                            const Icon(
                              Icons.people,
                              size: 18,
                            ),
                            Text(
                              "- ${meetinglist[meetindex].empcnt}",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black),
                            ),
                          ]),
                        ),
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDlgDelete(BuildContext context, int id) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        deletemeeting(id);
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

  deletemeeting(int iddelete) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleting Meeting...'),
      duration: Duration(seconds: 2),
    ));

    String query =
        '${globals.applictionRootUrl}API/DeleteMeetingDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&Id=$iddelete';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Meeting Deleted'),
        duration: Duration(seconds: 2),
      ));
      meetingempadmin();
    }
  }

  approverejectmeeting(int type, int id, String remark, int apprejid) async {
    String apprej = apprejid == 2 ? "Rejected" : "Approved";
    String query = globals.applictionRootUrl +
        'API/AcceptRejectMeeting?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        "&Type=" +
        '$type' +
        '&Id=' +
        "$id" +
        '&remarks=' +
        remark.trim();
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Meeting $apprej'),
        duration: const Duration(seconds: 3),
      ));
      meetingempadmin();
    }
  }

  approverejectDialog(BuildContext context, int apprejid, int id) {
    String apprej = apprejid == 2 ? "Reject" : "Approve";
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        remarkController.clear();
      },
    );
    Widget continueButton = TextButton(
      child: Text(apprej),
      onPressed: () {
        if (apprej == "Reject") {
          final form = _formKey.currentState;
          if (form!.validate()) {
            approverejectmeeting(2, id, remarkController.text, apprejid);
            remarkController.clear();
            Navigator.of(context, rootNavigator: true).pop('dialog');
          }
        } else {
          approverejectmeeting(1, id, remarkController.text, apprejid);
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      },
    );

    AlertDialog alert = AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Do you want to proceed?"),
            if (apprej == "Reject")
              TextFormField(
                controller: remarkController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                ),
                onSaved: (String? value) {},
                validator: (String? value) {
                  return (value!.isEmpty ? 'Reason required' : null);
                },
              )
          ],
        ),
      ),
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

  Future<void> meetingempadmin() async {
    if (mounted) {
      setState(() {
        isLoaded = false;
        mainMeetingList.clear();
        globals.meetingTabId = 0;
        globals.subject = "";
        globals.desc = "";
        globals.meetingDate = "";
        globals.noticeDate = "";
      });
    }
    String query =
        '${globals.applictionRootUrl}API/MeetingDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["model"]["MeetingDetailsList"];
      var mainListMeet = list.map((e) => MeetingModal.fromJson(e)).toList();
      mainMeetingList = List<MeetingModal>.from(mainListMeet);
    }

    //mainMeetingList.removeWhere((element) => element.userid != globals.userId);

    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }
}

class MeetingModal {
  const MeetingModal(
      {this.desc,
      this.sub,
      this.noticedate,
      this.meetingdate,
      this.empcnt,
      this.id,
      this.userid,
      this.status,
      this.remark});
  final String? desc;
  final String? sub;
  final String? noticedate;
  final String? meetingdate;
  final int? empcnt;
  final int? id;
  final int? userid;
  final int? status;
  final String? remark;
  factory MeetingModal.fromJson(Map<String, dynamic> json) {
    return MeetingModal(
        desc: json['Description'] ?? "",
        status: json['Status'] ?? 0,
        sub: json['Subject'] ?? "",
        noticedate: getdatefrommilisec(json['NoticeDate']),
        meetingdate: getdatefrommilisec(json['MeetingDate']),
        empcnt: json['EmployeeCount'] ?? 0,
        id: json['Id'] ?? 0,
        remark: json['RejectionRemarks'] ?? "",
        userid: json['UserId'] ?? 0);
  }
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

String getdatefrommilisec(String date) {
  var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
  var orDate = DateTime.fromMillisecondsSinceEpoch(oDate!);
  String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
  return orderDate;
}
