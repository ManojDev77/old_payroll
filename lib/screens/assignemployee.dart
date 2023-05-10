import 'package:badges/badges.dart' as Badge;
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import '../constants/style.dart';
import 'apiattandtask.dart';
import 'dailyreportdelete.dart';
import 'dailyworkentry.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as extensionPath;
import 'package:progress_dialog/progress_dialog.dart';

class AssignEmployee extends StatefulWidget {
  final int? tabindex;
  final int? id;

  const AssignEmployee({Key? key, this.tabindex, this.id}) : super(key: key);

  @override
  _AssignEmployeeState createState() => _AssignEmployeeState();
}

class _AssignEmployeeState extends State<AssignEmployee>
    with TickerProviderStateMixin {
  ProgressDialog? pr;
  String widgetType = "Default";
  TabController? _tabController;
  List<AssignModel> mainTaskList = [];
  List<StatusModal> mainTaskList2 = [];
  List<AssignModel> mainTaskList3 = [];
  List<AssignModel> assignedTaskEmployee = [];
  List<InwardModel> mainDocList = [];
  List<String> creationitems = [];
  List<String> updatestatuslist = [];

  List<String> ids = [];
  List<String> names = [];
  List<Employee> _selectedemployee = [];
  File? existingfile;
  List<MultiSelectItem<Employee>> _items = [];
  static List<Employee> employyelist = [];
  List<DropdownMenuItem<String>> statusList = [];
  List<dynamic> statusitem = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();
  String? statusValue;
  String? valueitems2;
  bool notselected = true;
  bool isLoaded = false;
  bool isPendingClicked = false;
  bool isCompleteClicked = false;
  bool isDeliveryClicked = false;
  bool isVerifiedClicked = false;
  bool isBilledClicked = false;
  bool isCancelledClicked = false;
  bool isPostponedClicked = false;
  bool isHomeClicked = false;
  int taskregCnt = 0;

  int completedCnt = 0;
  int verifiedCnt = 0;
  int deliveredCnt = 0;
  int billedCnt = 0;
  int cancelledCnt = 0;
  int postCnt = 0;
  bool isisFileAttached = false;
  bool floatingVisbilityEnable = true;
  String fileNameNew = "Pick a file";
  final _formKey = GlobalKey<FormState>();
  final fileController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DateTime? date;
  DateTime? estcompdate;
  @override
  void initState() {
    pr = ProgressDialog(context, isDismissible: false);
    globals.tabid = 0;
    globals.taskidnew = "";
    globals.taskdate = "";
    globals.taskhours = 0.0;
    globals.taskremark = "";
    _requestSearchData();

    _tabController = TabController(length: 3, vsync: this);

    _tabController!.addListener(() {
      print(_tabController!.index);
      if (_tabController!.index == 1 || _tabController!.index == 2) {
        setState(() {
          floatingVisbilityEnable = false;
        });
      } else {
        setState(() {
          floatingVisbilityEnable = true;
        });
      }
    });

    super.initState();
  }

  getdate() {
    if (date == null) {
      return "Select Date";
    }
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  getestcompdate() {
    if (estcompdate == null) {
      return "Select Date";
    }
    return '${estcompdate!.day}/${estcompdate!.month}/${estcompdate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDialOpen = ValueNotifier(false);
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;

          return false;
        } else {
          return true;
        }
      },
      child: DefaultTabController(
          length: 3,
          child: !globals.isEmployee
              ? Scaffold(
                  backgroundColor: const Color(0xffeeeeee),
                  floatingActionButton: Visibility(
                    visible: floatingVisbilityEnable,
                    child: SpeedDial(
                      openCloseDial: isDialOpen,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.4,
                      buttonSize: const Size(45.0, 45.0),
                      animatedIcon: AnimatedIcons.menu_close,
                      children: [
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.home),
                            label: 'Home',
                            onTap: () {
                              setState(() {
                                isPendingClicked = false;
                                isCompleteClicked = false;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isBilledClicked = false;
                                isPostponedClicked = false;
                                isCancelledClicked = false;
                                isHomeClicked = true;
                              });
                            }),
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.hourglass_empty),
                            label: 'Pending',
                            onTap: () {
                              setState(() {
                                isHomeClicked = false;
                                isPendingClicked = true;
                                isCompleteClicked = false;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isBilledClicked = false;
                                isCancelledClicked = false;
                                isPostponedClicked = false;
                              });
                            }),
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.done),
                            label: 'Completed',
                            onTap: () {
                              setState(() {
                                isHomeClicked = false;
                                isPendingClicked = false;
                                isCompleteClicked = true;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isBilledClicked = false;
                                isCancelledClicked = false;
                                isPostponedClicked = false;
                              });
                            }),
                        !globals.isdirectbilling
                            ? SpeedDialChild(
                                labelStyle: ThemeText.text,
                                child: const Icon(Icons.mail),
                                label: 'Verified',
                                onTap: () {
                                  setState(() {
                                    isHomeClicked = false;
                                    isPendingClicked = false;
                                    isCompleteClicked = false;
                                    isDeliveryClicked = false;
                                    isVerifiedClicked = true;
                                    isDeliveryClicked = false;
                                    isBilledClicked = false;
                                    isCancelledClicked = false;
                                    isPostponedClicked = false;
                                  });
                                })
                            : SpeedDialChild(),
                        !globals.isdirectbilling
                            ? SpeedDialChild(
                                labelStyle: ThemeText.text,
                                child:
                                    const Icon(Icons.delivery_dining_rounded),
                                label: 'Delivered',
                                onTap: () {
                                  setState(() {
                                    isHomeClicked = false;
                                    isPendingClicked = false;
                                    isCompleteClicked = false;
                                    isDeliveryClicked = false;
                                    isVerifiedClicked = false;
                                    isDeliveryClicked = true;
                                    isBilledClicked = false;
                                    isCancelledClicked = false;
                                    isPostponedClicked = false;
                                  });
                                })
                            : SpeedDialChild(),
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.receipt_long),
                            label: 'Billed',
                            onTap: () {
                              setState(() {
                                isHomeClicked = false;
                                isPendingClicked = false;
                                isCompleteClicked = false;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isCancelledClicked = false;
                                isBilledClicked = true;
                                isPostponedClicked = false;
                              });
                            }),
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.post_add),
                            label: 'Postponed',
                            onTap: () {
                              setState(() {
                                isHomeClicked = false;
                                isPendingClicked = false;
                                isCompleteClicked = false;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isBilledClicked = false;
                                isCancelledClicked = false;
                                isPostponedClicked = true;
                              });
                            }),
                        SpeedDialChild(
                            labelStyle: ThemeText.text,
                            child: const Icon(Icons.cancel_rounded),
                            label: 'Cancelled',
                            onTap: () {
                              setState(() {
                                isHomeClicked = false;
                                isPendingClicked = false;

                                isCompleteClicked = false;
                                isDeliveryClicked = false;
                                isVerifiedClicked = false;
                                isDeliveryClicked = false;
                                isBilledClicked = false;
                                isCancelledClicked = true;
                                isPostponedClicked = false;
                              });
                            }),
                      ],
                    ),
                  ),
                  appBar: AppBar(
                    backgroundColor: Colors.blue,
                    centerTitle: true,
                    title: const Text(
                      "Task",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(
                          text: "Tasks",
                        ),
                        Tab(
                          text: "Work Entry",
                        ),
                        Tab(
                          text: "Entry Details",
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      !isLoaded
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              child: newTaskPage(),
                            ),
                      const DailyWorkEntry(),
                      DailyWorkReportDelete(
                        tabController: _tabController!,
                      ),
                    ],
                  ),
                )
              : Scaffold(
                  backgroundColor: const Color(0xffeeeeee),
                  appBar: AppBar(
                    backgroundColor: Colors.blue,
                    centerTitle: true,
                    title: const Text(
                      "Task",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(
                          text: "Tasks",
                        ),
                        Tab(
                          text: "Work Entry",
                        ),
                        Tab(
                          text: "Entry Details",
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      !isLoaded
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              child: newTaskPage(),
                            ),
                      const DailyWorkEntry(),
                      DailyWorkReportDelete(
                        tabController: _tabController!,
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget newTaskPage() {
    return ListView(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
              isPendingClicked
                  ? "Pending Task - $taskregCnt"
                  : isCompleteClicked
                      ? "Completed Task - $completedCnt"
                      : isVerifiedClicked
                          ? "Verified Task - $verifiedCnt"
                          : isDeliveryClicked
                              ? "Delivered Task - $deliveredCnt"
                              : isBilledClicked
                                  ? "Billed Task - $billedCnt"
                                  : isCancelledClicked
                                      ? "Cancelled Task - $cancelledCnt"
                                      : isPostponedClicked
                                          ? "Postponed Task - $postCnt"
                                          : isHomeClicked
                                              ? globals.isEmployee
                                                  ? "Assigned Task"
                                                  : " Task Register - $taskregCnt"
                                              : globals.isEmployee
                                                  ? "Assigned Task"
                                                  : "Task Register - $taskregCnt",
              style: ThemeText.pageHeaderBlue),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mainTaskList.length,
              itemBuilder: (context, index) {
                return mainTaskList[index].updatedtask ==
                        (isPendingClicked
                            ? "Pending"
                            : isCompleteClicked
                                ? "Completed"
                                : isVerifiedClicked
                                    ? "Verified"
                                    : isDeliveryClicked
                                        ? "Delivered"
                                        : isBilledClicked
                                            ? "Billed"
                                            : isCancelledClicked
                                                ? "Cancelled"
                                                : isPostponedClicked
                                                    ? "Postponed"
                                                    : isHomeClicked
                                                        ? "Pending"
                                                        : "Pending")
                    ? Stack(
                        children: <Widget>[
                          Card(
                              elevation: 2,
                              color: Colors.white,
                              // shadowColor: Colors.black54,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Text(
                                                    "Task Number",
                                                    style: ThemeText.text,
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: const [
                                                  Text("Task Name",
                                                      style: ThemeText.text)
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: const [
                                                  Text("Task Date",
                                                      style: ThemeText.text)
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: const [
                                                  Text("Client",
                                                      style: ThemeText.text)
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: const [
                                                  Text(
                                                      "Estimated Completion Date",
                                                      style: ThemeText.text)
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ]),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Flexible(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ": ${mainTaskList[index].taskNumber!.length > 20 ? mainTaskList[index].taskNumber!.substring(0, 18) : mainTaskList[index].taskNumber}",
                                                  style: ThemeText.text,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Text(
                                                    ": "
                                                    "${mainTaskList[index].taskName}",
                                                    style: ThemeText.text,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        ": ${mainTaskList[index].date}",
                                                        style: ThemeText.text)
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Text(
                                                    ": "
                                                    "${mainTaskList[index].clientname}",
                                                    style: ThemeText.text,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        ": ${mainTaskList[index].estcomp}",
                                                        style: ThemeText.text)
                                                  ],
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    (isPendingClicked ||
                                            isCancelledClicked ||
                                            isBilledClicked)
                                        ? Row()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                  onTap: () async {
                                                    (isCompleteClicked ||
                                                            isDeliveryClicked ||
                                                            isVerifiedClicked ||
                                                            isPostponedClicked)
                                                        ? _showMyDialogupdatestatus(
                                                            context,
                                                            mainTaskList[index]
                                                                .id!,
                                                            isPostponedClicked
                                                                ? "1"
                                                                : isDeliveryClicked
                                                                    ? "5"
                                                                    : isVerifiedClicked
                                                                        ? "4"
                                                                        : globals.isdirectbilling
                                                                            ? "5"
                                                                            : "3")
                                                        : _showMyDialogupdate(
                                                            context,
                                                            mainTaskList[index]
                                                                .id!,
                                                          );
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      Text("Update Status ",
                                                          style: ThemeText
                                                              .pageHeaderBlue),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Icon(Icons.update)
                                                    ],
                                                  )),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              (isCompleteClicked ||
                                                      isVerifiedClicked ||
                                                      isDeliveryClicked ||
                                                      isBilledClicked ||
                                                      isCancelledClicked ||
                                                      isPostponedClicked)
                                                  ? Row()
                                                  : !globals.isEmployee
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              content: const Text(
                                                                  "Loading..."),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0)),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ));

                                                            _showMyDialog(
                                                                mainTaskList[
                                                                        index]
                                                                    .id!,
                                                                "No");
                                                          },
                                                          child: Row(children: [
                                                            const Text(
                                                                "Assign Employee ",
                                                                style: ThemeText
                                                                    .pageHeaderBlue),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Badge.Badge(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                toAnimate:
                                                                    false,
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                badgeContent: Text(
                                                                    "${mainTaskList[index].empcount}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                                badgeColor:
                                                                    Colors.blue,
                                                                child: const Icon(
                                                                    Icons
                                                                        .people_alt,
                                                                    size: 25)),
                                                          ]),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () async {
                                                            _showMyDialog(
                                                                mainTaskList[
                                                                        index]
                                                                    .id!,
                                                                "Transfer");
                                                          },
                                                          child: Row(
                                                            children: const [
                                                              Text(
                                                                  "Transfer Task",
                                                                  style: ThemeText
                                                                      .pageHeaderBlue),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Icon(Icons
                                                                  .swap_horiz)
                                                            ],
                                                          )),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              )),
                          (!isCancelledClicked &&
                                  !isPendingClicked &&
                                  !isCompleteClicked &&
                                  !isDeliveryClicked &&
                                  !isVerifiedClicked &&
                                  !isDeliveryClicked &&
                                  !isBilledClicked &&
                                  !isPostponedClicked)
                              ? !globals.isEmployee
                                  ? Positioned(
                                      right: 10.0,
                                      top: 12,
                                      // bottom: 0.0,
                                      child: GestureDetector(
                                          child: Badge.Badge(
                                            badgeColor: Colors.blue,
                                            badgeContent: Text(
                                              "${mainTaskList[index].filecount}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                            child:
                                                const Icon(Icons.attach_file),
                                          ),
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text('Please wait...'),
                                              duration: Duration(seconds: 3),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ));
                                            if (!globals.isEmployee) {
                                              fileNameNew = "Pick a file";
                                            }
                                            inwardfiledetailsadmin(
                                                mainTaskList[index].id!);
                                          }),
                                    )
                                  : Row()
                              : Row(),
                        ],
                      )
                    : Row();
              },
            ),
          ),
        ),
      ],
    );
  }

  List<TableRow> createTable() {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        decoration: const BoxDecoration(
          color: Color(0xfffaebd7),
        ),
        children: <Widget>[
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  "Action",
                  textAlign: TextAlign.center,
                  style: ThemeText.pageHeaderBlack,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "File Name",
              textAlign: TextAlign.center,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "Uploaded File",
              textAlign: TextAlign.center,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
        ],
      ),
    );

    for (int i = 0; i < mainDocList.length; i++) {
      rows.add(TableRow(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                        child: const Icon(
                          Icons.delete,
                          size: 20,
                        ),
                        onTap: () {
                          showAlertDlgDeleteDoc(context, mainDocList[i].id!);
                        }),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                mainDocList[i].actualfilename!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: GestureDetector(
                            child: const Icon(
                              Icons.download,
                              size: 20,
                            ),
                            onTap: () {
                              showAlertDlgDownDoc(
                                  context,
                                  mainDocList[i].id!,
                                  mainDocList[i].docname!,
                                  mainDocList[i].actualfilename!);
                            }),
                      )
                    : Row(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                mainDocList[i].docname!,
                textAlign: TextAlign.start,
                style: ThemeText.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                mainDocList[i].actualfilename!,
                textAlign: TextAlign.start,
                style: ThemeText.text,
              ),
            ),
          ]));
    }
    return rows;
  }

  showAlertDlgDeleteDoc(BuildContext context, int id) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        deleteInWardFileDetails(id);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Alert!",
      ),
      content: const Text(
        "Are you sure to delete?",
      ),
      actions: [
        cancelButton,
        okButton,
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

  showAlertDlgDownDoc(
      BuildContext context, int id, String docname, String acutalfilename) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Download"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        downloadDocumentrequest(id, docname, acutalfilename);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Alert!",
      ),
      content: const Text(
        "Are you sure to download?",
      ),
      actions: [
        cancelButton,
        okButton,
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

  Widget buildSheetfile(int taskregid) => DraggableScrollableSheet(
      minChildSize: 0.3,
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      builder: (_, controller) => StatefulBuilder(builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ListView(
                  shrinkWrap: true,
                  controller: controller,
                  children: [
                    const Text(
                      "File Details",
                      style: ThemeText.pageHeaderBlue,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (!globals.isEmployee)
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: fileController,
                              decoration: const InputDecoration(
                                labelText: 'File Name*',
                              ),
                              validator: (String? value) {
                                return (value!.isEmpty
                                    ? 'File Name required'
                                    : null);
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      final form = _formKey.currentState;
                                      if (form!.validate()) {
                                        if (existingfile != null) {
                                          _uploadFile(
                                            existingfile!,
                                            taskregid,
                                            fileController.text,
                                          );
                                        } else {
                                          onlyFileNameUpload(
                                              fileController.text, taskregid);
                                        }
                                      }
                                    },
                                    child: const Text("Save")),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 230,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        pickFile(taskregid, state);
                                        //updated(state);
                                      },
                                      child: Text(fileNameNew,
                                          overflow: TextOverflow.clip)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    mainDocList.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Table(
                                border: TableBorder.all(color: Colors.grey),
                                columnWidths: const <int, TableColumnWidth>{
                                  0: IntrinsicColumnWidth(),
                                  1: FlexColumnWidth(),
                                  //2: FixedColumnWidth(64),
                                },
                                children: createTable()),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No Files Uploaded")),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          }));

  showInwardDialog(BuildContext context, AssignModel assignModel) async {
    var list = [];
    // await inwardfiledetailsadmin(assignModel.id);

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: list.isNotEmpty
          ? const Text("Inward File Details")
          : const Text(
              "No Files Added",
            ),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        // Center(
        //   child: IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.upload),
        //   ),
        // ),
        // Center(child: Text("Upload File")),
        ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(
                  "${i + 1}.  " + list[i].docname,
                  style: const TextStyle(fontSize: 20),
                ),
                onTap: () {}
                //  downloadDocumentrequest(list[i])
                ,
              );
            }),
      ]),
      actions: [
        okButton,
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

  Future<void> _showMyDialog(int tskid, String trans) async {
    if (!globals.isEmployee) {
      await assignedEmpList(tskid);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(trans == "Transfer" ? 'Transfer To' : 'Assign To',
              style: ThemeText.pageHeaderBlack),
          content: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultiSelectBottomSheetField<Employee>(
                buttonIcon: const Icon(Icons.people_alt),
                key: _multiSelectKey,
                initialChildSize: 0.7,
                maxChildSize: 0.95,
                title: const Text("Employee List"),
                buttonText: const Text("Select"),
                items: _items,
                searchable: true,
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "Required";
                  }
                  ids = values.map((e) => e.id!).toList();
                  names = values.map((e) => e.name!).toList();

                  return null;
                },
                onConfirm: (values) {
                  setState(() {
                    _selectedemployee = values;
                  });
                  _multiSelectKey.currentState!.validate();
                },
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    setState(() {
                      _selectedemployee.remove(item);
                    });
                    _multiSelectKey.currentState!.validate();
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (!globals.isEmployee)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Assigned Employee",
                        style: ThemeText.pageHeaderBlack),
                    const SizedBox(
                      height: 20,
                    ),
                    if (assignedTaskEmployee.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const <int, TableColumnWidth>{
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                            2: FixedColumnWidth(64),
                          },
                          children: createTableAssigned(tskid),
                        ),
                      )
                  ],
                ),
            ],
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
            TextButton(
              child: Text(trans == "Transfer" ? 'Transfer' : 'Assign'),
              onPressed: () async {
                if (_multiSelectKey.currentState!.validate()) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  await assignemployee(tskid, ids, trans);
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<TableRow> createTableAssigned(int taskid) {
    List<TableRow> rows = [];
    rows.add(
      const TableRow(
        decoration: BoxDecoration(
          color: Color(0xfffaebd7),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "Action",
              textAlign: TextAlign.center,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "Employee",
              textAlign: TextAlign.center,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "Status",
              textAlign: TextAlign.center,
              style: ThemeText.pageHeaderBlack,
            ),
          ),
        ],
      ),
    );

    for (int i = 0; i < assignedTaskEmployee.length; i++) {
      rows.add(TableRow(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          children: <Widget>[
            (assignedTaskEmployee[i].updatedtask != "Completed")
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: GestureDetector(
                          child: const Icon(
                            Icons.delete,
                            size: 20,
                          ),
                          onTap: () {
                            showAlertDlgDeleteEmp(context, taskid,
                                assignedTaskEmployee[i].empid!);
                          }),
                    ),
                  )
                : Row(),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                assignedTaskEmployee[i].employee!,
                textAlign: TextAlign.start,
                style: ThemeText.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                assignedTaskEmployee[i].updatedtask!,
                textAlign: TextAlign.start,
                style: ThemeText.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]));
    }
    return rows;
  }

  showAlertDlgDeleteEmp(BuildContext context, int taskid, String empid) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
        assignedEmpDelete(taskid, empid);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Alert!",
      ),
      content: const Text(
        "Are you sure to delete?",
        style: ThemeText.text,
      ),
      actions: [
        cancelButton,
        okButton,
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

  void add(setState, value) {
    setState(() {
      statusValue = value;
    });
  }

  Future<void> _showMyDialogupdate(BuildContext mcontect, int tskid) async {
    final formKey = GlobalKey<FormState>();
    return showDialog<void>(
        context: mcontect,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: SingleChildScrollView(
                  child: Form(
                key: formKey,
                child: Column(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        iconSize: 0.0,
                        isExpanded: true,
                        items: statusList,
                        onChanged: (value) {
                          setState(() {
                            statusValue = value;
                            add(setState, value);
                          });
                        },
                        value: statusValue,
                        validator: (values) {
                          if (values == null || values.isEmpty) {
                            return "Required";
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
                TextButton(
                  child: const Text('Update Status'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await updatestatus(tskid, statusValue!);
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future<void> _showMyDialogupdatestatus(
      BuildContext mcontect, int tskid, String updateid) async {
    return showDialog<void>(
        context: mcontect,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: Text(
                  "Are sure you want to ${updateid == "3" ? globals.isdirectbilling ? "Bill the task" : "Verify the task" : updateid == "1" ? "Reopen the task" : updateid == "5" ? "Bill the task" : "Deliver the task"}"),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () async {
                    await updatestatus(tskid, updateid);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
              ],
            );
          });
        });
  }

  DropdownMenuItem<String> buildmenuitems(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Future _requestSearchData() async {
    setState(() {
      statusList.clear();
      taskregCnt = 0;

      completedCnt = 0;
      verifiedCnt = 0;
      deliveredCnt = 0;
      billedCnt = 0;
      cancelledCnt = 0;
      postCnt = 0;

      isLoaded = false;
    });

    String query =
        '${globals.applictionRootUrl}API/TaskRegisterSearch?DBName=${globals.databaseName}&UserId=${globals.userId}';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var list = jobject["TaskRegisterList"];
      if (list.isNotEmpty) {
        var listtaskemp = jobject["TaskRegisterData"]["EmpIDList"];
        var list2 = jobject["TaskRegisterData"]["StatusIDList"];
        var mainList = list.map((e) => AssignModel.fromJson(e)).toList();
        var mainlisttaskemp =
            listtaskemp.map((e) => AssignModel.fromJson(e)).toList();
        var mainList2 = list2.map((e) => StatusModal.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            mainTaskList = List<AssignModel>.from(mainList);
            mainTaskList2 = List<StatusModal>.from(mainList2);
            mainTaskList3 = List<AssignModel>.from(mainlisttaskemp);

            taskregCnt = mainTaskList
                .where((element) => element.updatedtask == "Pending")
                .length;

            completedCnt = mainTaskList
                .where((element) => element.updatedtask == "Completed")
                .length;

            deliveredCnt = mainTaskList
                .where((element) => element.updatedtask == "Delivered")
                .length;

            verifiedCnt = mainTaskList
                .where((element) => element.updatedtask == "Verified")
                .length;

            billedCnt = mainTaskList
                .where((element) => element.updatedtask == "Billed")
                .length;

            cancelledCnt = mainTaskList
                .where((element) => element.updatedtask == "Cancelled")
                .length;

            postCnt = mainTaskList
                .where((element) => element.updatedtask == "Postponed")
                .length;

            statusitem = List.from(list2);
            statusList.add(const DropdownMenuItem(
              value: "",
              child: Text("Select"),
            ));

            for (var item in statusitem) {
              statusList.add(DropdownMenuItem(
                  value: item["Value"].toString(),
                  child: Text(item["Text"].toString())));
            }

            employyelist.clear();
            for (int i = 0; i < mainTaskList3.length; i++) {
              employyelist.addAll([
                Employee(
                    id: mainTaskList3[i].employeeid.toString(),
                    name: mainTaskList3[i].employeename)
              ]);
            }

            _items.clear();
            _items = employyelist
                .map((emp) => MultiSelectItem<Employee>(emp, emp.name!))
                .toList();

            statusValue = statusList[0].value;
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  Future<void> assignedEmpList(int taskid) async {
    //AssignedEmployeeToTask(string DBName, int UserId, int Id)
    String query = globals.applictionRootUrl +
        'API/AssignedEmployeeToTask?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        "&Id=" +
        "$taskid";
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var empList = jobject['TaskRegisterList'];
      var mainList = empList.map((e) => AssignModel.fromJson(e)).toList();
      assignedTaskEmployee = List<AssignModel>.from(mainList);
      for (int i = 0; i < assignedTaskEmployee.length; i++) {
        _items.removeWhere(
            (element) => element.label == assignedTaskEmployee[i].employee);
      }
    }
  }

  Future<void> assignedEmpDelete(int taskid, String empid) async {
    pr?.style(
        message: 'Deleting Employee...',
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));
    pr?.show();
    //DeleteAssignEmployeeToTask(string DBName, int UserId, int Id, int Empid)
    String query = globals.applictionRootUrl +
        'API/DeleteAssignEmployeeToTask?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        "&Id=" +
        "$taskid" +
        "&Empid=" +
        empid;
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body.toString());
      var result = jobject;
      if (result) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Employee Deleted"),
          duration: const Duration(seconds: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    _requestSearchData();

    pr?.hide();
  }

  Future<void> inwardfiledetailsadmin(int id) async {
    String query =
        '${globals.applictionRootUrl}API/InWardFileDetails?DBName=${globals.databaseName}&UserId=${globals.userId}&TaskRegID=$id';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      var jobjlist = jsonDecode(response.body);
      var list = jobjlist["InWardFileDetailsList"];
      var mainList = list.map((e) => InwardModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          mainDocList = List<InwardModel>.from(mainList);
        });

        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(60))),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => buildSheetfile(id));
      }
    }
  }

  Future<void> assignemployee(int id, List<String> idsemp, String trans) async {
    //TransferEmployee(string DBName, int UserId, int TaskRegId, int Empid)

    pr?.style(
        message:
            trans != "Transfer" ? 'Assigning Employee...' : 'Transferring task',
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));
    pr?.show();

    http.Response? response;
    for (int i = 0; i < idsemp.length; i++) {
      String query =
          '${globals.applictionRootUrl}${trans == "Transfer" ? 'API/TransferEmployee?DBName=' : 'API/AssignEmployee?DBName='}${globals.databaseName}&UserId=${globals.userId}&TaskRegId=$id&Empid=${idsemp[i]}';
      response = await http.post(
        Uri.parse(query),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
    }
    if (response!.statusCode == 200) {
      var objlist = jsonDecode(response.body);
      bool result = trans == "Transfer" ? objlist : objlist['result'];
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(trans == "Transfer"
              ? "Task Transferred Successfully"
              : "Employee Assigned Successfully"),
          duration: const Duration(seconds: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          behavior: SnackBarBehavior.floating,
        ));
        _requestSearchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${objlist['msg']}"),
          duration: const Duration(seconds: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }

    pr?.hide();
  }

  Future<void> updatestatus(int id, String status) async {
    String query =
        '${globals.applictionRootUrl}API/UpdateStatus?DBName=${globals.databaseName}&UserId=${globals.userId}&TaskRegId=$id&Status=$status';
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Status Updated"),
        duration: const Duration(seconds: 1),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        behavior: SnackBarBehavior.floating,
      ));
      _requestSearchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Something Went Wrong"),
        duration: const Duration(seconds: 1),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        behavior: SnackBarBehavior.floating,
      ));
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

  //DeleteInWardFileDetails(string DBName, int UserId, int Id)
  Future<void> deleteInWardFileDetails(int id) async {
    Navigator.pop(context);

    String query = globals.applictionRootUrl +
        'API/DeleteInWardFileDetails?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&Id=' +
        "$id";

    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      //mainDocList.removeWhere((element) => element.id == id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('File deleted sucessfully'),
        duration: Duration(seconds: 2),
      ));
      _requestSearchData();
    }
  }

  Future downloadDocumentrequest(
      int id, String docname, String acutalfilename) async {
    Directory appDocDirectory;
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        appDocDirectory = (await getExternalStorageDirectory())!;
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
    Navigator.pop(context);
    pr?.style(
        message: 'Downloading...',
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));
    pr?.show();

    var dateTime = DateFormat('yyyy-MM-ddHH:mm:ss').format(DateTime.now());
    final extension = extensionPath.extension(acutalfilename);

    var filename = docname + dateTime;

    File saveFile = File("/storage/emulated/0/Download/$filename$extension");

    String query = globals.applictionRootUrl +
        'API/DownloadDocumentView?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&Id=' +
        "$id" +
        '&doc=' +
        docname;
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      var jobject = jsonDecode(response.body);
      var data = jobject;

      saveFile.writeAsBytes(data['bytes'].cast<int>());

      pr?.hide();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Download Completed '),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFile.open(saveFile.path);
            },
          )));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> updated(StateSetter updateState) async {
    updateState(() {
      fileNameNew = existingfile!.path.split('/').last;
    });
  }

  void pickFile(int tskid, StateSetter updateState) async {
    var result = await FlutterDocumentPicker.openDocument(
        params: FlutterDocumentPickerParams());

    if (result != null) {
      setState(() {
        isisFileAttached = true;
      });

      existingfile = File(result);
      updateState(() {
        fileNameNew = existingfile!.path.split('/').last;
      });

      //_uploadFile(existingfile, tskid, fileController.text);
    }
  }

  Future _uploadFile(File taskFile, int tskid, String filename) async {
    try {
      var response = await ApiAttandTask.putFile(
          '${globals.applictionRootUrl}API/InWardFileDetailsSave',
          taskFile,
          tskid,
          filename);

      if (response.statusCode == 200) {
        fileNameNew = "Pick a file";
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File Uploaded Successfully!")));

        fileController.clear();
        existingfile = null;
        _requestSearchData();
      } else {
        fileNameNew = "Pick a file";
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Upload Failed!")));
        fileController.clear();
        existingfile = null;
      }
    } catch (exception) {
      return null;
    }
  }

  Future<void> onlyFileNameUpload(String fileName, int taskid) async {
    //InWardFileDetailsSave(string DBName, int UserId,string FileName, int TaskRegID)
    String query = globals.applictionRootUrl +
        'API/InWardFileDetailsSave?DBName=' +
        globals.databaseName +
        '&UserId=' +
        globals.userId.toString() +
        '&FileName=' +
        fileName +
        '&TaskRegID=' +
        "$taskid";
    final http.Response response = await http.post(
      Uri.parse(query),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      fileController.clear();
      existingfile = null;
      _requestSearchData();
      inwardfiledetailsadmin(taskid);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
      fileController.clear();
      existingfile = null;
    }
  }

  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     if (result == PermissionStatus.granted) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  String creationsource(int creationnum) {
    switch (creationnum) {
      case 1:
        {
          return "Email";
        }
        break;
      case 2:
        {
          return "WhatsApp";
        }
        break;
      case 3:
        {
          return "Phone";
        }
        break;
      case 4:
        {
          return "Hardcopy";
        }
        break;
      case 5:
        {
          return "Recurring";
        }
        break;
    }
    return "";
  }
}

