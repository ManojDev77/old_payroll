/// ClientModel.dart
import 'dart:convert';

LoginProfile loginProfileFromJson(String str) {
  final jsonData = json.decode(str);
  return LoginProfile.fromMap(jsonData);
}

String loginProfileToJson(LoginProfile data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class LoginProfile {
  int? loginid;
  int? appid;
  String? emaild;
  String? databasename;
  bool? isdefault;

  LoginProfile({
    this.loginid,
    this.appid,
    this.emaild,
    this.databasename,
    this.isdefault,
  });

  factory LoginProfile.fromMap(Map<String, dynamic> json) => LoginProfile(
        loginid: json["loginid"],
        appid: json["appid"],
        emaild: json["emaild"],
        databasename: json["databasename"],
        isdefault: json["isdefault"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "loginid": loginid,
        "appid": appid,
        "emaild": emaild,
        "databasename": databasename,
        "isdefault": isdefault,
      };
}
