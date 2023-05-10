import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'colors.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Map<DateTime, List> _selecteddatetimeListALl = {};
List<HolidayModel> dateTimeList = [];
List<HolidayModel> dateTimeListAll = [];
List<HolidayModel> dateTimeListNew = [];
List<HolidayModel> dateTimeListFT = [];
List<HolidayModel> dateTimeListMonth = [];
List<HolidayModel> maindateTimeList = [];
Map<DateTime, List<dynamic>>? showholidays;
bool clicked = false;
bool present = false;
bool isloaded = false;
bool swiped = false;

class UpcomimgHoliday extends StatefulWidget {
  const UpcomimgHoliday({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _TodayonLeaveState createState() => _TodayonLeaveState();
}

class _TodayonLeaveState extends State<UpcomimgHoliday>
    with TickerProviderStateMixin {
  bool isholi = false;
  int count = 0;
  String fromdate = "";
  String todate = "";
  AnimationController? _animationController;
  CalendarController? _calendarController;
  bool isLoaded = false;
  @override
  void initState() {
    clicked = false;
    super.initState();
    _getHolidayData();
    initializeDateFormatting();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _calendarController!.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    swiped = false;
    dateTimeFunction(day);
  }

  void showAllHolidays() {
    setState(() {
      dateTimeListNew = maindateTimeList;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    dateTimeFunction(_calendarController!.focusedDay);
  }

  dateTimeFunction(DateTime datetime) {
    setState(() {
      isholi = false;
      present = false;
      dateTimeListNew.clear();
      dateTimeListFT.clear();
    });
    for (int i = 0; i < dateTimeList.length; i++) {
      if (dateTimeList[i].dated!.month == (datetime.month) &&
          (dateTimeList[i].dated!.year == datetime.year)) {
        dateTimeListNew.add(HolidayModel(
            dated: dateTimeList[i].dated,
            description: dateTimeList[i].description));
      }
      dateTimeListNew.sort((a, b) => a.dated!.compareTo(b.dated!));

      if ((dateTimeList[i].dated!.year == (datetime.year))) {
        isholi = true;
        dateTimeListFT.add(dateTimeList[i]);
      }
    }
    dateTimeListFT.sort((a, b) => a.dated!.compareTo(b.dated!));
    if (isholi && dateTimeListFT.isNotEmpty) {
      count = dateTimeListFT.length;
      if (dateTimeListFT.length == 1) {
        fromdate = DateFormat('dd-MM-yyyy').format(dateTimeListFT[0].dated!);
      } else {
        fromdate = DateFormat('dd-MM-yyyy').format(dateTimeListFT[0].dated!);
        todate = DateFormat('dd-MM-yyyy')
            .format(dateTimeListFT[dateTimeListFT.length - 1].dated!);
      }
    } else {
      count = 0;
    }
    setState(() {});
  }

  Future _getHolidayData() async {
    setState(() {
      dateTimeList.clear();
      dateTimeListAll.clear();
      maindateTimeList.clear();
      dateTimeListFT.clear();
      isLoaded = false;
    });
    final http.Response response = await http.post(
      Uri.parse(
          '${globals.applictionRootUrl}API/HolidayList?DBName=${globals.databaseName}&userId=${globals.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject;
      var mainList = list.map((e) => HolidayModel.fromJson(e)).toList();

      if (mounted) {
        dateTimeList = maindateTimeList = List<HolidayModel>.from(mainList);

        dateTimeListAll = List<HolidayModel>.from(mainList);

        for (int i = 0; i < dateTimeList.length; i++) {
          if ((dateTimeList[i].dated!.year ==
              _calendarController!.focusedDay.year)) {
            if (dateTimeList[i].dated!.month ==
                (_calendarController!.focusedDay.month)) {
              dateTimeListNew.add(dateTimeList[i]);
              dateTimeListMonth.add(dateTimeList[i]);
            }
          }

          if ((dateTimeList[i].dated!.year == DateTime.now().year)) {
            isholi = true;
            dateTimeListFT.add(dateTimeList[i]);
          }
        }

        dateTimeListNew.sort((a, b) => a.dated!.compareTo(b.dated!));
        maindateTimeList = dateTimeListNew;
        var datlist = getTask(dateTimeListNew);
        var datlistAll = getTask(dateTimeListAll);
        showholidays = datlist;
        _selecteddatetimeListALl = datlistAll;
        isLoaded = true;
        dateTimeListFT.sort((a, b) => a.dated!.compareTo(b.dated!));
        if (isholi && dateTimeListFT.isNotEmpty) {
          count = dateTimeListFT.length;
          if (dateTimeListFT.length == 1) {
            fromdate =
                DateFormat('dd-MM-yyyy').format(dateTimeListFT[0].dated!);
          } else {
            fromdate =
                DateFormat('dd-MM-yyyy').format(dateTimeListFT[0].dated!);
            todate = DateFormat('dd-MM-yyyy')
                .format(dateTimeListFT[dateTimeListFT.length - 1].dated!);
          }
        }
        setState(() {});
      }
    }
  }

  Map<DateTime, List> getTask(List<HolidayModel> list) {
    Map<DateTime, List> mapFetch = {};
    for (int i = 0; i < list.length; i++) {
      mapFetch[list[i].dated!] = [list[i].description];
    }
    return mapFetch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appbarcolor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Holidays Details",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Poppins-Medium",
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: dashBoardColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTableCalendarWithBuilders(),
              const SizedBox(height: 8.0),
              !isLoaded
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
                  : Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildButtons(),
                          const SizedBox(height: 8.0),
                          Expanded(child: _buildEventList()),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? getStartDate;

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'en_US',
      calendarController: _calendarController,
      events: _selecteddatetimeListALl,
      holidays: _selecteddatetimeListALl,
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
        _onDaySelected(date, events);
        _animationController!.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.beach_access,
      size: 25.0,
      color: Colors.red[500],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Text(
          isholi || dateTimeListFT.isNotEmpty
              ? "${" Holidays".toUpperCase()}[$count]"
              : "",
          style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 3),
        ),
        const SizedBox(height: 2.0),
        !globals.isEmployee && (isholi && dateTimeListFT.isNotEmpty)
            ? Text(
                "$fromdate  $todate",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              )
            : const Text(""),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildEventList() {
    return dateTimeListNew.isNotEmpty
        ? ListView(
            children: dateTimeListNew
                .map((event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          "${DateFormat('dd-MM-yyyy').format(event.dated!)}  -  ${event.description}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        // onTap: () => print('$event tapped!'),
                      ),
                    ))
                .toList(),
          )
        : Text(
            (!isholi)
                ? "Holidays Are Not Set".toUpperCase()
                : swiped
                    ? ""
                    : present
                        ? "No Holiday For This Day"
                        : "No Holidays In This Month",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: "poppins-medium"),
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

DateTime parseDateTime(String date) {
  DateFormat format = DateFormat("dd/MM/yyyy");
  return format.parse(date);
}
