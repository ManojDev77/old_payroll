import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class VarController extends GetxController {
  RxInt payrollwidgetcnt = 1.obs;
  RxBool isLeave = false.obs;
  RxBool istaskenabled = false.obs;
  RxBool isdirectbilling = false.obs;
  RxBool isCircularEnabled = false.obs;
  RxBool isMeetingEnabled = false.obs;
  RxBool isCalendarEnabled = false.obs;
  RxBool isBiometricEnabled = false.obs;
  RxBool isHolidayEnabled = false.obs;
  RxBool isSalaryEnabled = false.obs;
  RxBool isempcontactenabled = false.obs;
  RxBool employeelogin = false.obs;
  RxBool isAttendance = false.obs;
  RxBool isGPS = false.obs;
  RxBool isSublogin = false.obs;
  RxBool isWithoutLocationEnabled = false.obs;
  RxBool isLoginInWebAllowed = false.obs;
  RxBool loginphotocap = false.obs;
  RxBool isEmployee = false.obs;
  RxBool isEmpAttendanceOn = false.obs;
  RxBool isEmpSubLoginOn = false.obs;
  RxBool isEmpGpsOn = false.obs;

  Rx<LocationData>? locationData;
  RxBool isLocationLoaded = false.obs;

  final Rx<CameraPosition> initialposition = const CameraPosition(
    bearing: 15,
    target: LatLng(30.677515, 76.74390),
    zoom: 15,
  ).obs;

  RxBool loginVisible = true.obs;
  RxBool logoutVisible = false.obs;
  RxBool subloginVisible = false.obs;

  RxBool loginSubVisible = true.obs;
  RxBool logoutSubVisible = false.obs;
}
