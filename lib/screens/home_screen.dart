import 'package:campus_rider/maps/map_home_screen.dart';
import 'package:campus_rider/read%20data/get_user_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIDs = [];

  //get DocIDs
  Future getDocIds() async {
    await FirebaseFirestore.instance.collection("users").get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MapHomeScreeen(
      username: user.email!,
    );
    // Scaffold(
    //   appBar: AppBar(
    //     title: Text(user.email!),
    //     actions: [
    //       IconButton(
    //           onPressed: () {
    //             FirebaseAuth.instance.signOut();
    //           },
    //           icon: Icon(
    //             Icons.logout,
    //           ))
    //     ],
    //   ),
    //   body: MapHomeScreeen(),
    //   // body: Center(
    //   //   child: Column(
    //   //     mainAxisAlignment: MainAxisAlignment.center,
    //   //     children: [
    //   //       Expanded(
    //   //         child: FutureBuilder(
    //   //           future: getDocIds(),
    //   //           builder: (context, snapshot) {
    //   //             return ListView.builder(
    //   //               itemCount: docIDs.length,
    //   //               itemBuilder: ((context, index) {
    //   //                 return Padding(
    //   //                   padding: const EdgeInsets.all(8.0),
    //   //                   child: ListTile(
    //   //                     title: GetUserName(documentId: docIDs[index]),
    //   //                     tileColor: Colors.grey[200],
    //   //                   ),
    //   //                 );
    //   //               }),
    //   //             );
    //   //           },
    //   //         ),
    //   //       ),
    //   //     ],
    //   //   ),
    //   // ),
    // );
  }
}
