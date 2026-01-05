# Backend CRUD Dokümantasyonu

## Veritabanı ve Mimari

**Teknoloji:** Flutter + Dart + SQLite (sqflite) + Firebase Firestore  
**Yaklaşım:** Code First (Entity sınıflarından otomatik tablo oluşturma)  
**Platform:** Mobile (SQLite) + Web (SharedPreferences) + Cloud (Firebase)

---

## İlişkisel Veritabanı Tabloları

### Detaylı şema için: [DATABASE_DESIGN.md](./DATABASE_DESIGN.md)

**7 Ana Tablo:**
1. `roles` - Rol tanımları
2. `users` - Kullanıcılar (Foreign Key: role_id)
3. `user_stats` - İstatistikler (Foreign Key: user_id)
4. `routines` - Rutinler (Foreign Key: user_id)
5. `routine_tasks` - Görevler (Foreign Key: routine_id)
6. `tips` - İçerikler (Foreign Key: author_id, approved_by)
7. `products` - Ürünler (Foreign Key: created_by)

---

## 3 Rollü Sistem

### 1. Admin (role_id = 1)

**CRUD Yetkileri:**

| Entity | CREATE | READ | UPDATE | DELETE | Özel Yetkiler |
|--------|--------|------|--------|--------|---------------|
| Users | ✅ | ✅ Tümü | ✅ Tümü | ✅ | Rol değiştirme |
| Tips | ❌ | ✅ Tümü | ✅ Onaylama | ✅ | İçerik moderasyonu |
| Products | ✅ | ✅ Tümü | ✅ Tümü | ✅ | - |
| Routines | ❌ | ✅ Tümü | ❌ | ❌ | Sadece görüntüleme |
| Tasks | ❌ | ✅ Tümü | ❌ | ❌ | Analiz için |

**Kod Örneği - User Yönetimi:**

```dart
// lib/data/repositories/admin_repository.dart

class AdminRepository {
  final LocalDataSource _dataSource;

  // CREATE - Yeni kullanıcı oluştur
  Future<int> createUser(AppUser user) async {
    // Sadece admin yetkisi kontrolü
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    return await _dataSource.insertUser(user.toModel());
  }

  // READ - Tüm kullanıcıları listele
  Future<List<AppUser>> getAllUsers() async {
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    final users = await _dataSource.getAllUsers();
    return users.map((model) => model.toEntity()).toList();
  }

  // UPDATE - Kullanıcı güncelle
  Future<void> updateUser(AppUser user) async {
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    await _dataSource.updateUser(user.toModel());
  }

  // DELETE - Kullanıcı sil
  Future<void> deleteUser(int userId) async {
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    await _dataSource.deleteUser(userId);
  }

  // SPECIAL - Rol değiştir
  Future<void> changeUserRole(int userId, Role newRole) async {
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    await _dataSource.updateUserRole(userId, newRole.id);
  }

  // SPECIAL - Tip onayla
  Future<void> approveTip(int tipId) async {
    if (!_currentUserIsAdmin()) throw UnauthorizedException();
    
    await _dataSource.updateTipApproval(tipId, true, _currentUserId);
  }
}
```

**UI Örneği - Admin Paneli:**

```dart
// lib/presentation/screens/admin/admin_dashboard.dart

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Rol kontrolü
    if (!authProvider.currentUser!.isAdmin) {
      return UnauthorizedScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel')),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          // User Management
          AdminCard(
            title: 'Kullanıcı Yönetimi',
            icon: Icons.people,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserManagementScreen()),
            ),
          ),
          
          // Content Approval
          AdminCard(
            title: 'İçerik Onaylama',
            icon: Icons.approval,
            badge: pendingTipsCount,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContentApprovalScreen()),
            ),
          ),
          
          // System Statistics
          AdminCard(
            title: 'Sistem İstatistikleri',
            icon: Icons.analytics,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SystemStatsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 2. Expert (role_id = 2)

**CRUD Yetkileri:**

| Entity | CREATE | READ | UPDATE | DELETE | Notlar |
|--------|--------|------|--------|--------|--------|
| Tips | ✅ | ✅ Kendi + Onaylı | ✅ Kendi | ✅ Kendi | Admin onayı gerekir |
| Products | ✅ | ✅ Tümü | ✅ Tümü | ✅ | - |
| Routines | ❌ | ✅ Tümü | ❌ | ❌ | Sadece okuma (analiz) |
| Tasks | ❌ | ✅ Tümü | ❌ | ❌ | Analiz için |

**Kod Örneği - Tip Yönetimi:**

```dart
// lib/data/repositories/expert_repository.dart

class ExpertRepository {
  final LocalDataSource _dataSource;

  // CREATE - Yeni tip oluştur (onay bekler)
  Future<int> createTip(Tip tip) async {
    if (!_currentUserCanCreateContent()) throw UnauthorizedException();
    
    final tipModel = tip.toModel()
      ..authorId = _currentUserId
      ..isApproved = false; // Admin onayı bekliyor
    
    return await _dataSource.insertTip(tipModel);
  }

