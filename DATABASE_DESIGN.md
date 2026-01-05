# HairFlow - İlişkisel Veritabanı Tasarımı

## Veritabanı Yaklaşımı

**Teknoloji:** 
- **Mobile:** SQLite (sqflite paketi) - Code First
- **Web:** SharedPreferences + Firebase Firestore
- **Cloud Sync:** Firebase Firestore

**Yaklaşım:** Code First (Dart Entity sınıflarından otomatik tablo oluşturma)

---

## 3 Rollü Sistem

### Roller ve Yetkileri

| Rol | Açıklama | Yetkiler |
|-----|----------|----------|
| **Admin** | Sistem yöneticisi | Tüm CRUD işlemleri, kullanıcı yönetimi, içerik onaylama |
| **Expert** | Uzman/Danışman | İçerik oluşturma (tips, products), tüm rutinleri görüntüleme |
| **User** | Normal kullanıcı | Kendi rutinlerini yönetme, içerikleri görüntüleme |

---

## Veritabanı Şeması (İlişkisel)

### Entity Relationship Diagram

```
┌─────────────────┐         ┌─────────────────┐
│     roles       │         │     users       │
├─────────────────┤         ├─────────────────┤
│ PK: id          │◄────────│ FK: role_id     │
│     name        │   1:N   │ PK: id          │
│     description │         │     email       │
└─────────────────┘         │     uid         │
                            │     full_name   │
                            │     created_at  │
                            └────────┬────────┘
                                     │ 1:1
                            ┌────────▼────────┐
                            │   user_stats    │
                            ├─────────────────┤
                            │ FK: user_id     │
                            │ PK: id          │
                            │     total_xp    │
                            │     streak      │
                            │     level       │
                            └─────────────────┘
                                     │ 1:N
                            ┌────────▼────────┐
                            │   routines      │
                            ├─────────────────┤
                            │ FK: user_id     │
                            │ PK: id          │
                            │     name        │
                            │     description │
                            └────────┬────────┘
                                     │ 1:N
                            ┌────────▼────────────┐
                            │  routine_tasks      │
                            ├─────────────────────┤
                            │ FK: routine_id      │
                            │ PK: id              │
                            │     title           │
                            │     is_completed    │
                            │     date            │
                            └─────────────────────┘

┌─────────────────┐         ┌─────────────────┐
│     tips        │         │   products      │
├─────────────────┤         ├─────────────────┤
│ FK: author_id   │         │ FK: created_by  │
│ PK: id          │         │ PK: id          │
│     title       │         │     name        │
│     content     │         │     description │
│     category    │         │     category    │
│     is_approved │         │     usage_info  │
└─────────────────┘         └─────────────────┘
```

---

## Tablo Detayları

### 1. roles (Roller)

```sql
CREATE TABLE roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TEXT NOT NULL
);
```

**Varsayılan Veriler:**
```dart
static const List<Map<String, dynamic>> defaultRoles = [
  {'id': 1, 'name': 'Admin', 'description': 'Sistem yöneticisi'},
  {'id': 2, 'name': 'Expert', 'description': 'İçerik uzmanı'},
  {'id': 3, 'name': 'User', 'description': 'Normal kullanıcı'},
];
```

### 2. users (Kullanıcılar)

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    uid TEXT UNIQUE,              -- Firebase UID
    full_name TEXT,
    role_id INTEGER NOT NULL DEFAULT 3,  -- Default: User
    is_active INTEGER DEFAULT 1,
    email_verified INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    last_login TEXT,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_users_uid ON users(uid);
```

**İlişkiler:**
- `role_id` → `roles.id` (N:1)
- Her kullanıcının 1 rolü var
- Her rol birden fazla kullanıcıya sahip olabilir

### 3. user_stats (Kullanıcı İstatistikleri)

```sql
CREATE TABLE user_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    total_xp INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_tasks_completed INTEGER DEFAULT 0,
    last_completion_date TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_user_stats_user_id ON user_stats(user_id);
```

**İlişkiler:**
- `user_id` → `users.id` (1:1)
- Her kullanıcının tek bir stats kaydı var

### 4. routines (Rutinler)

```sql
CREATE TABLE routines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_routines_user_id ON routines(user_id);
```

**İlişkiler:**
- `user_id` → `users.id` (N:1)
- Her rutin bir kullanıcıya ait
- Kullanıcı silinirse rutinleri de silinir (CASCADE)

### 5. routine_tasks (Rutin Görevleri)

```sql
CREATE TABLE routine_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    routine_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    order_index INTEGER DEFAULT 0,
    date TEXT NOT NULL,
    scheduled_time TEXT,
    is_completed INTEGER DEFAULT 0,
    completed_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE
);

