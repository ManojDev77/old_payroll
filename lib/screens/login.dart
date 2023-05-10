import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_send_notification.dart';
import 'TaskAndAttendance.dart';
import 'dashboard_leave.dart';
import 'dashboard_payroll.dart';
import 'fieldStaffTracker.dart';
import 'globals.dart' as globals;
import 'onlyTaskManager.dart';
import 'sharedpreferences.dart' as sharedpreferences;
import 'screens.dart';

ProgressDialog? pr;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payroll',
      theme: ThemeData(
        fontFamily: 'VarelaRound',
        //primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyLoginPage(title: 'Home Page'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  MyLoginPageState createState() => MyLoginPageState();
}

const snackBar = SnackBar(
  content: Text('Invalid Login!'),
);
const snackBarLogin = SnackBar(
  content: Text('Login Successful'),
);

class MyLoginPageState extends State<MyLoginPage> {
  bool _showPassword = true;
  Map? data;
  List? userData;
  List<AppListModel> applist = [];
  List<LoginProfile> alllogins = [];
  sharedpreferences.SharedPreferencesTest sharedpref =
      sharedpreferences.SharedPreferencesTest();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? _username;
  TextEditingController? _password;

  String companydropdownValue = '';
  String appdropdownValue = '';
  List<DropdownMenuItem<String>> companyDropdownitems = [];
  List<DropdownMenuItem<String>> appDrodownitems = [];
  bool isloading = false;
  bool isdone = false;
  @override
  void initState() {
    super.initState();

    pr = ProgressDialog(context);
    pr?.style(
        message: 'Please Wait...',
        borderRadius: 5.0,
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 5.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400));
    _username = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _username!.dispose();
    _password!.dispose();
    super.dispose();
  }

  void _login() {
    String username = _username!.text;
    String password = _password!.text;
    if (username == '') {
      showInSnackBar("Enter Email ID");
      return;
    }
    if (password == '') {
      showInSnackBar("Enter Password");
      return;
    }
    // pr.show();
    setState(() {
      isloading = true;
      isdone = false;
    });

    globals.isLoggedIn = true;
    getData(username, password);
  }

  Future<void> getData(String email, String password) async {
    String query =
        '${globals.ofcRootUrl}CheckOfficeanywhereLogin?Email=${email.replaceAll("\r\n", " ").replaceAll("+", "%2B")}&Password=${password.replaceAll("\r\n", " ").replaceAll("+", "%2B").replaceAll(' ', "%20").replaceAll('&', '%26').replaceAll('!', '%21').replaceAll('#', '%23').replaceAll('-', '%2D').replaceAll('/', '%2F').replaceAll('.', '%2E').replaceAll('"', '%22')}';
    http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      List responseJson = json.decode(jobject);
      if (responseJson.isEmpty) {
        setState(() {
          isloading = false;
          isdone = false;
        });
        showInSnackBar("Invalid Login");
      } else {
        var jobject1 = jsonDecode(response.body.toString());
        List responseJson = json.decode(jobject1);
        int userId = responseJson[0]["Id"];
        globals.userId = userId;

        setState(() {
          isloading = false;
          isdone = true;
        });

        showInSnackBar("Login Successful");
        loadDropdowns();
        applist.clear();
      }
    } else {
      showInSnackBar("Something went wrong");
    }
  }

  Future loadApplist() async {
    final prefs = await SharedPreferences.getInstance();
    pr?.show();
    applist.clear();
    //  String query =
    //     '${globals.ofcRootUrl}GetApplicationData?CompanyName=${companydropdownValue.replaceAll("+", "%2B").replaceAll(' ', "%20").replaceAll('&', '%26').replaceAll('!', '%21').replaceAll('#', '%23').replaceAll('-', '%2D').replaceAll('/', '%2F').replaceAll('.', '%2E').replaceAll('"', '%22')}&AppId=2,5,27,28,29&UserId=${globals.userId}';

    String query =
        '${globals.ofcRootUrl}GetApplicationData?CompanyName=${companydropdownValue.replaceAll("+", "%2B").replaceAll(' ', "%20").replaceAll('&', '%26').replaceAll('!', '%21').replaceAll('#', '%23').replaceAll('-', '%2D').replaceAll('/', '%2F').replaceAll('.', '%2E').replaceAll('"', '%22')}&AppId=2,5,27,28,29&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject1 = jsonDecode(response.body.toString());

      List responseJson1 = json.decode(jobject1);
      if (responseJson1.isNotEmpty) {
        applist = responseJson1.map((e) => AppListModel.fromJson(e)).toList();
      }
    }

    pr?.hide();
    await prefs.setInt('appcount', 0);
    if (applist.isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Instance has not been created',
                style: TextStyle(fontSize: 18)),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Please contact our support team for help.'),
                  SizedBox(height: 2),
                  Text('+91 7829627077', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 2),
                  Text('officeanywhere@gaamma.in',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (applist.length == 1) {
      await prefs.setInt('appcount', applist.length);
      globals.appcount = prefs.getInt('appcount')!;
      openApp(0);
    } else {
      await prefs.setInt('appcount', applist.length);
      globals.appcount = prefs.getInt('appcount')!;
      displayDialog(context);
    }
  }

  Future loadDropdowns() async {
    final prefs = await SharedPreferences.getInstance();
    companyDropdownitems.clear();
    companyDropdownitems.add(const DropdownMenuItem(
      value: "",
      child: Text("Select Company"),
    ));

    final http.Response response = await http.post(
      Uri.parse('${globals.ofcRootUrl}GetCompanyData?UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    List<String> companyDdnitems = [];
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      List responseJson = json.decode(jobject);
      if (responseJson.isNotEmpty) {
        companyDdnitems =
            responseJson.map((e) => e["CompanyName"].toString()).toList();
      }
    }
    for (var item in companyDdnitems) {
      companyDropdownitems.add(DropdownMenuItem(
        value: item,
        child: Text(item.toString()),
      ));
    }
    if (companyDropdownitems.isNotEmpty) {
      if (companyDropdownitems.length == 2) {
        companydropdownValue = companyDropdownitems[1].value!;
        await prefs.setInt('companycount', companyDropdownitems.length);
        globals.compcount = prefs.getInt('companycount')!;
        loadApplist();
      } else {
        await prefs.setInt('companycount', companyDropdownitems.length);
        globals.compcount = prefs.getInt('companycount')!;
        companydropdownValue = companyDropdownitems[0].value!;
        getDropDowndataShowDialog(context);
      }
    }
  }

  Future _getLeaveRole() async {
    String query =
        '${globals.applictionRootUrl}API/GetLeaveSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveAttendance = jobject["SettingData"]["Attendance"];
      var leaveSublogin = jobject["SettingData"]["SubLogin"];
      var leaveGPS = jobject["SettingData"]["GPSTracking"];
      var logintime = jobject["SettingData"]["LInTime"];
      var logouttime = jobject["SettingData"]["LOutTime"];
      var taskManagement = jobject["SettingData"]["TaskManagement"];
      var yearType = jobject["SettingData"]["YearType"];

      if (yearType == 0) {
        globals.yearType = 0;
        sharedpref.setIntExtra("yeartype", 0);
      } else {
        globals.yearType = 1;
        sharedpref.setIntExtra("yeartype", 1);
      }
      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");
      print(logintime);

      if (taskManagement == true) {
        globals.istaskenabled = true;
        sharedpref.setBoolExtra("istaskenabled", true);
      } else {
        globals.istaskenabled = false;
        sharedpref.setBoolExtra("istaskenabled", false);
      }

      if (leaveAttendance == true) {
        globals.isLeaveAttendance = true;
        sharedpref.setBoolExtra("isLeaveAttendance", true);
      } else {
        sharedpref.setBoolExtra("isLeaveAttendance", false);
      }

      if (leaveSublogin == true) {
        globals.isLeaveSublogin = true;
        sharedpref.setBoolExtra("isLeaveSublogin", true);
      } else {
        sharedpref.setBoolExtra("isLeaveSublogin", false);
      }
      if (leaveGPS == true) {
        globals.isleaveGPS = true;
        sharedpref.setBoolExtra("isleaveGPS", true);
      } else {
        sharedpref.setBoolExtra("isleaveGPS", false);
      }
    }
  }

  Future _getuserRole() async {
    String query =
        '${globals.applictionRootUrl}API/GetUserRole?DBName=${globals.databaseName}&userId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var role = jobject;
      if (role.toString() == "2") {
        globals.isEmployee = true;
        sharedpref.setBoolExtra("isEmployee", true);
      } else {
        sharedpref.setBoolExtra("isEmployee", false);
      }
    }
  }

  Future _changeRole() async {
    String query =
        '${globals.applictionRootUrl}API/GetSettingsDetails?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var leaveEnable = jobject["Item1"][6]["SettingValue"];
      var attendanceEnable = jobject["Item1"][20]["SettingValue"];
      var gpsenable = jobject["Item1"][21]["SettingValue"];
      var sublogin = jobject["Item1"][23]["SettingValue"];
      var photocap = jobject["Item1"][33]["SettingValue"];
      var employeeContact = jobject["Item1"][32]["SettingValue"];
      var employeelogin = jobject["Item1"][12]["SettingValue"];
      // var leaveEnable = jobject[6]["SettingValue"];
      // var attendanceEnable = jobject[20]["SettingValue"];
      // var gpsenable = jobject[21]["SettingValue"];
      // var sublogin = jobject[23]["SettingValue"];

      var logintime = jobject["Item2"]["SettingData"]["LInTime"];
      var logouttime = jobject["Item2"]["SettingData"]["LOutTime"];

      sharedpref.setStringExtra('logintime', logintime ?? "not set");
      sharedpref.setStringExtra('logouttime', logouttime ?? "not set");
      if (employeelogin == true) {
        globals.employeelogin = true;
        sharedpref.setBoolExtra("isEmpLogin", true);
      } else {
        globals.employeelogin = false;

        sharedpref.setBoolExtra("isEmpLogin", false);
      }
      // var leaveAttendance = jobject["Item2"]["SettingData"]["Attendance"];
      // var leaveSublogin = jobject["Item2"]["SettingData"]["SubLogin"];
      // var leaveGPS = jobject["Item2"]["SettingData"]["GPSTracking"];

      if (photocap == true) {
        globals.loginphotocap = true;
        sharedpref.setBoolExtra("isLoginCap", true);
      } else {
        globals.loginphotocap = false;
        sharedpref.setBoolExtra("isLoginCap", false);
      }
      if (employeeContact == true) {
        globals.isempcontactenabled = true;
        sharedpref.setBoolExtra("isEmpCnt", true);
      } else {
        globals.isempcontactenabled = false;
        sharedpref.setBoolExtra("isEmpCnt", false);
      }
      if (leaveEnable == true) {
        globals.isLeave = true;
        sharedpref.setBoolExtra("isLeave", true);
      } else {
        sharedpref.setBoolExtra("isLeave", false);
      }
      if (attendanceEnable == true) {
        globals.isAttendance = true;
        sharedpref.setBoolExtra("isAttendance", true);
      } else {
        sharedpref.setBoolExtra("isAttendance", false);
      }

      if (gpsenable == true) {
        globals.isGPS = true;
        sharedpref.setBoolExtra("isGPS", true);
      } else {
        sharedpref.setBoolExtra("isGPS", false);
      }
      if (sublogin == true) {
        globals.isSublogin = true;
        sharedpref.setBoolExtra("isSublogin", true);
      } else {
        sharedpref.setBoolExtra("isSublogin", false);
      }
    }
  }

  void getDropDowndataShowDialog(BuildContext context) {
    displayDialog(context);
  }

  void openApp(int index) async {
    globals.databaseName = applist[index].databasename!;
    globals.databaseId = applist[index].id.toString();
    await _getLeaveRole();
    await _getuserRole();
    await _changeRole();
    globals.isLoggedIn = true;
    sharedpref.setIntExtra("UserId", globals.userId);
    sharedpref.setBoolExtra("IsLoggedIn", true);
    sharedpref.setStringExtra("DatabaseName", globals.databaseName);
    alllogins = await DBProvider.db.getAllLoginProfile();
    LoginProfile lg = LoginProfile();
    lg.loginid = globals.userId;
    lg.appid = applist[index].id!;
    var appid = applist[index].appid;

    lg.databasename = globals.databaseName;
    lg.emaild = _username!.text;
    lg.isdefault = true;
    var firstlogin = alllogins.firstWhere(
        (element) => element.loginid == globals.userId,
        orElse: () => LoginProfile());
    if (firstlogin != null) {
      DBProvider.db.updateDefaultLogin(lg);
    } else {
      DBProvider.db.newLoginProfile(lg);
    }
    await _notificationTokenSubmit();

    if (appid == 2) {
      Get.offAll(() => const LandingPagepayroll());

      globals.payroll = 2;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 5) {
      Get.offAll(() => LandingPageLeave());
      globals.payroll = 5;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 29) {
      Get.offAll(() => const TaskandAttendance());

      globals.payroll = 29;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else if (appid == 27) {
      Get.offAll(() => const OnlyTaskManager());

      globals.payroll = 27;
      sharedpref.setIntExtra("payroll", globals.payroll);
    } else {
      Get.offAll(() => const FieldStaffTracker());

      globals.payroll = 28;
      sharedpref.setIntExtra("payroll", globals.payroll);
    }
  }

  Future _notificationTokenSubmit() async {
    String token = await SendNotification.getToken();
    String query =
        '${globals.applictionRootUrl}API/NotificationTokenSubmit?DBName=${globals.databaseName}&UserId=${globals.userId}&TokenId=$token';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      print("Token Submitted");
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _changecompanydropdownval(String val) {
    companydropdownValue = val;
    if (companydropdownValue != '') {
      Navigator.of(context, rootNavigator: true).pop();
      loadApplist();
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text('Application Selection'),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text("Select Company",
                                    style: TextStyle(color: Colors.blue[400]))),
                            DropdownButton<String>(
                              value: companydropdownValue,
                              isExpanded: true,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.blue,
                              ),
                              items: companyDropdownitems,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _changecompanydropdownval(newValue!);
                                  companydropdownValue = newValue;
                                });
                              },
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Text("Select App",
                                    style: TextStyle(color: Colors.blue[400]))),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 100.0 * applist.length,
                            width: 200,
                            constraints: const BoxConstraints(
                                minHeight: 10, maxHeight: 300),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: applist.length,
                                itemBuilder: (context, index) {
                                  if (applist.isNotEmpty) {
                                    return Container(
                                        child:
                                            _buildItem(applist[index], index));
                                  } else {
                                    return Container(
                                      child: const Text("No Apps"),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildItem(AppListModel app, [int? index]) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 0.0),
      key: ValueKey<AppListModel>(app),
      title: Text(app.appname!),
      dense: false,
      trailing: IconButton(
        icon: const Icon(Icons.exit_to_app, color: Colors.blue),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          openApp(index!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: const Color(0xFFfafafa),
    ));

    var optionRowUserIcon = Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.person),
          color: Colors.blue[800],
          onPressed: () {},
        ),
        Text("Email ID",
            style:
                TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w700))
      ],
    );
    var optionRowPwdIcon = Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.verified_user),
          color: Colors.blue[800],
          onPressed: () {},
        ),
        Text("Password",
            style:
                TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w700))
      ],
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFfafafa),
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFfafafa)),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 10.0),
                  child: Image.asset('assets/office_anywhere_logo_black.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                AutofillGroup(
                    child: Column(children: [
                  optionRowUserIcon,
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(0, 0),
                          spreadRadius: -20,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      controller: _username,
                      obscureText: false,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000912),
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: Colors.grey,
                          onPressed: _username!.clear,
                          icon: const Icon(
                            Icons.clear,
                            size: 14,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                        hintText: "Email Id",
                        hintStyle: const TextStyle(
                          color: Color(0xffA6B0BD),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.person_outline,
                            size: 25, color: Color(0xffA6B0BD)),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 50,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  optionRowPwdIcon,
                  Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(0, 0),
                          spreadRadius: -30,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: const [AutofillHints.password],
                      onEditingComplete: () =>
                          TextInput.finishAutofillContext(),
                      controller: _password,
                      obscureText: _showPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000912),
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: Colors.grey,
                          onPressed: _password!.clear,
                          icon: const Icon(
                            Icons.clear,
                            size: 15,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Color(0xffA6B0BD),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: Icon(
                              _showPassword
                                  ? Icons.lock_outline
                                  : Icons.lock_open,
                              size: 25,
                              color: const Color(0xffA6B0BD)),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 50,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ])),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onLongPress: () {
                              Fluttertoast.showToast(
                                  msg: "Click here to reset your password",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: const Color(0xffeeeeee),
                                  textColor: Colors.black,
                                  fontSize: 15.0);
                            },
                            onPressed: () async {
                              _launchForgotPasswordURL(context);
                            },
                            child: const Text(
                              "Forgot Password ?",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: SizedBox(
                    width: (_username!.text == "" || _password!.text == "") ||
                            !isdone
                        ? MediaQuery.of(context).size.width
                        : 50,
                    height: 70,
                    child: !isloading
                        ? Container(
                            width: 120,
                            margin: const EdgeInsets.only(top: 20, bottom: 0),
                            decoration: const BoxDecoration(
                                color: Color(0xff008FFF),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x60008FFF),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ]),
                            child: (_username!.text == "" ||
                                        _password!.text == "") ||
                                    !isdone
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      elevation: 0.0,
                                      // padding: const EdgeInsets.symmetric(
                                      //     vertical: 15),
                                    ),
                                    onPressed: () => {
                                          FocusScope.of(context).unfocus(),
                                          _login()
                                        },
                                    child: const Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 3,
                                      ),
                                    ))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      elevation: 0.0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                    onPressed: () => {
                                      FocusScope.of(context).unfocus(),
                                      _login()
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.done,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                          )
                        : Container(
                            width: 150,
                            margin: const EdgeInsets.only(top: 15, bottom: 0),
                            decoration: const BoxDecoration(
                                color: Color(0xff008FFF),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x60008FFF),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ]),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  elevation: 0.0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: () {},
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Please Wait...",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: Colors.white,
                                        ),
                                      )
                                    ]))),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height - 700),
                const Text(
                  "Create an account?",
                  style: TextStyle(
                    color: Color(0xffA6B0BD),
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                  ),
                  onPressed: () =>
                      {_launchURL(context), print("Sign up pressed.")},
                  child: const Text(
                    "SIGN UP NOW",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget smallbutton() {
  const color = Colors.indigo;
  return Container(
    decoration: const BoxDecoration(shape: BoxShape.circle, color: color),
    child: const CircularProgressIndicator(
      color: Colors.amber,
    ),
  );
}

_launchURL(BuildContext context) async {
  const url = 'https://officeanywhere.io/account/register';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Something Went Wrong")));
  }
}

_launchForgotPasswordURL(BuildContext context) async {
  const url = 'https://officeanywhere.io/account/forgotpassword';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Something Went Wrong")));
  }
}

class AppListModel {
  const AppListModel({this.appid, this.id, this.appname, this.databasename});
  final int? appid;
  final int? id;
  final String? appname;
  final String? databasename;
  factory AppListModel.fromJson(Map<String, dynamic> json) {
    return AppListModel(
      appid: json['AppId'] ?? "",
      id: json['DatabaseId'] ?? "",
      appname: json['AppDisplayName'] == null
          ? ""
          : json['AppDisplayName'].toString().trim(),
      databasename: json['DatabaseName'] == null
          ? ""
          : json['DatabaseName'].toString().trim(),
    );
  }
}
