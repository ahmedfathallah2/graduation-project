import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<String?> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success 
    } on FirebaseAuthException catch (e) {
      return e.message; // Show error message
    }
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Show error message
    }
  }
}