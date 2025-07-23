import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling user authentication and user data management
/// 
/// Provides methods for user registration, login, logout, and user data operations
/// using Firebase Authentication and Firestore.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signs in a user with email and password
  /// 
  /// Returns [AuthResult] containing success status and optional error message
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.login('user@example.com', 'password');
  /// if (result.success) {
  ///   // Login successful
  /// } else {
  ///   // Handle error: result.errorMessage
  /// }
  /// ```
  Future<AuthResult> login(String email, String password) async {
    try {
      // Input validation
      if (email.trim().isEmpty || password.trim().isEmpty) {
        return AuthResult(
          success: false,
          errorMessage: 'Email and password cannot be empty',
        );
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Check if email is verified
        if (!userCredential.user!.emailVerified) {
          return AuthResult(
            success: false,
            errorMessage: 'Please verify your email before signing in',
            needsEmailVerification: true,
          );
        }

        return AuthResult(success: true, user: userCredential.user);
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Login failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = 'Login failed: ${e.message ?? 'Unknown error'}';
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Registers a new user with email, password, and additional information
  /// 
  /// Returns [AuthResult] containing success status and optional error message
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.register(
  ///   email: 'user@example.com',
  ///   password: 'securePassword',
  ///   name: 'John Doe',
  ///   address: '123 Farm Street',
  /// );
  /// ```
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    required String address,
  }) async {
    try {
      // Input validation
      if (email.trim().isEmpty || 
          password.trim().isEmpty || 
          name.trim().isEmpty || 
          address.trim().isEmpty) {
        return AuthResult(
          success: false,
          errorMessage: 'All fields are required',
        );
      }

      // Password strength validation
      if (password.length < 6) {
        return AuthResult(
          success: false,
          errorMessage: 'Password must be at least 6 characters long',
        );
      }

      // Email format validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
        return AuthResult(
          success: false,
          errorMessage: 'Please enter a valid email address',
        );
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Update display name
        await userCredential.user!.updateDisplayName(name.trim());

        // Create user document in Firestore
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': email.trim().toLowerCase(),
            'name': name.trim(),
            'address': address.trim(),
            'emailVerified': false,
            'profileComplete': true,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'analysisCount': 0,
            'settings': {
              'notifications': true,
              'locationServices': true,
              'dataBackup': false,
            },
          });
        } catch (firestoreError) {
          // If Firestore fails, delete the auth user to maintain consistency
          await userCredential.user!.delete();
          return AuthResult(
            success: false,
            errorMessage: 'Failed to create user profile. Please try again.',
          );
        }

        return AuthResult(
          success: true,
          user: userCredential.user,
          message: 'Registration successful! Please check your email for verification.',
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Registration failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message ?? 'Unknown error'}';
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sends a password reset email to the specified email address
  /// 
  /// Returns [AuthResult] containing success status and optional error message
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        return AuthResult(
          success: false,
          errorMessage: 'Email address is required',
        );
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message ?? 'Unknown error'}';
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Resends email verification to the current user
  /// 
  /// Returns [AuthResult] containing success status and optional error message
  Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is currently signed in',
        );
      }

      if (user.emailVerified) {
        return AuthResult(
          success: false,
          errorMessage: 'Email is already verified',
        );
      }

      await user.sendEmailVerification();
      return AuthResult(
        success: true,
        message: 'Verification email sent successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to send verification email: ${e.message}',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Signs out the current user
  /// 
  /// Returns [AuthResult] containing success status and optional error message
  Future<AuthResult> logout() async {
    try {
      await _auth.signOut();
      return AuthResult(success: true, message: 'Logged out successfully');
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to log out. Please try again.',
      );
    }
  }

  /// Updates the user's last login timestamp in Firestore
  Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silently handle this error as it's not critical
    }
  }

  /// Checks if the current user's email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  /// Updates user profile information in Firestore
  Future<AuthResult> updateUserProfile({
    String? name,
    String? address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is currently signed in',
        );
      }

      Map<String, dynamic> updates = {};
      
      if (name != null && name.trim().isNotEmpty) {
        updates['name'] = name.trim();
        await user.updateDisplayName(name.trim());
      }
      
      if (address != null && address.trim().isNotEmpty) {
        updates['address'] = address.trim();
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      return AuthResult(
        success: true,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to update profile. Please try again.',
      );
    }
  }

  /// Gets the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Result class for authentication operations
/// 
/// Contains success status, optional error message, and additional data
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? message;
  final User? user;
  final bool needsEmailVerification;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.message,
    this.user,
    this.needsEmailVerification = false,
  });

  @override
  String toString() {
    return 'AuthResult(success: $success, errorMessage: $errorMessage, message: $message)';
  }
}