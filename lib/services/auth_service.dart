import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return true; // Successfully logged in
      } else {
        return false; // Login failed
      }
    } on FirebaseAuthException catch (e) {
      print("Login failed: ${e.message}");
      // Handle specific error cases
      if (e.code == 'user-not-found') {
        print("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print("Incorrect password.");
      }
      return false; // Return false if an error occurred
    }
  }

  // Register method
  Future<bool> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Send email verification after registration
        await userCredential.user?.sendEmailVerification();
        print("Registration successful. Verification email sent.");
        return true; // Registration successful
      } else {
        return false; // Registration failed
      }
    } on FirebaseAuthException catch (e) {
      print("Registration failed: ${e.message}");
      // Handle specific error cases
      if (e.code == 'weak-password') {
        print("The password is too weak.");
      } else if (e.code == 'email-already-in-use') {
        print("The account already exists for that email.");
      } else if (e.code == 'invalid-email') {
        print("The email address is not valid.");
      }
      return false; // Return false if an error occurred
    }
  }

  // Method to log out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get the current user
  User? get currentUser {
    return _auth.currentUser;
  }
}