  // READ - Kendi tip'lerini + Onaylananları getir
  Future<List<Tip>> getTips() async {
    if (!_currentUserCanCreateContent()) throw UnauthorizedException();
    
    final tips = await _dataSource.getTips();
    
    // Expert kendi tip'lerini ve onaylananları görebilir
    return tips.where((tip) => 
      tip.isApproved || tip.authorId == _currentUserId
    ).toList();
  }

  // UPDATE - Kendi tip'ini güncelle (tekrar onay gerekir)
  Future<void> updateTip(Tip tip) async {
    if (!_currentUserCanCreateContent()) throw UnauthorizedException();
    
    final existing = await _dataSource.getTipById(tip.id!);
    if (existing.authorId != _currentUserId) {
      throw UnauthorizedException('Sadece kendi içeriğinizi düzenleyebilirsiniz');
    }
    
    final updatedTip = tip.toModel()
      ..isApproved = false; // Tekrar onay gerekir
    
    await _dataSource.updateTip(updatedTip);
  }

  // DELETE - Kendi tip'ini sil
  Future<void> deleteTip(int tipId) async {
    if (!_currentUserCanCreateContent()) throw UnauthorizedException();
    
    final tip = await _dataSource.getTipById(tipId);
    if (tip.authorId != _currentUserId) {
      throw UnauthorizedException('Sadece kendi içeriğinizi silebilirsiniz');
    }
    
    await _dataSource.deleteTip(tipId);
  }

  // READ - Tüm rutinleri görüntüle (analiz için)
  Future<List<Routine>> getAllRoutines() async {
    if (!_currentUserCanCreateContent()) throw UnauthorizedException();
    
    // Sadece okuma yetkisi, düzenleme yok
    return await _dataSource.getAllRoutines();
  }
}
```

**UI Örneği - Expert Paneli:**

```dart
// lib/presentation/screens/expert/expert_dashboard.dart

class ExpertDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Rol kontrolü
    if (!authProvider.currentUser!.isExpert && !authProvider.currentUser!.isAdmin) {
      return UnauthorizedScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Expert Panel')),
      body: Column(
        children: [
          // Tips Management
          ListTile(
            leading: Icon(Icons.tips_and_updates),
            title: Text('İpuçları Yönetimi'),
            subtitle: Text('İpucu oluştur ve düzenle'),
            trailing: Chip(
              label: Text('${pendingTipsCount} Bekliyor'),
              backgroundColor: Colors.orange,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TipsManagementScreen()),
            ),
          ),
          
          // Products Management
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Ürün Yönetimi'),
            subtitle: Text('Ürün ekle ve düzenle'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductsManagementScreen()),
            ),
          ),
          
          // Routines Analytics
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Rutin Analizi'),
            subtitle: Text('Kullanıcı rutinlerini görüntüle'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RoutinesAnalyticsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTipDialog(context),
        icon: Icon(Icons.add),
        label: Text('Yeni İpucu'),
      ),
    );
  }
}
```

---

### 3. User (role_id = 3)

**CRUD Yetkileri:**

| Entity | CREATE | READ | UPDATE | DELETE | Notlar |
|--------|--------|------|--------|--------|--------|
| Profile | ❌ | ✅ Kendi | ✅ Kendi | ❌ | - |
| Routines | ✅ | ✅ Kendi | ✅ Kendi | ✅ Kendi | +25 XP oluştururken |
| Tasks | ✅ | ✅ Kendi | ✅ Kendi | ✅ Kendi | +10 XP tamamlarken |
| Tips | ❌ | ✅ Onaylı | ❌ | ❌ | Sadece okuma |
| Products | ❌ | ✅ Aktif | ❌ | ❌ | Sadece okuma |
| Statistics | ❌ | ✅ Kendi | ❌ | ❌ | XP, Streak vb. |

**Kod Örneği - Routine CRUD:**

```dart
// lib/data/repositories/routine_repository_impl.dart

class RoutineRepositoryImpl implements RoutineRepository {
  final LocalDataSource _dataSource;

  // CREATE - Yeni rutin oluştur
  @override
  Future<int> createRoutine(Routine routine) async {
    // Kullanıcı sadece kendi rutinini oluşturabilir
    final routineModel = RoutineModel.fromEntity(routine)
      ..userId = _currentUserId;
    
    final id = await _dataSource.insertRoutine(routineModel);
    
    // XP ekle
    await _addXp(25);
    
    return id;
  }

  // READ - Kendi rutinlerini getir
  @override
  Future<List<Routine>> getRoutines() async {
    final routines = await _dataSource.getRoutines();
    
    // Sadece kendi rutinlerini görebilir
    return routines.where((r) => r.userId == _currentUserId).toList();
  }

  // UPDATE - Kendi rutinini güncelle
  @override
  Future<void> updateRoutine(Routine routine) async {
    // Ownership kontrolü
    final existing = await _dataSource.getRoutineById(routine.id!);
    if (existing!.userId != _currentUserId) {
      throw UnauthorizedException('Bu rutini düzenleme yetkiniz yok');
    }
    
    await _dataSource.updateRoutine(RoutineModel.fromEntity(routine));
  }

