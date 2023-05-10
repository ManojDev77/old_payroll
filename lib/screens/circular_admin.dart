import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../constants/style.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

List<NoticeModal> mainNoticeList = [];
ProgressDialog? pr;
int id = 0;

class CicularAdmin extends StatefulWidget {
  @override
  _CicularAdminState createState() => _CicularAdminState();
}

class _CicularAdminState extends State<CicularAdmin> {
  List<EmployeeId> mainEmployeeList = [];
  @override
  void initState() {
    noticelogadmin();
    _getEmployeeData();
    pr = ProgressDialog(context, isDismissible: false);

    pr?.style(
        message: 'Sending Circular...',
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

  Future _getEmployeeData() async {
    mainEmployeeList.clear();
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

  final TextEditingController _controller = TextEditingController();
  DateTime? date;
  getdate() {
    if (date == null) {
      return "Select Date";
    }

    return '${date!.day}/${date!.month}/${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 190,
              child: ListView.builder(
                itemCount: mainNoticeList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return admincircularmsg(mainNoticeList, index);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Colors.grey,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        controller: _controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          hintText: "Type your message",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          suffixIcon: ElevatedButton(
                              onPressed: () {
                                datepicker(context);
                                FocusScope.of(context).unfocus();
                              },
                              child: Text(
                                getdate(),
                                style: const TextStyle(fontSize: 10),
                              )),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.text == "") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please Enter The Circular")));
                              return;
                            } else if (getdate() == "Select Date") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please Select Date")));
                              return;
                            } else {
                              FocusScope.of(context).unfocus();
                              // textt=_controller.text;
                              pr?.show();
                              savenoticedata(getdate(), _controller.text, id);

                              _controller.clear();
                            }
                          });
                        },
                        icon: const Icon(Icons.send)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  admincircularmsg(List<NoticeModal> notilist, int index) {
    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 55,
          ),
          child: Column(children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  /// Add this
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Table(
                        // border: TableBorder.all(color: Colors.grey),
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(64),
                        }, children: <TableRow>[
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Description   :",
                            style: ThemeText.text,
                          ),
                        ),

                        // const Padding(
                        //   padding: EdgeInsets.only(top: 5.0),
                        //   child: Text(":   "),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            notilist[index].desc!,
                            style: ThemeText.text,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Date               :",
                            style: ThemeText.text,
                          ),
                        ),
                        // const Padding(
                        //   padding: EdgeInsets.only(top: 5.0),
                        //   child: Text(":   "),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            notilist[index].date!,
                            style: ThemeText.text,
                          ),
                        ),
                      ]),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                            ),
                            onTap: () {
                              _controller.text = notilist[index].desc!;
                              id = notilist[index].id!;
                              date = DateTime.parse(notilist[index]
                                  .date!
                                  .split("/")
                                  .reversed
                                  .join("-"));
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                            ),
                            onTap: () {
                              showAlertDlgDelete(context, notilist[index].id!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ])),
    );
  }

  showAlertDlgDelete(BuildContext context, int id) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        deletenotice(id);
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

  Future<void> noticelogadmin() async {
    String query =
        '${globals.applictionRootUrl}API/NoticeDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["NoticeDetailsList"];
      var mainListNoti = list.map((e) => NoticeModal.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainNoticeList = List<NoticeModal>.from(mainListNoti);
        });
      }
    }
  }

  Future<void> savenoticedata(String datenoti, String descrip, int id) async {
    //NoticeDetailsSave(string DBName, int UserId,int Id,DateTime NoticeDate,string Description)
    datenoti = datenoti.split("/").reversed.join("/");
    print(datenoti);
    String query =
        '${globals.applictionRootUrl}API/NoticeDetailsSave?DBName=${globals.databaseName}&UserId=${globals.userId}&Id=$id&NoticeDate=$datenoti&Description=$descrip';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      pr?.hide();
      noticelogadmin();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Circular Sent")));
    } else {
      pr?.hide();
    }
  }

  Future<void> deletenotice(int iddelete) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleting Circular...'),
      duration: Duration(seconds: 1),
    ));
    String query =
        '${globals.applictionRootUrl}API/DeleteNoticeDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&Id=$iddelete';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      noticelogadmin();
      // for (int i = 0; i < mainEmployeeList.length; i++) {
      //   int ids = mainEmployeeList[i].userid;
      //   if (globals.userId != ids) {
      //     SendNotification.sendMessage(globals.databaseName, ids.toString(),
      //         "Circular Cancelled", "Payroll");
      //   }
      // }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Circular Deleted'),
        duration: Duration(seconds: 1),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}

class NoticeModal {
  const NoticeModal({this.date, this.desc, this.isread, this.id});
  final String? desc;
  final String? date;
  final bool? isread;
  final int? id;
  factory NoticeModal.fromJson(Map<String, dynamic> json) {
    return NoticeModal(
      desc: json['Description'] ?? "",
      date: json['NotiDate'] ?? "",
      //  isread: json['IsRead'] == null ? false : json['IsRead'],
      id: json['Id'] ?? 0,
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
