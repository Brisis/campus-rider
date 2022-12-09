import 'package:campus_rider/helpers/constants.dart';
import 'package:campus_rider/maps/maps_home.dart';
import 'package:campus_rider/maps/maps_navigation.dart';
import 'package:campus_rider/screens/cab_tracking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class GoogleMaps extends StatefulWidget {
  final LatLng sourceLocation;
  final LatLng destination;

  const GoogleMaps({
    super.key,
    required this.sourceLocation,
    required this.destination,
  });
  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  final _driverIdController = TextEditingController();
  final _priceController = TextEditingController();

  String driver = "John Doe";

  BitmapDescriptor studentIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor driverIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Badge.png")
        .then((icon) => studentIcon = icon);

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/car.png")
        .then((icon) => driverIcon = icon);
  }

  void payTrip() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(loggedUser.uid)
          .set({
        'student': loggedUser.email,
        'driver': driver,
        'fee': _priceController.text.trim(),
      }, SetOptions(merge: true));

      Navigator.of(context).push(
        routeTransition(
          CabTrackingScreen(
            sourceLocation: widget.sourceLocation,
            destination: widget.destination,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _driverIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dialog tripDialog = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 8,
              ),
              child: Text(
                "Driver: $driver",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ride Fee",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: payTrip,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Start Trip",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MapsHomeScreen()));
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Center(
          child: Text(
            "Choose Driver",
            style: GoogleFonts.pacifico(
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (_added) {
            mymap(snapshot);
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            mapType: MapType.normal,
            markers: {
              Marker(
                position: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == loggedUser.uid)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == loggedUser.uid)['longitude'],
                ),
                markerId: MarkerId('id'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
              Marker(
                  position: LatLng(
                    snapshot.data!.docs.singleWhere((element) =>
                        element.id ==
                        "wPJPd24wdRXpIRHOzfQMsgWiTxb2")['latitude'],
                    snapshot.data!.docs.singleWhere((element) =>
                        element.id ==
                        "wPJPd24wdRXpIRHOzfQMsgWiTxb2")['longitude'],
                  ),
                  markerId: MarkerId('id'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  onTap: () {
                    var drivername = snapshot.data!.docs.singleWhere(
                        (element) =>
                            element.id ==
                            "wPJPd24wdRXpIRHOzfQMsgWiTxb2")['name'];
                    setState(() {
                      driver = drivername;
                    });

                    showDialog(
                        context: context,
                        builder: (BuildContext context) => tripDialog);
                  }),
              Marker(
                  position: LatLng(
                    snapshot.data!.docs.singleWhere((element) =>
                        element.id ==
                        "2I9EtcsgUeW7S0El3R0CeYsIKy63")['latitude'],
                    snapshot.data!.docs.singleWhere((element) =>
                        element.id ==
                        "2I9EtcsgUeW7S0El3R0CeYsIKy63")['longitude'],
                  ),
                  markerId: MarkerId('id'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  onTap: () {
                    var drivername = snapshot.data!.docs.singleWhere(
                        (element) =>
                            element.id ==
                            "2I9EtcsgUeW7S0El3R0CeYsIKy63")['name'];
                    setState(() {
                      driver = drivername;
                    });
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => tripDialog);
                  }),
            },
            initialCameraPosition: CameraPosition(
                target: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == loggedUser.uid)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == loggedUser.uid)['longitude'],
                ),
                zoom: 14.47),
            onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   label: const Text('My Location'),
      //   icon: const Icon(Icons.location_pin),
      //   backgroundColor: Colors.pink,
      // ),
    );
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == loggedUser.uid)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == loggedUser.uid)['longitude'],
            ),
            zoom: 14.47)));
  }
}
