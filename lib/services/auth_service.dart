import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String address,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();

        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': email,
            'name': name,
            'address': address,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          return false;
        }

        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current user getter
  User? get currentUser => _auth.currentUser;
}