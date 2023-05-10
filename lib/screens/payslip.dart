import 'package:path_provider/path_provider.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class Payslipdownload extends StatefulWidget {
  @override
  PayslipdownloadState createState() => PayslipdownloadState();
}

class PayslipdownloadState extends State<Payslipdownload> {
  ProgressDialog? pr;
  bool isloading = false;
  String yearListValue = "";
  // Directory directory;
  int? cleckedindex;
  bool loaded = false;
  bool cliked = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    //  _getPayslipList();
    _getpayrollyearlist();
    super.initState();
  }

  TextEditingController searchcontroller = TextEditingController();
  List<PayModel> searchList = [];
  List<PayModel> empList = [];
  List<DropdownMenuItem<String>> monthList = [];
  List<MonthModel> mainMonthList = [];
  List<PayModel> mainPayslipList = [];
  String empname = "";
  String empcode = "";
  String dept = "";
  bool permissionGranted = false;
  double progress = 0;
  Timer? _timer;

  //List<DropdownMenuItem<String>> monthList = [];
  List<DropdownMenuItem<String>> yearList = [];
  _getpayrollyearlist() async {
    yearList.clear();
    yearList.add(const DropdownMenuItem(
      value: "",
      child: Text("Select"),
    ));
    // setState(() {
    //   isLoaded = false;
    // });
    String query =
        '${globals.applictionRootUrl}API/GetPayrollYearList?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var yearitems = jobject;

      // print(yearitem);
      // accountitem = new List<String>.from(streetsFromJson["Text"]);
      // var mainList = monthitems.map((e) => new MonthModel.fromJson(e)).toList();

      setState(() {
        // mainMonthList = List<MonthModel>.from(mainList);
        yearitems.forEach((item) {
          yearList.add(DropdownMenuItem(
              value: item["Value"].toString(),
              child: Text(item["Text"].toString())));

          //  _salaryDetailsData();
        });

        if (yearList.isNotEmpty) {
          if (yearList.length == 2) {
            yearListValue = yearList[1].value!;
            _getpayrollmonthlist();
          } else {
            yearListValue = yearList[1].value!;
            _getpayrollmonthlist();
          }
        }
        // isLoaded = true;
      });
    }
  }

  _getpayrollmonthlist() async {
    // salaryList.clear();
    String query =
        '${globals.applictionRootUrl}API/GetPayrollYearWiseMonthList?DBName=${globals.databaseName}&UserId=${globals.userId}&YearId=$yearListValue';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => MonthModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainMonthList = List<MonthModel>.from(mainList);
        });
      }
      if (globals.isEmployee) {
        for (int i = 0; i < mainMonthList.length; i++) {
          _getPayslipList(mainMonthList[i].monthid.toString());
        }
      }
    }
  }

  Future _getPayslipList(String monthListValue) async {
    setState(() {
      loaded = false;
    });
    // monthList.clear();
    // monthList.add(new DropdownMenuItem(
    //   child: new Text("Select"),
    //   value: "",
    // ));
    String query =
        '${globals.applictionRootUrl}API/PayslipDetailsList?DBName=${globals.databaseName}&UserId=${globals.userId}&Monthid=$monthListValue';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var maingridlist = jobject["result"];
      var listt = jobject["Monthlist"];
      // var list = new List.from(listt.reversed);
      var mainList = maingridlist.map((e) => PayModel.fromJson(e)).toList();
      //var receiptbal = jobject["DashboardData"]["totalExp"];
      // var s = list.map((e) => e["RelationType"].toString()).toList();
      // List responseJson = json.decode(list);
      if (mounted) {
        setState(() {
          mainPayslipList = List<PayModel>.from(mainList);
          print(mainPayslipList.length);
          // var smainPayslipList =
          //     maingridlist.map((e) => new PayModel.fromJson(e)).toList();

          // mainPayslipList = List<PayModel>.from(smainPayslipList);
          empList.addAll(mainPayslipList);

          loaded = true;
        });
      }
    }
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

  Future _downloadPayslip(String name, int monthid, int billId) async {
    Directory appDocDirectory;
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        appDocDirectory = (await getExternalStorageDirectory())!;
        print(appDocDirectory);
        // new Directory(appDocDirectory.path + "/OfficeAnywhere Payslip")
        //     .create(recursive: true)
        //     .then((Directory directory) {
        //   print('Path of New Dir: ' + directory.path);
        //   // directory = Directory(directory.path);
        // });
        // appDocDirectory = await getExternalStorageDirectory();
        // print(appDocDirectory);
        // String newPath = "";
        // List<String> paths = appDocDirectory.path.split("/");
        // for (int x = 1; x < paths.length; x++) {
        //   String folder = paths[x];

        //   if (folder != "data") {
        //     newPath += "/" + folder;
        //     print(newPath);
        //   } else {
        //     break;
        //   }
        // }
        // newPath = appDocDirectory.path + "/OfficeAnywhere Payslip";

        // new Directory(appDocDirectory.path + "/OfficeAnywhere Payslip")
        //     .create(recursive: true);

      } else {
        return false;
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        appDocDirectory = await getTemporaryDirectory();
      } else {
        return false;
      }
    }
    // var dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var filename = "${name}_PaySlip";
    print(appDocDirectory.path);

    File saveFile = File("/storage/emulated/0/Download/$filename.pdf");
    // if (!await appDocDirectory.exists()) {
    //   await appDocDirectory.create(recursive: true);
    // }

    String query =
        '${globals.applictionRootUrl}API/PrintPayslips?DBName=${globals.databaseName}&UserId=${globals.userId}&Monthid=$monthid&Empid=$billId';

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      try {
        var jobject = jsonDecode(response.body.toString());
        var data = jobject;

        saveFile.writeAsBytes(data['bytes'].cast<int>());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('File Downloaded Successfully!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFile.open(saveFile.path, type: "application/pdf");
            },
          ),
        ));
      } catch (e) {}
      setState(() {
        isloading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Try Again Later'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  String monthValue = "";
  // Future _downloadPayslip(int index) async {
  //   mainPayslipList[index].monthid.toString();
  //   mainPayslipList[index].empid.toString();

  //   final http.Response response = await http.post(
  //     globals.applictionRootUrl +
  //         'API/PrintPayslips?DBName=' +
  //         globals.databaseName +
  //         '&userId=' +
  //         globals.userId.toString() +
  //         '&Monthid=' +
  //         mainPayslipList[index].monthid.toString() +
  //         '&Empid=' +
  //         mainPayslipList[index].empid.toString(),
  //     headers: <String, String>{
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     var jobject = jsonDecode(response.body.toString());
  //     String link = jobject["ApplicationPath"] + "\\" + jobject["Filename"];
  //     String maindir = (await pathprovider.getExternalStorageDirectory()).path;

  //     var maindirs = (await pathprovider.getExternalStorageDirectories());
  //     String dir = (await pathprovider.getExternalStorageDirectory())
  //             .parent
  //             .parent
  //             .parent
  //             .parent
  //             .path +
  //         "/Download";
  //     String file = "$maindir";
  //     var path = Directory("$maindir");
  //     if ((await path.exists())) {
  //     } else {
  //       maindir = dir;
  //     }
  //     //await FlutterDownloader.initialize(debug: true);
  //     // final taskId = await FlutterDownloader.enqueue(
  //     //   url: 'https://erachana.in/images/ERachana-All-Products-Logos/saas.png',
  //     //   savedDir: maindir,
  //     //   showNotification:
  //     //       true, // show download progress in status bar (for Android)
  //     //   openFileFromNotification:
  //     //       true, // click on notification to open downloaded file (for Android)
  //     // );
  //     // if (taskId != null) {
  //     //   var a = 1;
  //     // }
  //     File filen = new File(link);
  //     String fileName = filen.path.split('/').last;
  //     var dio = Dio();
  //     download2(dio, link, "$maindir/$fileName");
  //   }
  // }

  // Future download2(Dio dio, String url, String savePath) async {
  //   try {
  //     Response response = await dio.get(
  //       url,
  //       onReceiveProgress: showDownloadProgress,
  //       //Received data with List<int>
  //       options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status < 500;
  //           }),
  //     );
  //     print(response.headers);
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     // response.data is List<int> type
  //     raf.writeFromSync(response.data);
  //     await raf.close();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // void showDownloadProgress(received, total) {
  //   if (total != -1) {
  //     print((received / total * 100).toStringAsFixed(0) + "%");
  //   }
  // }

  showAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Download"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        _downloadPayslip(
            !globals.isEmployee
                ? mainPayslipList[index].empname!
                : empList[index].empname!,
            !globals.isEmployee
                ? mainPayslipList[index].monthid!
                : empList[index].monthid!,
            !globals.isEmployee
                ? mainPayslipList[index].empid!
                : empList[index].empid!);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Alert"),
      content: const Text("Are you sure want to Download?"),
      actions: [
        cancelButton,
        continueButton,
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

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Download Payslip'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 0.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("F.Y",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 22.2,
                      )),
                  const SizedBox(width: 30),
                  DropdownButton<String>(
                    value: yearListValue,
                    isExpanded: false,
                    elevation: 20,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        yearListValue = newValue!;
                      });
                      empList.clear();
                      loaded = false;
                      cliked = false;
                      _getpayrollmonthlist();
                    },
                    items: yearList,
                  ),
                ]),
                // Container(
                //   color: Theme.of(context).primaryColor,
                //   child: new Padding(
                //     padding: const EdgeInsets.all(3.0),
                //     child: new Card(
                //       child: new ListTile(
                //         leading: new Icon(Icons.search),
                //         title: new TextField(
                //           autofocus: false,
                //           controller: searchcontroller,
                //           decoration: new InputDecoration(
                //               hintText: 'Search', border: InputBorder.none),
                //           onChanged: onSearchTextChanged,
                //         ),
                //         trailing: new IconButton(
                //           icon: new Icon(Icons.cancel),
                //           onPressed: () {
                //             // isSearch = false;
                //             searchcontroller.clear();
                //             onSearchTextChanged('');
                //           },
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                globals.isEmployee
                    ? empList.isEmpty
                        ? Center(
                            heightFactor: 15,
                            child: Text(
                              "No records found".toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontFamily: "poppins-medium"),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: empList.length,
                              itemBuilder: (context, index) {
                                return buildPayslipItem(empList[index], index);
                              },
                            ),
                          )
                    : Row(),

                !globals.isEmployee
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: mainMonthList.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                                height: loaded && mainPayslipList.isNotEmpty
                                    ? cleckedindex == index
                                        ? 300.0
                                        : 90
                                    : 90,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.all(10.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEEEEEE),
                                            // borderRadius: BorderRadius.all(
                                            //     Radius.elliptical(20.0, 20.0)),
                                          ),
                                          child: Column(children: [
                                            Text(
                                                // (index + 1).toString() +
                                                //     ". " +
                                                mainMonthList[index].year!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  letterSpacing: 3,
                                                )),
                                            // SizedBox(
                                            //   height: 10,
                                            // ),
                                            loaded &&
                                                    mainPayslipList
                                                        .isNotEmpty &&
                                                    cleckedindex == index
                                                ? Expanded(
                                                    child: ListView.builder(
                                                        shrinkWrap: false,
                                                        itemCount:
                                                            mainPayslipList
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return buildPayslipItem(
                                                              mainPayslipList[
                                                                  index],
                                                              index);
                                                        }))
                                                : Row(),
                                            Text(
                                                loaded &&
                                                        cliked &&
                                                        mainPayslipList
                                                            .isEmpty &&
                                                        cleckedindex == index
                                                    ? "No Payslip"
                                                    : "",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                )),
                                          ]),
                                        ),
                                      ),
                                      Positioned(
                                        right: 5.0,
                                        top: -1.0,
                                        child: IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              cleckedindex = index;
                                              cliked = true;
                                            });
                                            _getPayslipList(
                                              (mainMonthList[index].monthid)
                                                  .toString(),
                                            );
                                          },
                                          icon: const Icon(Icons.add_circle),
                                          color: Colors.black87,
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    : Row(),
              ],
            ),
          )
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    final txt = text.toString().toLowerCase();
    for (var detail in empList) {
      if (detail.empname!.toLowerCase().contains(txt) ||
          detail.depmt.toString().toLowerCase().contains(txt)) {
        searchList.add(detail);
      }
    }

    if (txt.isNotEmpty || searchcontroller.text.isNotEmpty) {
      mainPayslipList = searchList;
    } else {
      mainPayslipList = empList;
    }
  }

  Widget buildPayslipItem(PayModel data, int index) {
    print(index);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  globals.isEmployee ? getmonth(data.monthid!) : data.empname,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Material(
            borderRadius: BorderRadius.circular(100.0),
            color: Colors.purple.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                icon: const Icon(Icons.file_download),
                color: Colors.purple,
                iconSize: 30.0,
                onPressed: () {
                  showAlertDialog(context, index);
                },
              ),
            ),
          ),
          // Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text(
          //         // data.receipt,
          //         data.empname,
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 18.0,
          //             fontWeight: FontWeight.bold),
          //       ),
          //       // Text(
          //       //   // data.receipt,
          //       //   data.empname,
          //       //   style: TextStyle(
          //       //       color: Colors.black,
          //       //       fontSize: 18.0,
          //       //       fontWeight: FontWeight.bold),
          //       // ),
          //       // Text(
          //       //   // data.date,
          //       //   data.depmt,
          //       //   style: TextStyle(
          //       //       color: Colors.black.withOpacity(0.8),
          //       //       fontSize: 16.0,
          //       //       fontWeight: FontWeight.bold),
          //       // ),
          //       // Text(
          //       //   data.account,
          //       //   style: TextStyle(
          //       //     fontSize: 15.0,
          //       //   ),
          //       // )
          //     ],
          //   ),
          // ),
          // Text(
          //   // data.amount.toString(),
          //   data.netamount.toString(),
          //   style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 18.0,
          //       fontWeight: FontWeight.bold),
          // )
        ],
        // children: <Widget>[
        //   Material(
        //     borderRadius: BorderRadius.circular(100.0),
        //     color: Colors.purple.withOpacity(0.1),
        //     child: Padding(
        //       padding: EdgeInsets.all(5.0),
        //       child: IconButton(
        //         padding: EdgeInsets.all(7.0),
        //         icon: Icon(Icons.file_download),
        //         color: Colors.purple,
        //         iconSize: 30.0,
        //         onPressed: () {
        //           // Navigator.of(context).push(
        //           //     MaterialPageRoute(
        //           //         builder:
        //           //             (BuildContext context) =>
        //           //                 LeaveStatusWidget()));
        //         },
        //       ),
        //     ),
        //   ),
        //   SizedBox(width: 25.0),
        //   GestureDetector(
        //     onTapUp: (TapUpDetails details) {
        //       showPopup(details.globalPosition);
        //     },
        //     child: Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: <Widget>[
        //           Text(
        //             'Nisha',
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontSize: 18.0,
        //                 fontWeight: FontWeight.bold),
        //           ),
        //           Text(
        //             '10/2/2020',
        //             style: TextStyle(
        //                 color: Colors.black.withOpacity(0.8),
        //                 fontSize: 16.0,
        //                 fontWeight: FontWeight.bold),
        //           )
        //         ],
        //       ),
        //     ),
        //   ),
        //   Text(
        //     'Rejected',
        //     style: TextStyle(
        //         color: Colors.black,
        //         fontSize: 17.0,
        //         fontWeight: FontWeight.bold),
        //   )
        // ],
      ),
    );
  }

  getmonth(int id) {
    String? month;
    for (int i = 0; i < mainMonthList.length; i++) {
      if (int.parse(mainMonthList[i].monthid!) == id) {
        month = mainMonthList[i].year;
      }
    }
    return month;
  }
}

