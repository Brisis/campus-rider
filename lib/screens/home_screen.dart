import 'package:campus_rider/helpers/constants.dart';
import 'package:campus_rider/maps/map_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class HomeScreen extends StatefulWidget {
  final LatLng currentLocation;
  const HomeScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  String name = "";
  String locationId = "";

  dynamic data;

  Future<dynamic> getData() async {
    final DocumentReference document =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        data = snapshot.data();
        name = data['full name'];
      });
    });
  }

  // Future<dynamic> getLocationData() async {
  //   final DocumentReference document =
  //       FirebaseFirestore.instance.collection("location").doc(user.uid);

  //   await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
  //     setState(() {
  //       locationId = snapshot.data()[];
  //     });
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    //return CabTrackingScreen();
    return MapHomeScreeen(
      name: name,
      username: user.email!,
      locationUserId: loggedUser.uid,
      currentLocation: widget.currentLocation,
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await locationLive.getLocation();
      await FirebaseFirestore.instance
          .collection('location')
          .doc(loggedUser.uid)
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': name,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }
}
