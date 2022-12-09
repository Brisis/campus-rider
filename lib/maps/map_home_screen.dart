import 'dart:async';

import 'package:campus_rider/helpers/constants.dart';
import 'package:campus_rider/helpers/location_service.dart';
import 'package:campus_rider/maps/maps_home.dart';
import 'package:campus_rider/maps/mymap.dart';
import 'package:campus_rider/widgets/settings_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapHomeScreeen extends StatefulWidget {
  final String username;
  final String name;
  final String locationUserId;
  final LatLng currentLocation;
  const MapHomeScreeen({
    super.key,
    required this.username,
    required this.name,
    required this.locationUserId,
    required this.currentLocation,
  });

  @override
  State<MapHomeScreeen> createState() => MapHomeScreeenState();
}

class MapHomeScreeenState extends State<MapHomeScreeen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_setMarker(LatLng(7.42796133580664, -122.085749655962));
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    //return GoogleMaps
    //MapsLiveLocation();
    //MapsHomeScreen();
    return Scaffold(
      key: _scaffoldKey,
      drawer: SafeArea(
        child: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/images/femaleProfile.jpg"),
                    maxRadius: 50,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 15,
                        color: kTextFadedColor,
                      ),
                    ),
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextFadedColor,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigator.of(context)
                      //     .push(routeTransition(const LoginScreen()));
                    },
                    label: Text(
                      "Logout",
                      style: const TextStyle(
                        fontSize: 15,
                        color: kTextWhite,
                      ),
                    ),
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10.0)),
                      backgroundColor: MaterialStateProperty.all(kPrimaryColor),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    icon: Icon(
                      Icons.logout,
                      color: kRedIconColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SettingsItem(
                  title: "Edit Profile",
                  icon: Icons.person_outline,
                  onTap: () {},
                ),
                SettingsItem(
                  title: "Your Trips",
                  icon: Icons.directions_car,
                  onTap: () {},
                ),
                // SettingsItem(
                //   title: "Notifications",
                //   icon: Icons.notifications,
                //   onTap: () {},
                // ),
                // SettingsItem(
                //   title: "Settings",
                //   icon: Icons.security,
                //   onTap: () {},
                // ),
                const Divider(
                  color: kTextGrey,
                  thickness: 0.2,
                ),
                const Center(
                  child: Text(
                    "Buse Ride Hailing @2022",
                    style: TextStyle(
                      fontSize: 10,
                      color: kTextFadedColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          icon: const Icon(
            Icons.menu,
          ),
        ),
        title: Center(
          child: Text(
            "Buse Ride Hailing",
            style: GoogleFonts.pacifico(
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      // body: GoogleMaps(
      //   userId: widget.locationUserId,
      //   userName: widget.name,
      //   destLatitude: ,
      //   destLongitude: ,
      //   currentLocation: widget.currentLocation,
      // ),
    );
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(loggedUser.uid)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': widget.name,
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await location.hasPermission();
    if (status == loc.PermissionStatus.granted) {
      print('done');
    } else if (status == loc.PermissionStatus.denied) {
      _requestPermission();
    }
  }
}
