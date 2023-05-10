import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/get_employee.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart' as dateformat;

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  CalendarController? _calendarController;
  AnimationController? _animationController;
  var mainEmployeeList = [];

  List<WeekOffModel> dateTimeListWeekoff = [];
  List<HolidayModel> dateTimeListholiday = [];
  List<LeaveModel> dateTimeListleave = [];
  List<ExtraWorkModel> dateTimeListextrawork = [];

  List<WeekOffModel> dateTimeListWeekoffNew = [];
  List<HolidayModel> dateTimeListholidayNew = [];
  List<LeaveModel> dateTimeListleaveNew = [];
  List<ExtraWorkModel> dateTimeListextraworkNew = [];
  final Map<DateTime, List> _selecteddatetimeList = {};
  Map<DateTime, List> datlistholiday = {};
  Map<DateTime, List> datlist2weekoff = {};
  Map<DateTime, List> datlist3leave = {};
  Map<DateTime, List> datlist4extrawork = {};
  bool isclicked = false;
  bool isholidayclicked = false;
  bool isweekoffclicked = false;
  bool isleaveclicked = false;
  bool isextraworkclicked = false;
  bool isloaded = false;
  Color? colorSet;
  @override
  void initState() {
    _getLeaveData();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      if (datlistholiday.isNotEmpty) {
        dateTimeListholidayNew = [];
        for (int i = 0; i < dateTimeListholiday.length; i++) {
          if ((DateFormat('dd-MM-yyyy').format(dateTimeListholiday[i].dated!) ==
              DateFormat('dd-MM-yyyy').format(day))) {
            dateTimeListholidayNew.add(HolidayModel(
                dated: day, description: dateTimeListholiday[i].description));
          }
        }
      }

      dateTimeListWeekoffNew = [];
      if (datlist2weekoff.isNotEmpty) {
        for (int i = 0; i < dateTimeListWeekoff.length; i++) {
          if ((DateFormat('dd-MM-yyyy').format(dateTimeListWeekoff[i].date!) ==
              DateFormat('dd-MM-yyyy').format(day))) {
            dateTimeListWeekoffNew.add(WeekOffModel(
                date: day, description: dateTimeListWeekoff[i].description));
          }
        }
      }

      dateTimeListleaveNew = [];
      if (datlist3leave.isNotEmpty) {
        for (int i = 0; i < dateTimeListleave.length; i++) {
          if ((DateFormat('dd-MM-yyyy')
                  .format(dateTimeListleave[i].leavedate!) ==
              DateFormat('dd-MM-yyyy').format(day))) {
            dateTimeListleaveNew.add(LeaveModel(
                leavedate: day,
                description: dateTimeListleave[i].description,
                leavecode: dateTimeListleave[i].leavecode));
          }
        }
      }

      dateTimeListextraworkNew = [];
      if (datlist4extrawork.isNotEmpty) {
        for (int i = 0; i < dateTimeListextrawork.length; i++) {
          if ((DateFormat('dd-MM-yyyy')
                  .format(dateTimeListextrawork[i].fromdate!) ==
              DateFormat('dd-MM-yyyy').format(day))) {
            dateTimeListextraworkNew.add(ExtraWorkModel(
                fromdate: day,
                description: dateTimeListextrawork[i].description));
          }
        }
      }
    });
  }

  Future<void> _getEmployeeDetails() async {
    mainEmployeeList = await GetEmployee().getEmployeeData();
    setState(() {});
  }

  Future _getLeaveData() async {
    await _getEmployeeDetails();
    setState(() {
      isloaded = false;
    });

    _selecteddatetimeList.clear();
    //  CalenderViewData(string DBName, int UserId,int EmpId)
    String empid = "";
    try {
      empid =
          "${mainEmployeeList.where((element) => element.userid == globals.userId).toList()[0].empid}";
    } catch (e) {
      empid = "${globals.userId}";
    }
    final http.Response response = await http.post(
      Uri.parse(globals.applictionRootUrl +
          'API/CalenderViewData?DBName=' +
          globals.databaseName +
          '&UserId=' +
          globals.userId.toString() +
          "&EmpId=" +
          empid),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var listofweekoff = jobject['Weekoffresult'];
      var listofholidays = jobject['Holidayresult'];
      var listofleave = jobject['LeaveDetails']['EmployeeLeaveDetailsList'];
      var listofextrawork =
          jobject['ExtraWorkDetails']['ExtraWorkingSearchList'];
      var mainListofWeakoff =
          listofweekoff.map((e) => WeekOffModel.fromJson(e)).toList();
      var mainListHolidays =
          listofholidays.map((e) => HolidayModel.fromJson(e)).toList();
      var mainListLeave =
          listofleave.map((e) => LeaveModel.fromJson(e)).toList();
      var mainListExtrawork =
          listofextrawork.map((e) => ExtraWorkModel.fromJson(e)).toList();

      // setState(() {
      dateTimeListWeekoff = List<WeekOffModel>.from(mainListofWeakoff);
      dateTimeListholiday = List<HolidayModel>.from(mainListHolidays);
      dateTimeListleave = List<LeaveModel>.from(mainListLeave);
      dateTimeListextrawork = List<ExtraWorkModel>.from(mainListExtrawork);

      final idsLeave = <dynamic>{};
      dateTimeListleave.retainWhere((x) => idsLeave.add(x.leavedate));

      final idsHoliday = <dynamic>{};
      dateTimeListholiday.retainWhere((x) => idsHoliday.add(x.dated));

      final idsWeekoff = <dynamic>{};
      dateTimeListWeekoff.retainWhere((x) => idsWeekoff.add(x.date));

      final idsextrawork = <dynamic>{};
      dateTimeListextrawork.retainWhere((x) => idsextrawork.add(x.fromdate));

      datlistholiday = getTask(dateTimeListholiday);
      datlist2weekoff = getTask2(dateTimeListWeekoff);
      datlist3leave = getTask3(dateTimeListleave);
      datlist4extrawork = getTask4(dateTimeListextrawork);

      _selecteddatetimeList.addAll(datlistholiday);
      _selecteddatetimeList.addAll(datlist2weekoff);
      _selecteddatetimeList.addAll(datlist3leave);
      _selecteddatetimeList.addAll(datlist4extrawork);
      // });
    }
    setState(() {
      isloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(" Calendar View"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: AlertDialog(
                      backgroundColor: const Color(0xffeeeeee),
                      title: Center(
                          child: Column(
                        children: [
                          Row(children: const [
                            Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 15,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Holidays", style: TextStyle(fontSize: 18))
                          ]),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.yellow,
                                size: 15,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Leave", style: TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Extra Work", style: TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.indigo,
                                size: 15,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Week Off", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      )),
                    ),
                  );
                }),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blue,
          child: Column(
            //  mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTableCalendarWithBuilders(),
              const SizedBox(height: 15.0),
              !isloaded
                  ? Center(
                      child: Container(
                          height: 60,
                          width: 200,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xffeeeeee),
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("Loading...",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                                SizedBox(
                                  width: 20,
                                ),
                                CircularProgressIndicator(color: Colors.white)
                              ])))
                  : Row(),
              ListView(
                shrinkWrap: true,
                children: [
                  _buildEventListHoliday(),
                  _buildEventListWeekOff(),
                  _buildEventListLeave(),
                  _buildEventListExtraWork(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventListHoliday() {
    return ListView(
      shrinkWrap: true,
      children: dateTimeListholidayNew
          .toSet()
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    "${event.description} ${DateFormat('dd-MM-yyyy').format(event.dated!)}",
                    style: const TextStyle(color: Colors.white),
                  ),

                  // onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildEventListWeekOff() {
    return ListView(
      shrinkWrap: true,
      children: dateTimeListWeekoffNew
          .toSet()
          .map((event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.indigo),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
              child: ListTile(
                title: Text(
                  DateFormat('dd-MM-yyyy').format(event.date!),
                  style: const TextStyle(color: Colors.white),
                ),
              )))
          .toList(),
    );
  }

  Widget _buildEventListLeave() {
    return ListView(
      shrinkWrap: true,
      children: dateTimeListleaveNew
          .toSet()
          .map((event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.yellow),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
              child: ListTile(
                title: Text(
                  "${event.description}  (${event.leavecode})   -  ${DateFormat('dd-MM-yyyy').format(event.leavedate!)}",
                  style: const TextStyle(color: Colors.white),
                ),
              )))
          .toList(),
    );
  }

  Widget _buildEventListExtraWork() {
    return ListView(
      shrinkWrap: true,
      children: dateTimeListextraworkNew
          .toSet()
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    "${event.description} ${DateFormat('dd-MM-yyyy').format(event.fromdate!)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'en_US',
      calendarController: _calendarController,
      events: _selecteddatetimeList,
      holidays: _selecteddatetimeList,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekdayStyle: const TextStyle().copyWith(color: Colors.white),
        weekendStyle: const TextStyle().copyWith(color: Colors.grey),
        holidayStyle: const TextStyle().copyWith(color: Colors.white),
        outsideWeekendStyle: const TextStyle().copyWith(color: Colors.grey),
        outsideStyle: const TextStyle().copyWith(color: Colors.grey),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: const TextStyle().copyWith(color: Colors.white),
        weekendStyle: const TextStyle().copyWith(color: Colors.white),
      ),
      headerStyle: const HeaderStyle(
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white60),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white60),
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 11.0, left: 12.0),
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(29, 209, 161, 1.0),
            ),
            child: Text(
              '${date.day}',
              style: const TextStyle().copyWith(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          );
        },
        markersBuilder: (context, dates, events, holidays) {
          final children = <Widget>[];
          if (datlistholiday.isNotEmpty) {
            for (int i = 0; i < dateTimeListholiday.length; i++) {
              if ((DateFormat('dd-MM-yyyy')
                      .format(dateTimeListholiday[i].dated!) ==
                  DateFormat('dd-MM-yyyy').format(dates))) {
                children.add(
                  Positioned(
                    right: 5,
                    top: 5,
                    child: _buildEventsMarker(
                        dateTimeListholiday[i].dated!, "holi"),
                  ),
                );
              }
            }
          }

          if (datlist3leave.isNotEmpty) {
            for (int i = 0; i < dateTimeListleave.length; i++) {
              if ((DateFormat('dd-MM-yyyy')
                      .format(dateTimeListleave[i].leavedate!) ==
                  DateFormat('dd-MM-yyyy').format(dates))) {
                children.add(
                  Positioned(
                    right: 5,
                    top: 15,
                    child: _buildEventsMarker(
                        dateTimeListleave[i].leavedate!, "leave"),
                  ),
                );
              }
            }
          }
          if (datlist4extrawork.isNotEmpty) {
            for (int i = 0; i < dateTimeListextrawork.length; i++) {
              if ((DateFormat('dd-MM-yyyy')
                      .format(dateTimeListextrawork[i].fromdate!) ==
                  DateFormat('dd-MM-yyyy').format(dates))) {
                children.add(
                  Positioned(
                    right: 5,
                    top: 20,
                    child: _buildEventsMarker(
                        dateTimeListextrawork[i].fromdate!, "extra"),
                  ),
                );
              }
            }
          }

          if (datlist2weekoff.isNotEmpty) {
            for (int i = 0; i < dateTimeListWeekoff.length; i++) {
              if ((DateFormat('dd-MM-yyyy')
                      .format(dateTimeListWeekoff[i].date!) ==
                  DateFormat('dd-MM-yyyy').format(dates))) {
                children.add(
                  Positioned(
                    right: 5,
                    top: 30,
                    child: _buildEventsMarker(
                        dateTimeListWeekoff[i].date!, "week"),
                  ),
                );
              }
            }
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events);
        _animationController!.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, String eleName) {
    Color col;
    if (eleName == "holi") {
      col = Colors.red;
    } else if (eleName == "leave") {
      col = Colors.amber;
    } else if (eleName == "extra") {
      col = Colors.white;
    } else {
      col = Colors.indigo;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: col,
      ),
      width: 8.0,
      height: 8.0,
    );
  }

  Map<DateTime, List> getTask(List<HolidayModel> list) {
    Map<DateTime, List> mapFetch = {};
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].dated!] = [list[i].description];
    }
    return mapFetch;
  }

  Map<DateTime, List> getTask2(List<WeekOffModel> list) {
    Map<DateTime, List> mapFetch = {};
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].date!] = [list[i].description];
    }
    return mapFetch;
  }

  Map<DateTime, List> getTask3(List<LeaveModel> list) {
    Map<DateTime, List> mapFetch = {};
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].leavedate!] = [list[i].description];
    }
    return mapFetch;
  }

  Map<DateTime, List> getTask4(List<ExtraWorkModel> list) {
    Map<DateTime, List> mapFetch = {};
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].fromdate!] = [list[i].description];
    }
    return mapFetch;
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    setState(() {
      dateTimeListholidayNew = [];
      dateTimeListWeekoffNew = [];
      dateTimeListleaveNew = [];
      dateTimeListextraworkNew = [];
    });
  }
}

