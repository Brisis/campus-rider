import 'package:firebase_auth/firebase_auth.dart';

Future<String?> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    return null;
  } on FirebaseAuthException catch (ex) {
    return "${ex.code}: ${ex.message}";
  }
}
