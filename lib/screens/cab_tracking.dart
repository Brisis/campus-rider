import 'dart:async';

import 'package:campus_rider/helpers/constants.dart';
import 'package:campus_rider/maps/maps_home.dart';
import 'package:campus_rider/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CabTrackingScreen extends StatefulWidget {
  final LatLng sourceLocation;
  final LatLng destination;
  const CabTrackingScreen({
    Key? key,
    required this.sourceLocation,
    required this.destination,
  }) : super(key: key);

  @override
  State<CabTrackingScreen> createState() => CabTrackingScreenState();
}

class CabTrackingScreenState extends State<CabTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location? location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              newLoc.latitude!,
              newLoc.longitude!,
            ),
            zoom: 13.5,
          ),
        ),
      );
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(
          widget.sourceLocation.latitude, widget.sourceLocation.longitude),
      PointLatLng(widget.destination.latitude, widget.destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then((icon) => sourceIcon = icon);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then((icon) => destinationIcon = icon);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Badge.png")
        .then((icon) => currentLocationIcon = icon);
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            "In Transit",
            style: GoogleFonts.pacifico(
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: currentLocation == null
          ? Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 20.5,
              ),
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.deepPurple,
                  width: 6,
                )
              },
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  icon: currentLocationIcon,
                ),
                Marker(
                  markerId: MarkerId("source"),
                  position: widget.sourceLocation,
                  icon: sourceIcon,
                ),
                Marker(
                  markerId: MarkerId("destination"),
                  position: widget.destination,
                  icon: destinationIcon,
                )
              },
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            await FirebaseFirestore.instance
                .collection('notifications')
                .doc(loggedUser.uid)
                .set({
              'admin': "Bindura University Admin",
              'status': "Arrived",
              'student': loggedUser.email,
            }, SetOptions(merge: true));

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MapsHomeScreen()));
          } catch (e) {
            print(e);
          }
        },
        label: const Text('End Trip'),
        icon: const Icon(Icons.location_pin),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
