import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../domain/entities/role.dart';

/// Admin Repository - Admin yetkisi gerektiren işlemler
class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ========== USER MANAGEMENT ==========

  /// Tüm kullanıcıları listele (sadece Admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Kullanıcının rolünü değiştir (sadece Admin)
  Future<void> changeUserRole(String userId, Role newRole) async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    await _firestore.collection('users').doc(userId).update({
      'role': newRole.name.toLowerCase(),
      'roleId': newRole.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kullanıcıyı aktif/pasif yap (sadece Admin)
  Future<void> toggleUserActive(String userId, bool isActive) async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kullanıcı sil (sadece Admin)
  Future<void> deleteUser(String userId) async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    // Kullanıcıyı ve tüm subcollection'larını sil
    final batch = _firestore.batch();
    
    // User doc
    final userDoc = _firestore.collection('users').doc(userId);
    batch.delete(userDoc);
    
    // Routines
    final routines = await userDoc.collection('routines').get();
    for (final doc in routines.docs) {
      batch.delete(doc.reference);
    }
    
    // Tasks
    final tasks = await userDoc.collection('tasks').get();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }
    
    // UserStats
    final stats = await userDoc.collection('userStats').get();
    for (final doc in stats.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // ========== TIP MANAGEMENT ==========

  /// Onay bekleyen tip'leri getir (sadece Admin)
  Future<List<Map<String, dynamic>>> getPendingTips() async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    final snapshot = await _firestore
        .collection('tips')
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Tip'i onayla (sadece Admin)
  Future<void> approveTip(String tipId) async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    await _firestore.collection('tips').doc(tipId).update({
      'isApproved': true,
      'approvedBy': _authService.currentUser!.uid,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Tip'i reddet/sil (sadece Admin)
  Future<void> rejectTip(String tipId) async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    await _firestore.collection('tips').doc(tipId).delete();
  }

  // ========== STATISTICS ==========

  /// Sistem istatistiklerini getir (sadece Admin)
  Future<Map<String, dynamic>> getSystemStatistics() async {
    if (!await _authService.isAdmin()) {
      throw Exception('Bu işlem için Admin yetkisi gerekli');
    }

    // Kullanıcı sayıları
    final usersSnapshot = await _firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;
    
    // Rol bazında kullanıcı sayıları
    final adminCount = usersSnapshot.docs.where((d) => d.data()['role'] == 'admin').length;
    final expertCount = usersSnapshot.docs.where((d) => d.data()['role'] == 'expert').length;
    final userCount = usersSnapshot.docs.where((d) => d.data()['role'] == 'user').length;

    // Tip istatistikleri
    final tipsSnapshot = await _firestore.collection('tips').get();
    final totalTips = tipsSnapshot.docs.length;
    final approvedTips = tipsSnapshot.docs.where((d) => d.data()['isApproved'] == true).length;
    final pendingTips = totalTips - approvedTips;

    // Ürün sayısı
    final productsSnapshot = await _firestore.collection('products').get();
    final totalProducts = productsSnapshot.docs.length;

    return {
      'users': {
        'total': totalUsers,
        'admin': adminCount,
        'expert': expertCount,
        'user': userCount,
      },
      'tips': {
        'total': totalTips,
        'approved': approvedTips,
        'pending': pendingTips,
      },
      'products': {
        'total': totalProducts,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}

