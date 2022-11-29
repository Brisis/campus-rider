import 'package:firebase_auth/firebase_auth.dart';

Future<String?> mailRegister(String mail, String pwd) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: mail, password: pwd);
    return null;
  } on FirebaseAuthException catch (ex) {
    return "${ex.code}: ${ex.message}";
  }
}