  // DELETE - Kendi rutinini sil
  @override
  Future<void> deleteRoutine(int id) async {
    // Ownership kontrolü
    final routine = await _dataSource.getRoutineById(id);
    if (routine!.userId != _currentUserId) {
      throw UnauthorizedException('Bu rutini silme yetkiniz yok');
    }
    
    await _dataSource.deleteRoutine(id);
  }

  // CREATE TASK - Yeni görev oluştur
  @override
  Future<int> createTask(RoutineTask task) async {
    // Rutinin ownership kontrolü
    final routine = await _dataSource.getRoutineById(task.routineId);
    if (routine!.userId != _currentUserId) {
      throw UnauthorizedException();
    }
    
    return await _dataSource.insertTask(RoutineTaskModel.fromEntity(task));
  }

  // MARK COMPLETED - Görevi tamamla
  @override
  Future<void> markTaskCompleted(int id, bool isCompleted) async {
    final task = await _dataSource.getTaskById(id);
    final routine = await _dataSource.getRoutineById(task!.routineId);
    
    // Ownership kontrolü
    if (routine!.userId != _currentUserId) {
      throw UnauthorizedException();
    }
    
    await _dataSource.markTaskCompleted(id, isCompleted);
    
    if (isCompleted) {
      // XP ekle
      await _addXp(10);
      // Streak güncelle
      await _updateStreak();
    }
  }

  // Helper: XP ekle
  Future<void> _addXp(int xp) async {
    final stats = await _dataSource.getUserStats(_currentUserId);
    stats.totalXp += xp;
    stats.currentLevel = (stats.totalXp / 100).floor() + 1;
    await _dataSource.updateUserStats(stats);
  }

  // Helper: Streak güncelle
  Future<void> _updateStreak() async {
    final stats = await _dataSource.getUserStats(_currentUserId);
    final today = DateTime.now();
    final lastDate = stats.lastCompletionDate;

    if (lastDate != null) {
      final diff = today.difference(lastDate).inDays;
      
      if (diff == 0) {
        return; // Bugün zaten güncellendi
      } else if (diff == 1) {
        // Streak devam ediyor
        stats.currentStreak++;
      } else {
        // Streak kırıldı
        stats.currentStreak = 1;
      }
    } else {
      stats.currentStreak = 1;
    }

    if (stats.currentStreak > stats.longestStreak) {
      stats.longestStreak = stats.currentStreak;
    }

    stats.lastCompletionDate = today;
    await _dataSource.updateUserStats(stats);
  }
}
```

**UI Örneği - Routine CRUD:**

```dart
// lib/presentation/screens/routines_screen.dart

class RoutinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        // Sadece kendi rutinlerini gösterir
        final myRoutines = routineProvider.routines;

        return Scaffold(
          appBar: AppBar(title: Text('Rutinlerim')),
          body: ListView.builder(
            itemCount: myRoutines.length,
            itemBuilder: (context, index) {
              final routine = myRoutines[index];
              return RoutineCard(
                routine: routine,
                onTap: () => _viewRoutineDetail(context, routine),
                onEdit: () => _editRoutine(context, routine),
                onDelete: () => _deleteRoutine(context, routine),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createNewRoutine(context),
            icon: Icon(Icons.add),
            label: Text('Yeni Rutin'),
          ),
        );
      },
    );
  }

  void _createNewRoutine(BuildContext context) {
    // CREATE işlemi
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRoutineScreen(),
      ),
    );
  }

  void _editRoutine(BuildContext context, Routine routine) {
    // UPDATE işlemi
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditRoutineScreen(routine: routine),
      ),
    );
  }

  void _deleteRoutine(BuildContext context, Routine routine) async {
    // DELETE işlemi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rutini Sil'),
        content: Text('${routine.name} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<RoutineProvider>().deleteRoutine(routine.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutin silindi')),
      );
    }
  }
}
```

---

## Özet

### ✅ Gerçekleştirilen Gereksinimler

1. **✅ İlişkisel Veritabanı Tasarımı**
   - SQLite (Code First)
   - 7 tablo, Foreign Keys
   - Indexes

2. **✅ 3 Rollü Sistem**
   - Admin (role_id = 1)
   - Expert (role_id = 2)
   - User (role_id = 3)

3. **✅ CRUD Operasyonları**
   - Her rol için detaylı CRUD yetkileri
   - Repository pattern
   - Permission kontrolü

4. **✅ Kod Örnekleri**
   - Admin repository
   - Expert repository
   - User repository
   - UI implementasyonları

5. **✅ Güvenlik**
   - Role-based access control
   - Ownership kontrolü
   - UnauthorizedException

**Teknoloji:** Flutter + Dart + SQLite (sqflite) + Firebase
**Yaklaşım:** Code First
**Dokümantasyon:** [DATABASE_DESIGN.md](./DATABASE_DESIGN.md)

