import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'approveList.dart';
import 'leave_application.dart';
import 'leave_details.dart';

class LeaveAproveRequest extends StatefulWidget {
  const LeaveAproveRequest({Key? key}) : super(key: key);

  @override
  _LeaveAproveRequestState createState() => _LeaveAproveRequestState();
}

class _LeaveAproveRequestState extends State<LeaveAproveRequest> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: globals.isapprover ? 3 : 2,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: const Text("Leave Application"),
              bottom: TabBar(
                tabs: [
                  if (globals.isapprover)
                    const Tab(
                      text: "Leave Approve",
                    ),
                  const Tab(
                    text: "Leave Request",
                  ),
                  const Tab(
                    text: "Leave Details",
                  ),
                ],
              )),
          body: TabBarView(
            children: [
              if (globals.isapprover)
                const Tab(
                  child: ApproveLeaveList(),
                ),
              const Tab(
                child: LeaveApplicationWidget(
                  mainId: 0,
                  empname: "",
                ),
              ),
              const Tab(
                child: LeaveDetails(),
              ),
            ],
          )),
    );
  }
}
