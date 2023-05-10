import 'dart:async';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class LocateUserWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  const LocateUserWidget({Key? key, this.latitude, this.longitude})
      : super(key: key);

  @override
  LocateUserWidgetState createState() => LocateUserWidgetState();
}

class LocateUserWidgetState extends State<LocateUserWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  double zoomVal = 5.0;
  String? checkinoutStatus;
  Location location = Location();
  LatLng? currentPostion;
  final Set<Marker> _markers = {};
  bool isFullDay = true;
  bool loginVisible = true;
  bool logoutVisible = true;
  String? error;
  var direction = 1;
  @override
  void initState() {
    super.initState();
    setinitiallocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "User Location",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Poppins-Medium",
              fontSize: 22,
              letterSpacing: .6,
              fontWeight: FontWeight.w600),
        ),
        elevation: 0.8,
        centerTitle: true,
        bottomOpacity: 0,
      ),
      body: Stack(
        children: <Widget>[
          googleMap(context),
        ],
      ),
    );
  }

  Widget googleMap(BuildContext context) {
    double initialLat = 30.677515;
    double initialLong = 76.743902;
    double initialZoom = 15;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
            target: LatLng(initialLat, initialLong), zoom: initialZoom),
        markers: Set.from(_markers),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller.complete(controller);
          });
        },
      ),
    );
  }

  void setinitiallocation() async {
    setState(() {
      _gotoLocation(widget.latitude!, widget.longitude!);
    });
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long), zoom: 15, tilt: 50.0, bearing: 45.0)));
    _markers.add(Marker(
        markerId: const MarkerId("marker"), position: LatLng(lat, long)));
  }
}