CREATE INDEX idx_tasks_routine_id ON routine_tasks(routine_id);
CREATE INDEX idx_tasks_date ON routine_tasks(date);
CREATE INDEX idx_tasks_is_completed ON routine_tasks(is_completed);
```

**İlişkiler:**
- `routine_id` → `routines.id` (N:1)
- Her görev bir rutine ait
- Rutin silinirse görevleri de silinir (CASCADE)

### 6. tips (İpuçları)

```sql
CREATE TABLE tips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT,
    image_url TEXT,
    author_id INTEGER NOT NULL,
    is_approved INTEGER DEFAULT 0,
    is_favorite INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    approved_at TEXT,
    approved_by INTEGER,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_tips_author_id ON tips(author_id);
CREATE INDEX idx_tips_is_approved ON tips(is_approved);
CREATE INDEX idx_tips_category ON tips(category);
```

**İlişkiler:**
- `author_id` → `users.id` (N:1) - Expert tarafından oluşturulur
- `approved_by` → `users.id` (N:1) - Admin tarafından onaylanır
- Yazar silinirse tip'leri de silinir
- Onaylayan silinirse sadece approved_by NULL olur

### 7. products (Ürünler)

```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    usage_instructions TEXT,
    dosage TEXT,
    price REAL,
    image_url TEXT,
    is_active INTEGER DEFAULT 1,
    created_by INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_is_active ON products(is_active);
```

**İlişkiler:**
- `created_by` → `users.id` (N:1) - Expert tarafından oluşturulur
- Oluşturan silinirse sadece created_by NULL olur

---

## Rol Bazlı CRUD Operasyonları

### Admin Rolü (role_id = 1)

**Yetkiler:**

#### ✅ USERS - Tam CRUD
- `CREATE` - Yeni kullanıcı ekleme
- `READ` - Tüm kullanıcıları listeleme
- `UPDATE` - Kullanıcı bilgilerini güncelleme
- `DELETE` - Kullanıcı silme
- **Özel:** Rol değiştirme

#### ✅ TIPS - Onaylama Yetkisi
- `READ` - Tüm tip'leri görme (onaylı/onaysız)
- `UPDATE` - Tip onaylama/reddetme (`is_approved` değiştirme)
- `DELETE` - İstenmeyen tip'leri silme

#### ✅ PRODUCTS - Tam CRUD
- `CREATE` - Yeni ürün ekleme
- `READ` - Tüm ürünleri görme
- `UPDATE` - Ürün bilgilerini güncelleme
- `DELETE` - Ürün silme

#### ✅ ROUTINES - Tüm Rutinleri Görme
- `READ` - Tüm kullanıcıların rutinlerini görme (analiz için)

#### ✅ STATISTICS - Sistem İstatistikleri
- Toplam kullanıcı sayısı
- Toplam rutin/görev sayısı
- Onay bekleyen tip sayısı
- Kullanıcı aktivite raporu

### Expert Rolü (role_id = 2)

**Yetkiler:**

#### ✅ TIPS - Tam CRUD (Kendi İçerikleri)
- `CREATE` - Yeni tip oluşturma (onay bekler)
- `READ` - Kendi tip'lerini ve onaylanmış tip'leri görme
- `UPDATE` - Kendi tip'lerini güncelleme (tekrar onay gerekir)
- `DELETE` - Kendi tip'lerini silme

#### ✅ PRODUCTS - Tam CRUD
- `CREATE` - Yeni ürün ekleme
- `READ` - Tüm ürünleri görme
- `UPDATE` - Ürün bilgilerini güncelleme
- `DELETE` - Ürün silme

#### ✅ ROUTINES - Sadece Okuma (Analiz)
- `READ` - Tüm kullanıcıların rutinlerini görme (danışmanlık için)

#### ❌ Yasak İşlemler
- Kullanıcı yönetimi
- Tip onaylama
- Diğer expert'lerin içeriklerini silme/güncelleme

### User Rolü (role_id = 3)

**Yetkiler:**

#### ✅ PROFILE - Kendi Profili
- `READ` - Kendi profilini görme
- `UPDATE` - Kendi profilini güncelleme

#### ✅ ROUTINES - Tam CRUD (Kendi Rutinleri)
- `CREATE` - Yeni rutin oluşturma (+25 XP)
- `READ` - Kendi rutinlerini listeleme
- `UPDATE` - Kendi rutinlerini güncelleme
- `DELETE` - Kendi rutinlerini silme

#### ✅ TASKS - Tam CRUD (Kendi Görevleri)
- `CREATE` - Yeni görev ekleme
- `READ` - Kendi görevlerini listeleme
- `UPDATE` - Görev durumunu güncelleme (+10 XP tamamlayınca)
- `DELETE` - Görev silme

#### ✅ TIPS - Sadece Okuma
- `READ` - Onaylanmış tip'leri görme

#### ✅ PRODUCTS - Sadece Okuma
- `READ` - Aktif ürünleri görme

#### ✅ STATISTICS - Kendi İstatistikleri
- XP, Level, Streak
- Tamamlanan görev sayısı
- Aktif rutin sayısı

#### ❌ Yasak İşlemler
- Başkalarının rutinlerine erişim
- İçerik oluşturma/düzenleme
- Kullanıcı yönetimi

---

## Veri Akışı

### 1. User Kayıt Olduğunda

```dart
// Firebase Authentication ile kayıt
User firebaseUser = await FirebaseAuth.signInWithGoogle();

