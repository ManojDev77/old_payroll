import 'dart:convert';
import 'package:badges/badges.dart' as Badge;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as dateformat;
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class AllEmpDetails extends StatefulWidget {
  final String? empdept;
  const AllEmpDetails({Key? key, this.empdept}) : super(key: key);

  @override
  _AllEmpDetailsState createState() => _AllEmpDetailsState();
}

class _AllEmpDetailsState extends State<AllEmpDetails> {
  List<AllEmployeeDetails> mainEmpList = [];
  List<AllEmployeeDetails> mainEmpListNew = [];
  List<AllEmployeeDetails> searchList = [];
  List<AllEmployeeDetails> empList = [];
  TextEditingController searchcontroller = TextEditingController();
  bool isLoaded = false;
  @override
  void initState() {
    allEmployeeDetails();
    super.initState();
  }

  Future<void> allEmployeeDetails() async {
    String query =
        '${globals.applictionRootUrl}API/AllEmployeeDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var emplist = jobject["EmployeeList"];
      var mainListEmp =
          emplist.map((e) => AllEmployeeDetails.fromJson(e)).toList();
      if (mounted) {
        mainEmpList = List<AllEmployeeDetails>.from(mainListEmp);
        mainEmpListNew = mainEmpList
            .where((element) => element.dept == widget.empdept)
            .toList();
        empList = mainEmpList;
      }
    }
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text("Employee Details"),
          actions: [
            isLoaded
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: Badge.Badge(
                        badgeColor: Colors.pink,
                        toAnimate: false,
                        badgeContent: Text(
                          "${mainEmpList.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: const Icon(Icons.people)))
                : Row()
          ],
        ),
        body: !isLoaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(5),
                child: SingleChildScrollView(
                    child: Column(children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Card(
                        elevation: 2,
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
                              // isSearch = false;
                              searchcontroller.clear();
                              onSearchTextChanged('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: mainEmpList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  color: const Color(0xffeeeeee),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Employee Name ",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Employee Code ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                  child: const Text(
                                                    "E-Mail : ",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text: mainEmpList[
                                                                        index]
                                                                    .mail))
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Email copied to your clipboard !')));
                                                    });
                                                  }),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                  child: const Text(
                                                    "Mobile Number ",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text: mainEmpList[
                                                                        index]
                                                                    .num))
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Mobile Number copied to your clipboard !')));
                                                    });
                                                  }),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Designation  ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Department ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "DOB ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Join Date ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                mainEmpList[index].leftdate !=
                                                        ""
                                                    ? "Left Date :  "
                                                    : "",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ": ${mainEmpList[index].empname}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ": ${mainEmpList[index].empcode}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                  child: Text(
                                                    ": ${mainEmpList[index].mail}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text: mainEmpList[
                                                                        index]
                                                                    .mail))
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Email copied to your clipboard !')));
                                                    });
                                                  }),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                  child: Text(
                                                    ": ${mainEmpList[index].num}",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text: mainEmpList[
                                                                        index]
                                                                    .num))
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Mobile Number copied to your clipboard !')));
                                                    });
                                                  }),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ": ${mainEmpList[index].desig}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ": ${mainEmpList[index].dept}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ": ${mainEmpList[index].dob}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ": ${mainEmpList[index].joindate}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                mainEmpList[index].leftdate !=
                                                        ""
                                                    ? ": ${mainEmpList[index].leftdate}"
                                                    : "",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  )));
                        }),
                  )
                ]))));
  }

  onSearchTextChanged(String text) async {
    print(text);
    searchList.clear();
    final txt = text.toString().toLowerCase();
    print(txt);

    for (var detail in empList) {
      if (detail.empname!.toLowerCase().contains(txt) ||
          detail.empcode.toString().toLowerCase().contains(txt) ||
          detail.mail!.toLowerCase().contains(txt) ||
          detail.num!.toLowerCase().contains(txt) ||
          detail.desig.toString().toLowerCase().contains(txt) ||
          detail.dept.toString().toLowerCase().contains(txt) ||
          detail.joindate!.toLowerCase().contains(txt) ||
          detail.leftdate.toString().toLowerCase().contains(txt) ||
          detail.dob.toString().toLowerCase().contains(txt)) {
        searchList.add(detail);
      }
    }

    if (txt.isNotEmpty || searchcontroller.text.isNotEmpty) {
      mainEmpList = searchList;
    } else {
      mainEmpList = empList;
    }
    setState(() {});
  }
}

class AllEmployeeDetails {
  const AllEmployeeDetails({
    this.empname,
    this.empcode,
    this.mail,
    this.num,
    this.desig,
    this.dept,
    this.joindate,
    this.leftdate,
    this.dob,
  });

  final String? empname;
  final String? empcode;
  final String? mail;
  final String? num;
  final String? desig;
  final String? dept;
  final String? joindate;
  final String? leftdate;
  final String? dob;

  factory AllEmployeeDetails.fromJson(Map<String, dynamic> json) {
    return AllEmployeeDetails(
      empname: json['EmpName'] ?? "",
      empcode: json['ReferenceNum'] ?? "",
      mail: json['EmailID'] ?? "",
      num: json['MobileNum1'] ?? "",
      desig: json['EmpDesignationName'] ?? "",
      dept: json['EmpDepartmentName'] ?? "",
      joindate:
          json['JoinDate'] == null ? "" : getdatefrommilisec(json['JoinDate']),
      leftdate:
          json['LeftDate'] == null ? "" : getdatefrommilisec(json['LeftDate']),
      dob: json['DateOfBirth'] == null
          ? ""
          : getdatefrommilisec(json['DateOfBirth']),
    );
  }
}

String getdatefrommilisec(String date) {
  var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
  var orDate = DateTime.fromMillisecondsSinceEpoch(oDate!);
  String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
  return orderDate;
}
