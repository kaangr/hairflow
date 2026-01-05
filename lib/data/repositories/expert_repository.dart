import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../domain/entities/tip.dart';

/// Expert Repository - Expert yetkisi gerektiren işlemler
class ExpertRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ========== TIPS MANAGEMENT ==========

  /// Yeni tip oluştur (Expert/Admin)
  Future<String> createTip(Tip tip) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final docRef = await _firestore.collection('tips').add({
      'title': tip.title,
      'content': tip.content,
      'category': tip.category.toString().split('.').last,
      'imageUrl': tip.imageUrl,
      'authorId': _authService.currentUser!.uid,
      'isApproved': false, // Admin onayı bekler
      'isFavorite': false,
      'viewCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Kendi tip'lerini getir (Expert/Admin)
  Future<List<Map<String, dynamic>>> getMyTips() async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final snapshot = await _firestore
        .collection('tips')
        .where('authorId', isEqualTo: _authService.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Kendi tip'ini güncelle (Expert/Admin)
  Future<void> updateTip(String tipId, Tip tip) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    // Ownership kontrolü
    final tipDoc = await _firestore.collection('tips').doc(tipId).get();
    if (!tipDoc.exists) {
      throw Exception('Tip bulunamadı');
    }

    final authorId = tipDoc.data()?['authorId'] as String?;
    if (authorId != _authService.currentUser!.uid && !await _authService.isAdmin()) {
      throw Exception('Bu tip\'i düzenleme yetkiniz yok');
    }

    await _firestore.collection('tips').doc(tipId).update({
      'title': tip.title,
      'content': tip.content,
      'category': tip.category.toString().split('.').last,
      'imageUrl': tip.imageUrl,
      'isApproved': false, // Düzenleme sonrası tekrar onay gerekir
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kendi tip'ini sil (Expert/Admin)
  Future<void> deleteTip(String tipId) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    // Ownership kontrolü
    final tipDoc = await _firestore.collection('tips').doc(tipId).get();
    if (!tipDoc.exists) {
      throw Exception('Tip bulunamadı');
    }

    final authorId = tipDoc.data()?['authorId'] as String?;
    if (authorId != _authService.currentUser!.uid && !await _authService.isAdmin()) {
      throw Exception('Bu tip\'i silme yetkiniz yok');
    }

    await _firestore.collection('tips').doc(tipId).delete();
  }

  // ========== PRODUCTS MANAGEMENT ==========

  /// Yeni ürün oluştur (Expert/Admin)
  Future<String> createProduct(Map<String, dynamic> productData) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final docRef = await _firestore.collection('products').add({
      ...productData,
      'createdBy': _authService.currentUser!.uid,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Ürünleri listele (Expert/Admin)
  Future<List<Map<String, dynamic>>> getProducts() async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final snapshot = await _firestore
        .collection('products')
        .orderBy('category')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Ürün güncelle (Expert/Admin)
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    await _firestore.collection('products').doc(productId).update({
      ...productData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ürün sil (Expert/Admin)
  Future<void> deleteProduct(String productId) async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    await _firestore.collection('products').doc(productId).delete();
  }

  // ========== ANALYTICS ==========

  /// Tüm kullanıcıların rutinlerini görüntüle (analiz için) (Expert/Admin)
  Future<List<Map<String, dynamic>>> getAllRoutines() async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final usersSnapshot = await _firestore.collection('users').get();
    final allRoutines = <Map<String, dynamic>>[];

    for (final userDoc in usersSnapshot.docs) {
      final routinesSnapshot = await userDoc.reference
          .collection('routines')
          .get();

      for (final routineDoc in routinesSnapshot.docs) {
        allRoutines.add({
          'id': routineDoc.id,
          'userId': userDoc.id,
          'userEmail': userDoc.data()['email'],
          'userName': userDoc.data()['displayName'],
          ...routineDoc.data(),
        });
      }
    }

    return allRoutines;
  }

  /// Expert istatistikleri
  Future<Map<String, dynamic>> getExpertStats() async {
    if (!await _authService.isExpert()) {
      throw Exception('Bu işlem için Expert yetkisi gerekli');
    }

    final myTips = await getMyTips();
    final approvedTips = myTips.where((t) => t['isApproved'] == true).length;
    final pendingTips = myTips.length - approvedTips;

    return {
      'myTips': {
        'total': myTips.length,
        'approved': approvedTips,
        'pending': pendingTips,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}

