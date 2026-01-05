# Firebase'e 3 Rollü Sistem Ekleme

## Mevcut Durum vs Olması Gereken

### ❌ Şu An (Eksik)

```
Firestore:
users/
  {userId}/
    - email
    - displayName
    - photoURL
    - createdAt
    routines/
    tasks/
    userStats/
```

**Problem:** Rol yok, herkes sadece "User"

### ✅ Olması Gereken (Rol Sistemi)

```
Firestore:
users/
  {userId}/
    - email
    - displayName
    - photoURL
    - role: "user" | "expert" | "admin"  ← YENİ!
    - roleId: 3                           ← YENİ!
    - createdAt
    routines/        ← Sadece role="user" için
    tasks/          ← Sadece role="user" için
    userStats/

tips/              ← Sadece role="expert" ve "admin" oluşturabilir
  {tipId}/
    - title
    - content
    - authorId       ← Expert'in user ID'si
    - isApproved     ← Admin onayı
    - approvedBy     ← Admin'in user ID'si

products/          ← Sadece role="expert" ve "admin" oluşturabilir
  {productId}/
    - name
    - description
    - createdBy      ← Expert'in user ID'si
```

---

## Firestore Security Rules (Rol Bazlı)

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    function isAdmin() {
      return isSignedIn() && getUserRole() == 'admin';
    }
    
    function isExpert() {
      return isSignedIn() && (getUserRole() == 'expert' || getUserRole() == 'admin');
    }
    
    function isUser() {
      return isSignedIn() && getUserRole() == 'user';
    }
    
    // ========== USERS ==========
    match /users/{userId} {
      // READ: Herkes kendi profilini okuyabilir, Admin herkesi okuyabilir
      allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());
      
      // CREATE: Kayıt sırasında otomatik oluşur
      allow create: if isSignedIn() && request.auth.uid == userId;
      
      // UPDATE: Kullanıcı kendi profilini güncelleyebilir (rol hariç!)
      allow update: if isSignedIn() && request.auth.uid == userId 
                    && request.resource.data.role == resource.data.role; // Rol değiştiremez!
      
      // DELETE: Sadece Admin silebilir
      allow delete: if isAdmin();
      
      // ========== USER ROUTINES ==========
      match /routines/{routineId} {
        // User sadece kendi rutinlerini yönetebilir
        // Expert ve Admin tüm rutinleri okuyabilir (analiz için)
        allow read: if isSignedIn() && (request.auth.uid == userId || isExpert());
        allow create, update, delete: if isSignedIn() && request.auth.uid == userId;
      }
      
      // ========== USER TASKS ==========
      match /tasks/{taskId} {
        allow read: if isSignedIn() && (request.auth.uid == userId || isExpert());
        allow create, update, delete: if isSignedIn() && request.auth.uid == userId;
      }
      
      // ========== USER STATS ==========
      match /userStats/{docId} {
        allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());
        allow write: if isSignedIn() && request.auth.uid == userId;
      }
    }
    
    // ========== TIPS ==========
    match /tips/{tipId} {
      // READ: Herkes onaylı tip'leri okuyabilir
      allow read: if isSignedIn() && (resource.data.isApproved == true || isExpert());
      
      // CREATE: Sadece Expert ve Admin oluşturabilir
      allow create: if isExpert() && 
                    request.resource.data.authorId == request.auth.uid &&
                    request.resource.data.isApproved == false; // Başlangıçta onaysız
      
      // UPDATE: Kendi tip'ini güncelleyebilir (onayı sıfırlanır) VEYA Admin onaylayabilir
      allow update: if (isExpert() && resource.data.authorId == request.auth.uid) 
                    || isAdmin();
      
      // DELETE: Kendi tip'ini veya Admin silebilir
      allow delete: if (isExpert() && resource.data.authorId == request.auth.uid) 
                    || isAdmin();
    }
    
    // ========== PRODUCTS ==========
    match /products/{productId} {
      // READ: Herkes okuyabilir
      allow read: if isSignedIn();
      
      // CREATE, UPDATE, DELETE: Sadece Expert ve Admin
      allow create, update, delete: if isExpert();
    }
  }
}
```

---

## Kod: Firebase'e Rol Ekleme

### 1. User Kayıt Olduğunda Rol Atama

```dart
// lib/core/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/role.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final UserCredential userCredential = 
        await _firebaseAuth.signInWithPopup(googleProvider);
    
    if (userCredential.user != null) {
      // Firestore'da kullanıcı bilgisi oluştur/güncelle
      await _createOrUpdateFirestoreUser(userCredential.user!);
    }
    
    return userCredential.user;
  }

  Future<void> _createOrUpdateFirestoreUser(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Yeni kullanıcı - default role: User
      await userDoc.set({
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoURL': firebaseUser.photoURL,
        'role': 'user',          // ← YENİ! Default: user
        'roleId': 3,             // ← YENİ! Role.userRole.id
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // UserStats oluştur
      await userDoc.collection('userStats').doc('stats').set({
        'totalXP': 0,
        'currentLevel': 1,
        'currentStreak': 0,
        'longestStreak': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Mevcut kullanıcı - son giriş güncelle
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Kullanıcının rolünü getir
  Future<String> getUserRole() async {
    final user = currentUser;
    if (user == null) return 'guest';

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['role'] as String? ?? 'user';
  }

  // Admin kontrolü
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Expert kontrolü
  Future<bool> isExpert() async {
    final role = await getUserRole();
    return role == 'expert' || role == 'admin';
  }
}
```

### 2. Admin: Rol Değiştirme

```dart
// lib/data/repositories/admin_firebase_repository.dart

class AdminFirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ADMIN: Kullanıcının rolünü değiştir
  Future<void> changeUserRole(String userId, Role newRole) async {
    // Sadece admin yapabilir
    if (!await _authService.isAdmin()) {
      throw UnauthorizedException('Bu işlem için admin yetkisi gerekli');
    }

    await _firestore.collection('users').doc(userId).update({
      'role': newRole.name.toLowerCase(),
      'roleId': newRole.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ADMIN: Tüm kullanıcıları listele
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (!await _authService.isAdmin()) {
      throw UnauthorizedException();
    }

    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // ADMIN: Tip onayla
  Future<void> approveTip(String tipId) async {
    if (!await _authService.isAdmin()) {
      throw UnauthorizedException();
    }

    await _firestore.collection('tips').doc(tipId).update({
      'isApproved': true,
      'approvedBy': _authService.currentUser!.uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  // ADMIN: Onay bekleyen tip'leri getir
  Future<List<Map<String, dynamic>>> getPendingTips() async {
    if (!await _authService.isAdmin()) {
      throw UnauthorizedException();
    }

    final snapshot = await _firestore
        .collection('tips')
        .where('isApproved', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }
}
```

### 3. Expert: İçerik Oluşturma

```dart
// lib/data/repositories/expert_firebase_repository.dart

class ExpertFirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // EXPERT: Yeni tip oluştur (onay bekler)
  Future<String> createTip(Tip tip) async {
    if (!await _authService.isExpert()) {
      throw UnauthorizedException('Bu işlem için expert yetkisi gerekli');
    }

    final docRef = await _firestore.collection('tips').add({
      'title': tip.title,
      'content': tip.content,
      'category': tip.category.toString().split('.').last,
      'imageUrl': tip.imageUrl,
      'authorId': _authService.currentUser!.uid,
      'isApproved': false, // Admin onayı bekliyor
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // EXPERT: Kendi tip'lerini getir
  Future<List<Map<String, dynamic>>> getMyTips() async {
    if (!await _authService.isExpert()) {
      throw UnauthorizedException();
    }

    final snapshot = await _firestore
        .collection('tips')
        .where('authorId', isEqualTo: _authService.currentUser!.uid)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // EXPERT: Yeni ürün oluştur
  Future<String> createProduct(Map<String, dynamic> productData) async {
    if (!await _authService.isExpert()) {
      throw UnauthorizedException();
    }

    final docRef = await _firestore.collection('products').add({
      ...productData,
      'createdBy': _authService.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // EXPERT: Tüm rutinleri görüntüle (analiz için)
  Future<List<Map<String, dynamic>>> getAllRoutines() async {
    if (!await _authService.isExpert()) {
      throw UnauthorizedException();
    }

    // Tüm kullanıcıların rutinlerini getir
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
          ...routineDoc.data(),
        });
      }
    }

    return allRoutines;
  }
}
```

---

## Özet: Firebase + SQLite Kombinasyonu

### SQLite (Local - İlişkisel)
✅ Akademik gereksinim için
✅ Foreign Keys, Indexes
✅ Offline çalışma
✅ Code First (Entity → Table)

### Firebase (Cloud - NoSQL)
✅ Cloud backup
✅ Senkronizasyon
✅ Real-time updates
✅ Rol bazlı Security Rules

### Birlikte Çalışma

```dart
// Rutin oluşturulduğunda:

// 1. SQLite'a kaydet (local, ilişkisel)
final localId = await sqliteDb.insert('routines', {
  'user_id': currentUserId,
  'name': 'Sabah Rutinim',
  // Foreign Key: user_id → users.id
});

// 2. Firebase'e senkronize et (cloud, NoSQL)
final firebaseId = await firestore
    .collection('users')
    .doc(currentUserUid)
    .collection('routines')
    .add({
      'name': 'Sabah Rutinim',
      // Rol kontrolü: Security Rules ile
    });
```

**Sonuç:**
- ✅ Akademik gereksinimler: SQLite (ilişkisel, 3 rol, CRUD)
- ✅ Production özellikler: Firebase (cloud, sync, backup)
- ✅ İkisi birlikte çalışıyor!

