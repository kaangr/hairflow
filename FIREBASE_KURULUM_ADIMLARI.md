# Firebase Kurulum Adımları - HIZLI BAŞLANGIÇ

## 🚀 Hızlı Adımlar

### 1. Uygulamayı Çalıştır ve Giriş Yap

```bash
flutter run -d chrome
# veya
flutter run -d android
```

**Uygulamadan Google ile giriş yap!**

### 2. Console/Terminal'i İzle

Giriş yaptıktan sonra **terminal/console'da** şöyle bir çıktı göreceksin:

```
═══════════════════════════════════════════
🔐 KULLANICI GİRİŞ YAPTI
═══════════════════════════════════════════
User ID (UID):  abc123xyz789...  ← BU ÖNEMLİ!
Email:          senin@email.com
Display Name:   Senin Adın
Role:           user
Role ID:        3
Is Admin:       false
Is Expert:      false
═══════════════════════════════════════════

📝 Firebase Console'da Admin yapmak için:
1. https://console.firebase.google.com
2. Firestore Database → Data
3. users → abc123xyz789...
4. Edit document (kalem ikonu)
5. Ekle: role = "admin", roleId = 1
6. Update butonuna bas
═══════════════════════════════════════════
```

### 3. User ID'yi Kopyala

Terminal'den **User ID (UID)** değerini kopyala: `abc123xyz789...`

### 4. Firebase Console'a Git

1. Tarayıcıda aç: https://console.firebase.google.com
2. **hairflow** projesini seç
3. Sol menüden **Firestore Database** → **Data** sekmesi

### 5. Kullanıcıyı Bul ve Admin Yap

1. `users` collection'ına tıkla
2. Kopyaladığın User ID'yi bul (örn: `abc123xyz789...`)
3. O dökümanın üzerine tıkla
4. Sağ üstte **kalem ikonu** (Edit document) → tıkla
5. Şu field'ları ekle/düzenle:

```
role      (string):  admin
roleId    (number):  1
```

6. **Update** butonuna bas

### 6. Uygulamayı Yeniden Başlat

```bash
# Uygulamayı kapat ve tekrar çalıştır
flutter run -d chrome
```

Tekrar giriş yap ve terminal'de şunu göreceksin:

```
Role:           admin  ← DEĞİŞTİ!
Role ID:        1      ← DEĞİŞTİ!
Is Admin:       true   ← DEĞİŞTİ!
```

---

## ✅ Tamamlandı!

Artık **Admin** yetkileriniz var! 

### Test Et:

```dart
// Herhangi bir ekranda test et:
final authService = context.read<AuthService>();
final isAdmin = await authService.isAdmin();
print('Admin miyim? $isAdmin'); // true olmalı!
```

---

## 🔧 Firebase Rules Deploy (Önemli!)

Security rules'u deploy et:

```bash
cd /home/kaan/Programming/hairflow
firebase deploy --only firestore:rules
```

**VEYA** Firebase Console'dan manuel:

1. **Firestore Database** → **Rules** sekmesi
2. Projedeki `firestore.rules` dosyasını kopyala-yapıştır
3. **Publish** butonuna bas

---

## 🎯 Sonraki Adımlar

### Admin Olarak Yapabileceklerin:

```dart
// Admin Repository kullan
final adminRepo = AdminRepository();

// 1. Tüm kullanıcıları listele
final users = await adminRepo.getAllUsers();
print('Toplam kullanıcı: ${users.length}');

// 2. Başka birine Expert rolü ver
await adminRepo.changeUserRole(userId, Role.expert);

// 3. Tip onayla
await adminRepo.approveTip(tipId);

// 4. Sistem istatistikleri
final stats = await adminRepo.getSystemStatistics();
print('İstatistikler: $stats');
```

### Expert Rolü Ver (Admin Console'dan):

1. Başka bir kullanıcının giriş yapmasını sağla
2. O kullanıcının User ID'sini al (terminal'den)
3. Firebase Console'da o user'ı bul
4. Ekle: `role = "expert"`, `roleId = 2`

---

## 🐛 Debug Screen (Bonus)

Uygulamada **Settings** → **🔍 Debug - Kullanıcı Bilgileri** ekranı eklendi!

Bu ekranda:
- User ID'yi görebilir ve kopyalayabilirsin
- Role bilgilerini görebilirsin
- Admin yapma talimatlarını görebilirsin

Kod: `lib/presentation/screens/debug_screen.dart`

---

## 📝 Önemli Notlar

1. **İlk admin'i manuel ekliyorsun** (Firebase Console'dan)
2. **Sonraki admin/expert'leri** ilk admin atayabilir
3. **Security rules** mutlaka deploy edilmeli
4. **Terminal çıktısını** izle, User ID orada yazıyor

---

## 🚨 Sorun mu Var?

### Terminal'de User ID görmüyorum?

**Çözüm:** AuthProvider'da print kodları eklendi. Uygulamayı yeniden başlat:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Firebase'de users collection yok?

**Çözüm:** Google Sign-In yap, otomatik oluşacak!

### Role değişmedi?

**Çözüm:** 
1. Firebase Console'da `role` ve `roleId` field'larını kontrol et
2. Uygulamayı **tamamen** kapat ve tekrar aç
3. Chrome'da F5 ile yenile

---

## 📄 İlgili Dosyalar

- ✅ `lib/core/services/auth_service.dart` - Rol kontrolü eklendi
- ✅ `lib/presentation/providers/auth_provider.dart` - Print eklendi
- ✅ `lib/presentation/screens/debug_screen.dart` - Debug ekranı (YENİ!)
- ✅ `lib/data/repositories/admin_repository.dart` - Admin CRUD
- ✅ `lib/data/repositories/expert_repository.dart` - Expert CRUD
- ✅ `firestore.rules` - Security rules

**Tüm kodlar eklendi! Sadece Firebase Console'dan admin yapman kaldı!** 🚀