class WeekOffModel {
  const WeekOffModel({
    this.date,
    this.description,
  });

  final DateTime? date;
  final String? description;
  factory WeekOffModel.fromJson(Map<String, dynamic> json) {
    return WeekOffModel(
      date: json['WeeklyoffDate'] == null
          ? DateTime.now()
          : parseDateTime(json['WeeklyoffDate']),
      description: json['leavedate'] ?? "",
    );
  }
}

class HolidayModel {
  const HolidayModel({
    this.dated,
    this.description,
  });
  final DateTime? dated;
  final String? description;

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      dated:
          json['Date'] == null ? DateTime.now() : parseDateTime(json['Date']),
      description: json['Description'] ?? "",
    );
  }
}

class LeaveModel {
  const LeaveModel({this.leavedate, this.description, this.leavecode});
  final DateTime? leavedate;
  final String? description;
  final String? leavecode;
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
        leavedate: json['fromdate'] == null
            ? DateTime.now()
            : parseDateTime(getdatefrommilisec(json['fromdate'])),
        description: json['empname'] ?? "",
        leavecode: json['leavecode'] ?? "");
  }
}

class ExtraWorkModel {
  const ExtraWorkModel({
    this.fromdate,
    this.description,
  });
  final DateTime? fromdate;
  final String? description;

  factory ExtraWorkModel.fromJson(Map<String, dynamic> json) {
    return ExtraWorkModel(
      fromdate: json['fromdate'] == null
          ? DateTime.now()
          : parseDateTime(getdatefrommilisec(json['fromdate'])),
      description: json['empname'] ?? "",
    );
  }
}

String getdatefrommilisec(String date) {
  var oDate = int.tryParse(date.toString().split('(')[1].split(')')[0]);
  var orDate = DateTime.fromMillisecondsSinceEpoch(oDate!);
  String orderDate = dateformat.DateFormat("dd/MM/yyyy").format(orDate);
  return orderDate;
}

DateTime parseDateTime(String date) {
  DateFormat format = DateFormat("dd/MM/yyyy");
  return format.parse(date);
}
