import 'package:firebase_auth/firebase_auth.dart';

/// Authentication service that handles Firebase Auth with Google Sign-In
/// Uses Firebase Auth popup for all platforms (web, android, ios)
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign in with Google using Firebase Auth
  /// Returns the User if successful, throws an exception otherwise
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      // Use popup for web, signInWithProvider for mobile
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithPopup(googleProvider);
      
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from Firebase
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Get user display name
  String? get displayName => currentUser?.displayName;

  /// Get user email
  String? get email => currentUser?.email;

  /// Get user photo URL
  String? get photoURL => currentUser?.photoURL;

  /// Get user UID
  String? get uid => currentUser?.uid;
}