// Local SQLite'a kullanıcı ekle
await db.insert('users', {
  'email': firebaseUser.email,
  'uid': firebaseUser.uid,
  'full_name': firebaseUser.displayName,
  'role_id': 3, // Default: User
  'created_at': DateTime.now().toIso8601String(),
});

// Otomatik user_stats oluştur
await db.insert('user_stats', {
  'user_id': userId,
  'total_xp': 0,
  'current_level': 1,
  'created_at': DateTime.now().toIso8601String(),
});
```

### 2. User Rutin Oluşturduğunda

```dart
// 1. Routine oluştur
final routineId = await db.insert('routines', {
  'user_id': currentUserId,
  'name': 'Sabah Rutinim',
  'description': 'Günlük sabah bakım',
  'created_at': DateTime.now().toIso8601String(),
});

// 2. XP ekle
await db.rawUpdate('''
  UPDATE user_stats 
  SET total_xp = total_xp + 25,
      current_level = (total_xp / 100) + 1
  WHERE user_id = ?
''', [currentUserId]);

// 3. Firebase'e senkronize et
await FirestoreService().createRoutine(routine);
```

### 3. User Görev Tamamladığında

```dart
// 1. Task'ı tamamla
await db.update('routine_tasks', 
  {
    'is_completed': 1,
    'completed_at': DateTime.now().toIso8601String(),
  },
  where: 'id = ?',
  whereArgs: [taskId],
);

// 2. XP ekle ve streak güncelle
await db.rawUpdate('''
  UPDATE user_stats 
  SET total_xp = total_xp + 10,
      total_tasks_completed = total_tasks_completed + 1,
      last_completion_date = ?
  WHERE user_id = ?
''', [DateTime.now().toIso8601String(), currentUserId]);

// 3. Streak kontrolü
await updateStreak(currentUserId);
```

### 4. Expert İçerik Oluşturduğunda

```dart
// Tip oluştur (onay bekler)
await db.insert('tips', {
  'title': 'Minoxidil Kullanım Rehberi',
  'content': '...',
  'category': 'product',
  'author_id': expertUserId,
  'is_approved': 0, // Admin onayı bekliyor
  'created_at': DateTime.now().toIso8601String(),
});
```

### 5. Admin İçerik Onayladığında

```dart
// Tip'i onayla
await db.update('tips',
  {
    'is_approved': 1,
    'approved_by': adminUserId,
    'approved_at': DateTime.now().toIso8601String(),
  },
  where: 'id = ?',
  whereArgs: [tipId],
);
```

---

## Sorgu Örnekleri

### Role'e Göre Kullanıcı Sayısı

```dart
final result = await db.rawQuery('''
  SELECT r.name as role_name, COUNT(u.id) as user_count
  FROM roles r
  LEFT JOIN users u ON r.id = u.role_id
  GROUP BY r.id, r.name
''');
```

### Kullanıcının Günlük Tamamlama Oranı

```dart
final result = await db.rawQuery('''
  SELECT 
    DATE(date) as task_date,
    COUNT(*) as total_tasks,
    SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_tasks,
    ROUND(
      SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
      2
    ) as completion_percentage
  FROM routine_tasks rt
  JOIN routines r ON rt.routine_id = r.id
  WHERE r.user_id = ?
  GROUP BY DATE(date)
  ORDER BY task_date DESC
  LIMIT 30
''', [userId]);
```

### En Aktif Kullanıcılar (XP'ye göre)

```dart
final result = await db.rawQuery('''
  SELECT 
    u.full_name,
    us.total_xp,
    us.current_level,
    us.current_streak,
    us.total_tasks_completed
  FROM users u
  JOIN user_stats us ON u.id = us.user_id
  ORDER BY us.total_xp DESC
  LIMIT 10
''');
```

### Onay Bekleyen Tips (Admin için)

```dart
final result = await db.rawQuery('''
  SELECT 
    t.id,
    t.title,
    t.category,
    u.full_name as author_name,
    t.created_at
  FROM tips t
  JOIN users u ON t.author_id = u.id
  WHERE t.is_approved = 0
  ORDER BY t.created_at ASC
''');
```

---

## Özet

✅ **İlişkisel Veritabanı:** SQLite ile tam ilişkisel yapı (Foreign Keys, Indexes)
✅ **3 Rollü Sistem:** Admin, Expert, User (role_id ile kontrol)
✅ **CRUD Operasyonları:** Her rol için detaylı CRUD yetkileri
✅ **Code First:** Dart Entity sınıflarından tablo oluşturma
✅ **Platform Agnostic:** Mobile (SQLite) + Web (SharedPreferences) + Cloud (Firebase)
✅ **Gamification:** XP, Level, Streak sistemi ile ilişkisel bağlantılar

**Teknoloji:** Flutter + Dart + SQLite (sqflite) + Firebase

