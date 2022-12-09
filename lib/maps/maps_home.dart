import 'dart:async';

import 'package:campus_rider/helpers/constants.dart';
import 'package:campus_rider/maps/maps_navigation.dart';
import 'package:campus_rider/screens/home_screen.dart';
import 'package:campus_rider/widgets/settings_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;

class MapsHomeScreen extends StatefulWidget {
  @override
  State<MapsHomeScreen> createState() => _MapsHomeScreenState();
}

class _MapsHomeScreenState extends State<MapsHomeScreen> {
  LatLng? destLocation = LatLng(-17.301306, 31.319849);
  double? destLatitude;
  double? destLongitude;
  Location location = Location();
  loc.LocationData? _currentPosition;
  final Completer<GoogleMapController?> _controller = Completer();
  String? _address;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final user = FirebaseAuth.instance.currentUser!;
  String name = "";
  String locationId = "";

  dynamic data;

  String? address;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    getData();
  }

  @override
  Widget build(BuildContext context) {
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
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        color: kTextFadedColor,
                      ),
                    ),
                    Text(
                      loggedUser.email!,
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
                      FirebaseAuth.instance.signOut();
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
            "Choose Destination",
            style: GoogleFonts.pacifico(
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                getCurrentLocation();
              },
              icon: Icon(Icons.location_pin))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.navigate_next),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NavigationScreen(
                    destLatitude!,
                    destLongitude!,
                  ),
                ),
                (route) => false);
          }),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: destLocation!,
              zoom: 16,
            ),
            onCameraMove: (CameraPosition? position) {
              if (destLocation != position!.target) {
                setState(() {
                  destLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              print('camera idle');
              getAddressFromLatLng();
            },
            onTap: (latLng) {
              // print(latLng);
              getAddress(latLng.latitude, latLng.longitude);

              //getAddressFromLatLng(latLng.latitude, latLng.longitude);
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Image.asset(
                'assets/images/pick.png',
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Text(_address ?? 'Pick your destination address',
                  overflow: TextOverflow.visible, softWrap: true),
            ),
          ),
        ],
      ),
    );
  }

  getAddress(double latitude, double longitude) async {
    geo.Placemark place;
    List<geo.Placemark> placemarkes =
        await geo.placemarkFromCoordinates(latitude, longitude);
    place = placemarkes[0];

    print(place);
    setState(() {
      _address = place.name;
      destLatitude = latitude;
      destLongitude = longitude;
    });
  }

//double? latitude, double? longitude
  getAddressFromLatLng() async {
    try {
      print(destLocation!.latitude);
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: destLocation!.latitude,
        longitude: destLocation!.longitude,
        googleMapApiKey: googleApiKey,
      );

      setState(() {
        _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    final GoogleMapController? controller = await _controller.future;

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if (_permissionGranted == loc.PermissionStatus.granted) {
      location.changeSettings(accuracy: loc.LocationAccuracy.high);

      _currentPosition = await location.getLocation();
      controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        zoom: 16,
      )));
      setState(() {
        destLocation =
            LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      });
    }
  }
}
