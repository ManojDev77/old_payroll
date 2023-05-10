import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'circular_admin.dart';
import 'sharedpreferences.dart' as sharedpreferences;
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

List<NoticeModal> mainNoticeList = [];
sharedpreferences.SharedPreferencesTest sharedpref =
    sharedpreferences.SharedPreferencesTest();
bool isLoaded = false;

class CircularEmployee extends StatefulWidget {
  const CircularEmployee({Key? key}) : super(key: key);

  @override
  _CircularEmployeeState createState() => _CircularEmployeeState();
}

class _CircularEmployeeState extends State<CircularEmployee> {
  @override
  void initState() {
    noticelog();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !globals.isEmployee
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: const Color(0xFFEEEEEE),
              appBar: AppBar(
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  title: const Text(
                    "Circular",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        text: "Circular",
                      ),
                      Tab(
                        text: "Circular Log",
                      ),
                    ],
                  )),
              body: TabBarView(children: [
                Tab(child: CicularAdmin()),
                Tab(
                    child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 190,
                    child: ListView.builder(
                      itemCount: mainNoticeList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return admincircularmsg(mainNoticeList, index);
                      },
                    ),
                  ),
                ))
              ]),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: AppBar(
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: const Text(
                "Circular ",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: !isLoaded
                ? const Center(child: CircularProgressIndicator())
                : mainNoticeList.isNotEmpty
                    ? ListView.builder(
                        itemCount: mainNoticeList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return admincircularmsg(mainNoticeList, index);
                        },
                      )
                    : const Center(child: Text("No Records Found")));
  }

  admincircularmsg(List<NoticeModal> listnoti, int indexnoti) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 55,
          ),
          child: Column(children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Table(
                        // border: TableBorder.all(color: Colors.grey),
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(64),
                        }, children: <TableRow>[
                      if (!globals.isEmployee)
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              "Employee    :",
                              style: ThemeText.pageHeaderBlack,
                            ),
                          ),
                          // const Padding(
                          //   padding: EdgeInsets.only(top: 5.0),
                          //   child: Text(":   "),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              listnoti[indexnoti].empname!,
                              style: ThemeText.pageHeaderBlack,
                            ),
                          ),
                        ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Description :",
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
                            listnoti[indexnoti].desc!,
                            style: ThemeText.text,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Date             :",
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
                            listnoti[indexnoti].notidate!,
                            style: ThemeText.text,
                          ),
                        ),
                      ]),
                      if (!globals.isEmployee)
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              "Read Date   :",
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
                              listnoti[indexnoti].readdate!,
                              style: ThemeText.text,
                            ),
                          ),
                        ]),
                    ]),
                    // !globals.isEmployee
                    //     ? Text(
                    //         listnoti[indexnoti].empname,
                    //         style: const TextStyle(
                    //             fontSize: 16, color: Colors.blue),
                    //       )
                    //     : Row(),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // Text(
                    //   "Description   : " + listnoti[indexnoti].desc,
                    //   style: ThemeText.text,
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // Text(
                    //   "Date               : " + listnoti[indexnoti].notidate,
                    //   style: ThemeText.text,
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // if (!globals.isEmployee)
                    //   Text(
                    //     "Read Date     : " + listnoti[indexnoti].readdate,
                    //     style: ThemeText.text,
                    //   ),

                    Align(
                        alignment: Alignment.topRight,
                        child:
                            (!listnoti[indexnoti].isread! && globals.isEmployee)
                                ? GestureDetector(
                                    child: const Icon(
                                      Icons.remove_red_eye_rounded,
                                      size: 20,
                                    ),
                                    onTap: () {
                                      reportread(listnoti[indexnoti].id!);
                                    },
                                  )
                                : Row()),
                  ],
                ),
              ),
            ),
          ])),
    );
  }

  Future<void> noticelog() async {
    isLoaded = false;
    String query =
        '${globals.applictionRootUrl}${getapi(globals.isEmployee)}${globals.databaseName}&UserId=${globals.userId}';
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
        mainNoticeList = List<NoticeModal>.from(mainListNoti);
      }
    }
    setState(() {
      isLoaded = true;
    });
  }

  String getapi(bool isemporadmin) {
    String apistring = '';
    if (isemporadmin) {
      apistring = 'API/NoticeDetailsEmpView?DBName=';
    } else {
      apistring = 'API/NoticeDetailsEmpLog?DBName=';
    }
    return apistring;
  }

  Future<void> reportread(int idread) async {
    String query =
        '${globals.applictionRootUrl}API/ReadNoticeDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&NoticeId=$idread';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You Have Read The Circular'),
        duration: Duration(seconds: 1),
      ));
      noticelog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 3),
      ));
    }
  }
}

class NoticeModal {
  const NoticeModal(
      {this.notidate,
      this.desc,
      this.isread,
      this.id,
      this.empname,
      this.seendateemp,
      this.readdate});
  final String? desc;
  final String? notidate;
  final bool? isread;
  final int? id;
  final String? empname;
  final String? seendateemp;
  final String? readdate;
  factory NoticeModal.fromJson(Map<String, dynamic> json) {
    return NoticeModal(
      desc: json['Description'] ?? "",
      notidate: json['NotiDate'] ?? "",
      isread: json['IsRead'] ?? false,
      readdate: json['RDate'] ?? "",
      id: json['Id'] ?? 0,
      empname: json['EmployeeName'] ?? "",
      seendateemp: json['RDate'] ?? "",
    );
  }
}
