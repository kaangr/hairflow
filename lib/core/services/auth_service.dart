import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication service that handles Firebase Auth with Google Sign-In
/// Uses Firebase Auth popup for all platforms (web, android, ios)
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      
      // Firestore'da kullanıcı kaydı oluştur/güncelle (rol sistemi ile)
      if (userCredential.user != null) {
        await _createOrUpdateFirestoreUser(userCredential.user!);
      }
      
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Firestore'da kullanıcı profili oluştur veya güncelle (rol sistemi)
  Future<void> _createOrUpdateFirestoreUser(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Yeni kullanıcı - default role: User (roleId = 3)
      await userDoc.set({
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoURL': firebaseUser.photoURL,
        'role': 'user',          // Default: user
        'roleId': 3,             // Default: 3 (User)
        'isActive': true,
        'emailVerified': firebaseUser.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      // UserStats oluştur
      await userDoc.collection('userStats').doc('stats').set({
        'totalXP': 0,
        'currentLevel': 1,
        'currentStreak': 0,
        'longestStreak': 0,
        'totalTasksCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Mevcut kullanıcı - son giriş güncelle
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  /// Kullanıcının rolünü getir
  Future<String> getUserRole() async {
    final user = currentUser;
    if (user == null) return 'guest';

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['role'] as String? ?? 'user';
    } catch (e) {
      return 'user';
    }
  }
  
  /// Kullanıcının role ID'sini getir
  Future<int> getUserRoleId() async {
    final user = currentUser;
    if (user == null) return 0;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['roleId'] as int? ?? 3;
    } catch (e) {
      return 3;
    }
  }

  /// Admin kontrolü
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  /// Expert kontrolü
  Future<bool> isExpert() async {
    final role = await getUserRole();
    return role == 'expert' || role == 'admin';
  }
  
  /// User kontrolü
  Future<bool> isUser() async {
    final role = await getUserRole();
    return role == 'user';
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
