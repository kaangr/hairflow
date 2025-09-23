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

    // Insert default routine
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here in future versions
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default routine
    final routineId = await db.insert(AppConstants.routinesTable, {
      'name': 'Temel Saç Bakım Rutini',
      'description': 'Günlük saç sağlığı için temel rutin',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert default tasks for today
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    for (int i = 0; i < AppConstants.defaultRoutineTasks.length; i++) {
      await db.insert(AppConstants.routineTasksTable, {
        'routine_id': routineId,
        'title': AppConstants.defaultRoutineTasks[i],
        'description': null,
        'order_index': i,
        'is_completed': 0,
        'completed_at': null,
        'date': todayString,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Insert default tips
    await _insertDefaultTips(db);
  }

  Future<void> _insertDefaultTips(Database db) async {
    final defaultTips = [
      {
        'title': 'Minoxidil Kullanımı',
        'content': 'Minoxidil uygulaması için saçınızın kuru olduğundan emin olun. Yaklaşık 1 ml ürünü seyrekleşen alanlara masajla yedirin. Uyguladıktan sonra en az 4 saat saçınızı yıkamayın.',
        'category': 'product',
        'image_url': null,
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Finasteride Bilgileri',
        'content': 'Finasteride 1 mg tablet günde 1 kez alınır. Yemekten bağımsız alınabilir. Etkisi 3-6 ayda gözlemlenir. Yan etki potansiyeli nedeniyle doktor kontrolü şarttır.',
        'category': 'product',
        'image_url': null,
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Biotin Takviyesi',
        'content': '2.500-5.000 mcg biotin içeren tablet/kapsül günde 1 kez alınır. Yemekle birlikte alınması emilimi artırır. Düzenli kullanımda saç teli kalınlaşması desteklenir.',
        'category': 'product',
        'image_url': null,
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Kafeinli Şampuan Kullanımı',
        'content': 'Kafeinli veya DHT-blokajlı şampuanları haftada 3-5 kez normal şampuan yerine kullanın. Saç derisine masajla köpürtün, en az 2 dakika bekletin, sonra durulayın.',
        'category': 'product',
        'image_url': null,
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Saw Palmetto Takviyesi',
        'content': '160 mg kapsül/softgel günde 1-2 kez alınır. Yemekle birlikte alınması mideyi rahatlatır. Etki için 2-3 ay düzenli kullanım gerekir.',
        'category': 'product',
        'image_url': null,
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Günlük Rutin Önerisi',
        'content': 'Sabah: Minoxidil + kafeinli şampuan\nAkşam: Minoxidil (2. doz)\nGünlük: Finasteride + Biotin\nTakviye: Saw Palmetto (yemekle)',
        'category': 'routine',
        'image_url': null,
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
}
