import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

class AllDetailsCal extends StatefulWidget {
  const AllDetailsCal({Key? key}) : super(key: key);

  @override
  _AllDetailsCalState createState() => _AllDetailsCalState();
}

class _AllDetailsCalState extends State<AllDetailsCal>
    with TickerProviderStateMixin {
  final CalendarController _calendarControl = CalendarController();
  AnimationController? _animationController;
  Map<DateTime, List> _selecteddatetimeList = {};
  Map<DateTime, List> _selecteddatetimeListHoli = {};
  bool isLoaded = false;
  List<dynamic> dateTimeList = [];
  List<LeaveModel> maindateTimeList = [];
  List<HolidayModel> dateTimeListHoli = [];
  List<HolidayModel> maindateTimeListHoli = [];

  List<dynamic> jobject = [];
  List<dynamic> list = [];
  List<dynamic> jobject2 = [];
  List<dynamic> list2 = [];
  List<dynamic> mainList = [];
  List<dynamic> mainList2 = [];

  Map<DateTime, List<dynamic>> datlist = {};
  Map<DateTime, List<dynamic>> datlistholi = {};
  Map<DateTime, List> mapFetch = {};
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    _getHolidayLeaveData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _calendarControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildTableCalendarWithBuilders(),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
            // Expanded(child: _buildHoliList()),
          ],
        ),
      ),
    );
  }

  Future _getHolidayLeaveData() async {
    setState(() {
      isLoaded = false;
    });

    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/HolidayList?DBName=${globals.databaseName}&userId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    final http.Response responseleave = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/UpcomingLeaveList?DBName=${globals.databaseName}&UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final http.Response responseweekoff = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/WeekoffList?DBName=${globals.databaseName}&UserId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200 ||
        responseleave.statusCode == 200 ||
        responseweekoff.statusCode == 200) {
      jobject = jsonDecode(response.body.toString());

      list = jobject;
      print(list.length);
      mainList = list.map((e) => HolidayModel.fromJson(e)).toList();

      jobject2 = jsonDecode(responseleave.body.toString());
      list2 = (jobject2);

      var jobject3 = jsonDecode(responseweekoff.body.toString());
      var list3 = (jobject3);

      mainList2 = list2.map((e) => LeaveModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          dateTimeList = maindateTimeList = List<LeaveModel>.from(mainList2);
          dateTimeListHoli =
              maindateTimeListHoli = List<HolidayModel>.from(mainList);
          datlist = getTask(dateTimeList, dateTimeListHoli);
          _selecteddatetimeList = datlist;

          datlistholi = getTaskHoli(dateTimeListHoli);
          _selecteddatetimeListHoli = datlistholi;
          isLoaded = true;
        });
      }
    }
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'en_US',
      calendarController: _calendarControl,
      events: _selecteddatetimeList,
      holidays: _selecteddatetimeListHoli,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        eventDayStyle: const TextStyle().copyWith(color: Colors.red),
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
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController!),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 11.0, left: 12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber[500],
              ),
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: const TextStyle().copyWith(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
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
        markersBuilder: (context, dated, events, holidays) {
          final children = <Widget>[];
          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController!.forward(from: 0.0);
      },
    );
  }

  Widget _buildHolidaysMarker() {
    return const Icon(
      Icons.beach_access,
      size: 25.0,
      color: Colors.redAccent,
    );
  }

  Map<DateTime, List> getTask(List<dynamic> list, List<HolidayModel> list2) {
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].date] = [list[i].name];
    }

    for (int i = 0; i < list2.length; i++) {
      mapFetch[list2[i].date!] = [list2[i].name];
    }
    return mapFetch;
  }

  Map<DateTime, List> getTaskHoli(List<HolidayModel> list) {
    Map<DateTime, List> mapFetchHoli = {};

    for (int i = 0; i < list.length; i++) {
      mapFetchHoli[list[i].date!] = [list[i].name];
    }
    return mapFetchHoli;
  }

  void _onDaySelected(DateTime day, List events, List holi) {
    setState(() {
      if (events.isNotEmpty) {
        dateTimeList = [];
        dateTimeList.add(LeaveModel(date: day, name: events[0]));
        //dateTimeList.add(new HolidayModel(date: day, name: events[0]));
      } else {
        dateTimeList = [];
      }
      if (events.isNotEmpty) {
        dateTimeList = [];

        dateTimeList.add(HolidayModel(date: day, name: events[0]));
      } else {
        dateTimeList = [];
      }
    });
  }

  void showAllHolidays() {
    setState(() {
      dateTimeList = maindateTimeList;
    });
  }

  Widget _buildEventList() {
    return (dateTimeList.isNotEmpty)
        ? ListView(
            children: dateTimeList
                .map((event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          "${DateFormat('dd-MM-yyyy').format(event.date)}  -  " +
                              event.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ))
                .toList(),
          )
        : Text(
            "No Records Found".toUpperCase(),
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontFamily: "poppins-medium"),
          );
  }

  // Widget _buildHoliList() {
  //   var now = new DateTime.now();
  //   return dateTimeListHoli.length != 0
  //       ? ListView(
  //           children: dateTimeListHoli
  //               .map(
  //                 (event) => !clicked
  //                     ? (event.dated.compareTo(now) > 0)
  //                         ? Container(
  //                             decoration: BoxDecoration(
  //                               border:
  //                                   Border.all(width: 2, color: Colors.white),
  //                               borderRadius: BorderRadius.circular(12.0),
  //                             ),
  //                             margin: const EdgeInsets.symmetric(
  //                                 horizontal: 8.0, vertical: 4.0),
  //                             child: ListTile(
  //                               title: Text(
  //                                 DateFormat('dd-MM-yyyy').format(event.dated) +
  //                                     "  -  " +
  //                                     event.description,
  //                                 style: TextStyle(color: Colors.white),
  //                               ),
  //                               // onTap: () => print('$event tapped!'),
  //                             ),
  //                           )
  //                         : Container()
  //                     : Container(
  //                         decoration: BoxDecoration(
  //                           border: Border.all(width: 2, color: Colors.white),
  //                           borderRadius: BorderRadius.circular(12.0),
  //                         ),
  //                         margin: const EdgeInsets.symmetric(
  //                             horizontal: 8.0, vertical: 4.0),
  //                         child: ListTile(
  //                           title: Text(
  //                             DateFormat('dd-MM-yyyy').format(event.dated) +
  //                                 "  -  " +
  //                                 event.description,
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                           // onTap: () => print('$event tapped!'),
  //                         ),
  //                       ),
  //               )
  //               .toList(),
  //         )
  //       : Text(
  //           "No Records Found".toUpperCase(),
  //           style: TextStyle(
  //               color: Colors.white70,
  //               fontSize: 22,
  //               fontFamily: "poppins-medium"),
  //         );
  // }
}

class LeaveModel {
  LeaveModel({
    this.date,
    this.name,
  });

  final DateTime? date;
  final String? name;

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      name: json['empname'] ?? "",
      date: json['leavedate'] == null
          ? parseDateTime(json['leavedate'])
          : parseDateTime(json['leavedate']),
    );
  }
}

class HolidayModel {
  const HolidayModel({
    this.date,
    this.name,
  });
  final DateTime? date;
  final String? name;

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      date: json['Date'] == null
          ? parseDateTime(json['Date'])
          : parseDateTime(json['Date']),
      name: json['Description'] ?? "",
    );
  }
}

DateTime parseDateTime(String date) {
  DateFormat format = DateFormat("dd/MM/yyyy");
  return format.parse(date);
}
