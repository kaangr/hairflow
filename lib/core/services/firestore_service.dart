import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Firestore servisi - tüm CRUD işlemleri için merkezi servis
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection paths
  static const String _usersCollection = 'users';
  static const String _routinesCollection = 'routines';
  static const String _tasksCollection = 'tasks';
  static const String _tipsCollection = 'tips';
  static const String _productsCollection = 'products';
  static const String _userStatsCollection = 'userStats';

  /// Mevcut kullanıcı ID'si
  String? get currentUserId => _auth.currentUser?.uid;

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => _auth.currentUser != null;

  // ============ USER METHODS ============

  /// Kullanıcı profili oluştur veya güncelle
  Future<void> createOrUpdateUser(Map<String, dynamic> userData) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .set({
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Kullanıcı profilini getir
  Future<Map<String, dynamic>?> getUser() async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .get();
    
    return doc.data();
  }

  // ============ ROUTINE METHODS ============

  /// Rutin oluştur
  Future<String> createRoutine(Map<String, dynamic> routineData) async {
    if (currentUserId == null) throw Exception('Kullanıcı giriş yapmamış');
    
    final docRef = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_routinesCollection)
        .add({
          ...routineData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
    
    return docRef.id;
  }

  /// Tüm rutinleri getir
  Future<List<Map<String, dynamic>>> getRoutines() async {
    if (currentUserId == null) return [];
    
    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_routinesCollection)
        .orderBy('createdAt', descending: false)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Rutin güncelle
  Future<void> updateRoutine(String routineId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_routinesCollection)
        .doc(routineId)
        .update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Rutin sil
  Future<void> deleteRoutine(String routineId) async {
    if (currentUserId == null) return;
    
    // Önce ilişkili görevleri sil
    final tasksSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .where('routineId', isEqualTo: routineId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in tasksSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Sonra rutini sil
    batch.delete(_firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_routinesCollection)
        .doc(routineId));
    
    await batch.commit();
  }

  // ============ TASK METHODS ============

  /// Görev oluştur
  Future<String> createTask(Map<String, dynamic> taskData) async {
    if (currentUserId == null) throw Exception('Kullanıcı giriş yapmamış');
    
    final docRef = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .add({
          ...taskData,
          'createdAt': FieldValue.serverTimestamp(),
        });
    
    return docRef.id;
  }

  /// Belirli tarihteki görevleri getir
  Future<List<Map<String, dynamic>>> getTasksByDate(DateTime date) async {
    if (currentUserId == null) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Tüm görevleri getir
  Future<List<Map<String, dynamic>>> getAllTasks() async {
    if (currentUserId == null) return [];
    
    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Rutin'e ait görevleri getir
  Future<List<Map<String, dynamic>>> getTasksByRoutineId(String routineId) async {
    if (currentUserId == null) return [];
    
    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .where('routineId', isEqualTo: routineId)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Görev güncelle
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .doc(taskId)
        .update(data);
  }

  /// Görev tamamlandı olarak işaretle
  Future<void> markTaskCompleted(String taskId, bool isCompleted) async {
    await updateTask(taskId, {
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
    });
  }

  /// Görev sil
  Future<void> deleteTask(String taskId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_tasksCollection)
        .doc(taskId)
        .delete();
  }

  // ============ USER STATS METHODS ============

  /// Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>?> getUserStats() async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_userStatsCollection)
        .doc('stats')
        .get();
    
    return doc.data();
  }

  /// Kullanıcı istatistiklerini güncelle
  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_userStatsCollection)
        .doc('stats')
        .set(stats, SetOptions(merge: true));
  }

  /// XP ekle
  Future<void> addXP(int amount) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_userStatsCollection)
        .doc('stats')
        .set({
          'totalXP': FieldValue.increment(amount),
          'lastActivityAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Streak güncelle
  Future<void> updateStreak() async {
    if (currentUserId == null) return;
    
    final stats = await getUserStats();
    final lastActivity = stats?['lastActivityAt'] as Timestamp?;
    final currentStreak = stats?['currentStreak'] as int? ?? 0;
    final longestStreak = stats?['longestStreak'] as int? ?? 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = currentStreak;
    
    if (lastActivity != null) {
      final lastDate = lastActivity.toDate();
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDay).inDays;
      
      if (difference == 1) {
        // Ardışık gün - streak artır
        newStreak = currentStreak + 1;
      } else if (difference > 1) {
        // Ara verildi - streak sıfırla
        newStreak = 1;
      }
      // difference == 0 ise aynı gün, streak değişmez
    } else {
      newStreak = 1;
    }
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_userStatsCollection)
        .doc('stats')
        .set({
          'currentStreak': newStreak,
          'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
          'lastActivityAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // ============ GLOBAL TIPS/PRODUCTS (Admin) ============

  /// Global ürünleri getir (tüm kullanıcılar için)
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('category')
          .get();
      
      return snapshot.docs.map((doc) => <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      // Permission denied veya başka bir hata - boş liste döndür
      return <Map<String, dynamic>>[];
    }
  }

  /// Global ipuçlarını getir (tüm kullanıcılar için)
  Future<List<Map<String, dynamic>>> getTips() async {
    try {
      final snapshot = await _firestore
          .collection(_tipsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Kategoriye göre ipuçlarını getir
  Future<List<Map<String, dynamic>>> getTipsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_tipsCollection)
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs.map((doc) => <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }
}

