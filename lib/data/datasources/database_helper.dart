import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create routines table
    await db.execute('''
      CREATE TABLE ${AppConstants.routinesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create routine_tasks table
    await db.execute('''
      CREATE TABLE ${AppConstants.routineTasksTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        order_index INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        date TEXT NOT NULL,
        scheduled_time TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (routine_id) REFERENCES ${AppConstants.routinesTable} (id) ON DELETE CASCADE
      )
    ''');

    // Create tips table
    await db.execute('''
      CREATE TABLE ${AppConstants.tipsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default tips only
    await _insertDefaultTips(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.delete(AppConstants.tipsTable);
      await _insertDefaultTips(db);
    }
    
    if (oldVersion < 3) {
      await db.delete(AppConstants.tipsTable);
      await _insertDefaultTips(db);
    }
    
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.routineTasksTable} ADD COLUMN scheduled_time TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  Future<void> _insertDefaultTips(Database db) async {
    final defaultTips = [
      {
        'title': 'Minoxidil %5 Çözeltisi',
        'content': 'Minoxidil %5 günde 2 kez (1 ml) uygulanmalıdır. Saç derisi tamamen kuru olduğunda uygulayın ve 4 saat boyunca yıkamayın.',
        'category': 'product',
        'image_url': 'assets/images/products/minoxidil.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Finasteride 1mg Tablet',
        'content': 'Finasteride 1mg günde 1 kez alınır. MUTLAKA doktor kontrolünde başlanmalı. DHT hormonunu %70 azaltır.',
        'category': 'product',
        'image_url': 'assets/images/products/finasteride.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'D Vitamini 2000 IU',
        'content': 'D vitamini saç folliküllerinin sağlığı için kritiktir. Günde 2000-4000 IU alınabilir.',
        'category': 'nutrition',
        'image_url': 'assets/images/nutrition/vitamin_d.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Biotin 5000mcg Takviyesi',
        'content': 'Biotin 5000-10000 mcg günde 1 kez alınabilir. Saç, cilt ve tırnak sağlığını destekler.',
        'category': 'nutrition',
        'image_url': 'assets/images/products/biotin.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Kafeinli Şampuan',
        'content': 'Kafeinli şampuan saç derisinde 2 dakika bekletilmeli. Haftada 3-4 kez kullanım yeterlidir.',
        'category': 'product',
        'image_url': 'assets/images/products/caffeine_shampoo.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Günlük Rutin Önerisi',
        'content': 'Sabah: Minoxidil + kafeinli şampuan\nAkşam: Minoxidil (2. doz)\nGünlük: Biotin takviyesi',
        'category': 'routine',
        'image_url': 'assets/images/routines/daily_routine.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final tip in defaultTips) {
      await db.insert(AppConstants.tipsTable, tip);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> refreshDatabase() async {
    await close();
    _database = await _initDatabase();
  }
}
