import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_preferences.dart';

/// Repository for managing user data in Firebase Firestore
class FirebaseUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _usersCollection = 'users';
  static const String _routinesCollection = 'routines';
  static const String _preferencesDoc = 'preferences';

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(_usersCollection).doc(uid);
  }

  /// Create or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String? email,
    required String? displayName,
    required String? photoURL,
  }) async {
    await _userDoc(uid).set({
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Set createdAt only if it doesn't exist
    final doc = await _userDoc(uid).get();
    if (!doc.exists || doc.data()?['createdAt'] == null) {
      await _userDoc(uid).update({
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data();
  }

  /// Save user preferences to Firestore
  Future<void> saveUserPreferences({
    required String uid,
    required UserPreferences preferences,
  }) async {
    await _userDoc(uid).collection('settings').doc(_preferencesDoc).set({
      'goal': preferences.goal,
      'notificationsEnabled': preferences.notificationsEnabled,
      'reminderTime': preferences.reminderTime,
      'isDarkMode': preferences.isDarkMode,
      'isFirstLaunch': preferences.isFirstLaunch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user preferences from Firestore
  Future<UserPreferences?> getUserPreferences(String uid) async {
    final doc = await _userDoc(uid)
        .collection('settings')
        .doc(_preferencesDoc)
        .get();
    
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    return UserPreferences(
      goal: data['goal'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      reminderTime: data['reminderTime'] ?? '09:00',
      isDarkMode: data['isDarkMode'] ?? false,
      isFirstLaunch: data['isFirstLaunch'] ?? true,
    );
  }

  /// Save routine completion
  Future<void> saveRoutineCompletion({
    required String uid,
    required String taskId,
    required String taskName,
    required DateTime completedAt,
  }) async {
    final dateStr = _formatDate(completedAt);
    
    await _userDoc(uid)
        .collection(_routinesCollection)
        .doc(dateStr)
        .collection('completedTasks')
        .doc(taskId)
        .set({
      'taskName': taskName,
      'completedAt': Timestamp.fromDate(completedAt),
    });
  }

  /// Get completed tasks for a specific date
  Future<List<String>> getCompletedTaskIds({
    required String uid,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    
    final snapshot = await _userDoc(uid)
        .collection(_routinesCollection)
        .doc(dateStr)
        .collection('completedTasks')
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Get routine history for date range
  Future<Map<DateTime, int>> getRoutineHistory({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = <DateTime, int>{};
    
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || 
           currentDate.isAtSameMomentAs(endDate)) {
      final dateStr = _formatDate(currentDate);
      
      final snapshot = await _userDoc(uid)
          .collection(_routinesCollection)
          .doc(dateStr)
          .collection('completedTasks')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        result[currentDate] = snapshot.docs.length;
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return result;
  }

  /// Delete user data
  Future<void> deleteUserData(String uid) async {
    // Delete user document and subcollections
    final userDoc = _userDoc(uid);
    
    // Delete preferences
    await userDoc.collection('settings').doc(_preferencesDoc).delete();
    
    // Delete routines (this is a simplified version - 
    // in production, you'd need to handle subcollections properly)
    final routines = await userDoc.collection(_routinesCollection).get();
    for (final doc in routines.docs) {
      await doc.reference.delete();
    }
    
    // Delete user document
    await userDoc.delete();
  }

  /// Format date to string for document ID
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

