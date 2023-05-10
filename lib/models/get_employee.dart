import 'dart:convert';
import 'dart:async';
import '../screens/globals.dart' as globals;
import 'package:http/http.dart' as http;

class GetEmployee {
  List<EmployeeId> mainEmployeeList = [];
  Future<List<EmployeeId>> getEmployeeData() async {
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
      mainEmployeeList = List<EmployeeId>.from(mainList);
    }
    return mainEmployeeList;
  }
}

class EmployeeId {
  EmployeeId({this.empid, this.userid, this.empname});
  int? empid;
  int? userid;
  String? empname;
  factory EmployeeId.fromJson(Map<String, dynamic> json) {
    return EmployeeId(
        empid: json['EmpID'] ?? 0,
        userid: json['UserID'] ?? 0,
        empname: json['EmpName'] ?? "");
  }
}