class AssignModel {
  const AssignModel(
      {this.clientname,
      this.taskNumber,
      this.taskName,
      this.employee,
      this.employeename,
      this.date,
      this.finYear,
      this.estcomp,
      this.creationsrc,
      this.taskid,
      this.statusid,
      this.statusname,
      this.updatedtask,
      this.id,
      this.filecount,
      this.employeeid,
      this.empcount,
      this.empid});
  final String? clientname;
  final String? taskNumber;
  final String? taskName;
  final String? employee;
  final String? empid;
  final String? employeename;
  final String? date;
  final String? finYear;
  final String? estcomp;
  final int? creationsrc;
  final int? taskid;
  final String? statusname;
  final String? statusid;
  final String? updatedtask;
  final int? id;
  final int? filecount;
  final String? employeeid;
  final int? empcount;

  factory AssignModel.fromJson(Map<String, dynamic> json) {
    return AssignModel(
      clientname: json['ClientIDName'] ?? "",
      taskNumber: json['TaskNumber'] ?? "",
      taskName: json['TaskIDName'] ?? "",
      empid: json['EmpID'].toString(),
      employee: json['EmpIDName'] ?? "",
      employeename: json['Text'] ?? "",
      employeeid: json['Value'] ?? "",
      date: json['RegDate'] ?? "",
      finYear: json['FinancialYear'] ?? "",
      estcomp: json['EstCompDate'] ?? "",
      creationsrc: json['CreationSource'] ?? 0,
      taskid: json['TaskID'] ?? 0,
      id: json['Id'] ?? 0,
      statusname: json['Text'] ?? "",
      statusid: json['Value'] ?? "",
      updatedtask: json['StatusIDName'] ?? "",
      filecount: json['FileCount'] ?? 0,
      empcount: json['EmployeeCount'] ?? 0,
    );
  }
}

class StatusModal {
  StatusModal({this.text, this.value});

  String? text;
  String? value;

  factory StatusModal.fromJson(Map<String, dynamic> json) {
    return StatusModal(text: json['Text'] ?? "", value: json['Value'] ?? "");
  }
}

class InwardModel {
  InwardModel(
      {this.docname,
      this.id,
      this.actualfilename,
      this.taskid,
      this.refdocname});
  final String? docname;
  final int? id;
  final String? actualfilename;
  final int? taskid;
  final String? refdocname;

  factory InwardModel.fromJson(Map<String, dynamic> json) {
    return InwardModel(
        docname: json['FileName'] ?? "",
        id: json['Id'] ?? 0,
        taskid: json['TaskID'] ?? "",
        refdocname: json['RefFileName'] ?? "",
        actualfilename: json['ActualFileName'] ?? "");
  }
}

class Employee {
  final String? id;
  String? name;

  Employee({
    this.id,
    this.name,
  });
}

Loader(bool isLoaded) {
  return !isLoaded
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
                        style: TextStyle(fontSize: 20, color: Colors.blue)),
                    SizedBox(
                      width: 20,
                    ),
                    CircularProgressIndicator(color: Colors.blue)
                  ])))
      : Row();
}
