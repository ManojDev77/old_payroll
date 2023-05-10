import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../constants/style.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newcontroller;
  String empValue = "";
  List<DropdownMenuItem<String>> empList = [];
  var mainEmployeeList = [];
  List<EmployeeId> mainEmployeeListDetails = [];
  List<dynamic> empitem = [];
  List<LocationModel> _locationList = [];
  final List<Marker> _markers = <Marker>[];
  List<LatLng> latlong = [];
  final Set<Polygon> _polygon = HashSet<Polygon>();
  bool isLoaded = false;
  int empid = 0;
  @override
  initState() {
    super.initState();
    _getEmployeeData();
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long), zoom: 13, tilt: 50.0, bearing: 45.0)));
  }

  final CameraPosition _initialposition = const CameraPosition(
    bearing: 15,
    target: LatLng(30.677515, 76.74390),
    zoom: 10,
  );

  Future _getEmployeeData() async {
    empList.clear();
    mainEmployeeList.clear();
    setState(() {
      empList.add(const DropdownMenuItem(
        value: "",
        child: Text("Select"),
      ));
    });

    mainEmployeeList = await GetEmployee().getEmployeeData();

    if (mounted) {
      for (var item in mainEmployeeList) {
        empList.add(DropdownMenuItem(
            value: "${item.userid}", child: Text(item.empname)));
      }

      try {
        empid = mainEmployeeList
            .where((element) => element.userid == globals.userId)
            .toList()[0]
            .empid;
        empValue =
            "${mainEmployeeList.where((element) => element.userid == globals.userId).toList()[0].userid}";
      } catch (e) {
        empid = mainEmployeeList[0].empid;
        empValue = empList[1].value!;
      }
    }
    setState(() {});
    await _getEmployeeLogData();
  }

  Future _getEmployeeLogData() async {
    setState(() {
      isLoaded = true;
    });

    _markers.clear();
    _polygon.clear();
    String date;
    if (getdate() == "Select Date") {
      var currentDate = DateTime.now();
      date = DateFormat('yyyy-MM-dd').format(currentDate);
    } else {
      date = getdate().split('-').reversed.join("-");
    }
    empid = 0;

    empid = mainEmployeeList
        .where((element) => "${element.userid}" == empValue)
        .toList()[0]
        .empid;
    empValue =
        "${mainEmployeeList.where((element) => "${element.userid}" == empValue).toList()[0].userid}";

    String query = globals.applictionRootUrl +
        'API/GPSLogDetailsHistoryEmp?DBName=' +
        globals.databaseName +
        '&UserId=' +
        empValue +
        '&Date=' +
        date +
        "&Empid=" +
        "$empid";
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    _locationList.clear();
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => LocationModel.fromJson(e)).toList();
      _locationList = List<LocationModel>.from(mainList);
    }
    _markers.clear();
    latlong.clear();
    _polygon.clear();
    if (_locationList.isNotEmpty) {
      for (int i = 0; i < _locationList.length; i++) {
        _markers.add(Marker(
          markerId: MarkerId('$i'),
          position:
              LatLng(_locationList[i].latitude!, _locationList[i].longitude!),
        ));

        latlong.add(
            LatLng(_locationList[i].latitude!, _locationList[i].longitude!));
      }

      _polygon.add(
        Polygon(
          polygonId: const PolygonId("Poly"),
          points: latlong,
          fillColor: Colors.deepPurple,
          strokeWidth: 2,
          strokeColor: Colors.deepPurple,
        ),
      );
      if (_locationList.isNotEmpty) {
        _gotoLocation(_locationList[0].latitude!, _locationList[0].longitude!);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No Data Found")));
    }

    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ElevatedButton(
                onPressed: () {
                  datepicker(context);
                },
                child: Text("${getdate()}")),
            const SizedBox(
              width: 20,
            ),
            !globals.isEmployee
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Employee', style: ThemeText.pageHeaderBlack),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        hint: const Text("Employee"),
                        value: empValue,
                        elevation: 10,
                        style: ThemeText.text,
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            empValue = newValue!;
                            _markers.clear();
                            _polygon.clear();
                          });

                          _getEmployeeLogData();
                        },
                        items: empList,
                      ),
                    ],
                  )
                : Row(),
          ]),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.77,
        width: MediaQuery.of(context).size.width * 1.0,
        child: Stack(children: [
          GoogleMap(
            markers: _markers.map((e) => e).toSet(),
            polygons: _polygon.map((e) => e).toSet(),
            mapType: MapType.normal,
            initialCameraPosition: _initialposition,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              } else {
                newcontroller = controller;
              }
            },
          ),
          !isLoaded
              ? Center(
                  child: Card(
                      margin: const EdgeInsets.only(left: 80, right: 80),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 65,
                            ),
                            Text("Loading...",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.blue)),
                            SizedBox(
                              width: 20,
                            ),
                            CircularProgressIndicator(color: Colors.blue)
                          ])))
              : Row()
        ]),
      ),
    ])));
  }

  DateTime? date;
  getdate() {
    if (date == null) {
      return '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
    }
    return '${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}';
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
    _getEmployeeLogData();
  }

  String getemid(String id) {
    String idemp = "";

    for (int i = 0; i < mainEmployeeListDetails.length; i++) {
      if (mainEmployeeListDetails[i].userid.toString() == id) {
        idemp = mainEmployeeListDetails[i].empid.toString();

        return idemp;
      }
    }
    return idemp;
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

class LocationModel {
  const LocationModel({
    this.empname,
    this.loginstatus,
    this.loginoutdate,
    this.logininouttime,
    this.latitude,
    this.longitude,
    this.remark,
  });
  final String? empname;
  final String? loginstatus;
  final String? loginoutdate;
  final String? logininouttime;
  final double? latitude;
  final double? longitude;
  final String? remark;
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      empname: json['EmployeeName'] ?? "",
      loginstatus: json['Loginstatus'] ?? "",
      loginoutdate: json['LoginoutDate'] ?? "",
      logininouttime: json['LoginoutTime'] ?? "",
      latitude: json['lat'] == null ? 0 : json['lat'] + 0.0,
      longitude: json['longitude'] == null ? 0 : json['longitude'] + 0.0,
      remark: json['remark'] ?? "",
    );
  }
}