void showDialogTemplate(BuildContext context, String title, String subtitle,
    String gif, Color color, String buttonText) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 40,
        child: AlertDialog(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                gif,
                width: 175,
              ),
              Text(subtitle, style: const TextStyle(color: Colors.white60)),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class PayModel {
  const PayModel(
      {this.empid, this.monthid, this.empname, this.netamount, this.depmt});

  final int? empid;
  final int? monthid;
  final String? empname;
  final double? netamount;
  final String? depmt;
  factory PayModel.fromJson(Map<String, dynamic> json) {
    return PayModel(
      //date: '22/10/2020',
      empid: json['empid'] ?? 0,
      monthid: json['monthid'] ?? 0,
      empname: json['empname'] ?? "",
      netamount: json['netamount'] ?? 0,
      depmt: json['department'] ?? "",
    );
  }
}

class MonthModel {
  MonthModel({
    this.year,
    this.monthid,
  });

  final String? monthid;
  final String? year;

  factory MonthModel.fromJson(Map<String, dynamic> json) {
    return MonthModel(
      year: json['Text'] ?? "",
      monthid: json['Value'] ?? "",
    );
  }
}

class MonthListModel {
  const MonthListModel({
    this.id,
    this.monthid,
    this.empname,
    this.totalearning,
    this.totaldeduction,
    this.netamount,
  });

  final int? id;
  final int? monthid;
  final String? empname;
  final double? totalearning;
  final double? totaldeduction;
  final double? netamount;

  factory MonthListModel.fromJson(Map<String, dynamic> json) {
    return MonthListModel(
      id: json['EmployeeId'] ?? 0,
      monthid: json['MonthId'] ?? 0,
      empname: json['EmployeeName'] ?? "",
      totalearning: json['TotalEar'] == null ? "" : json['TotalEar'] + 0.0,
      totaldeduction: json['TotalDed'] == null ? "" : json['TotalDed'] + 0.0,
      netamount: json['GrossAmount'] == null ? "" : json['GrossAmount'] + 0.0,
    );
  }
}
