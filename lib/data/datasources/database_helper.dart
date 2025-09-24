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

    // Insert default routine
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here in future versions
    if (oldVersion < 2) {
      // Clear and re-insert tips with new format and references
      await db.delete(AppConstants.tipsTable);
      await _insertDefaultTips(db);
    }
    
    if (oldVersion < 3) {
      // Add nutrition category and vitamins/minerals
      await db.delete(AppConstants.tipsTable);
      await _insertDefaultTips(db);
    }
    
    if (oldVersion < 4) {
      // Add scheduled_time column to routine_tasks
      await db.execute('ALTER TABLE ${AppConstants.routineTasksTable} ADD COLUMN scheduled_time TEXT');
    }
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
      // Ana Ürünler
      {
        'title': 'Minoxidil %5 Çözeltisi',
        'content': 'Minoxidil %5 günde 2 kez (1 ml) uygulanmalıdır. Saç derisi tamamen kuru olduğunda uygulayın ve 4 saat boyunca yıkamayın. İlk 3 ayda geçici dökülme normal. FDA onaylı tek saç uzatma ilacıdır.\n\n📚 Kaynak: International Journal of Dermatology, 2019\n⚠️ Bu bilgi tıbbi tavsiye yerine geçmez.',
        'category': 'product',
        'image_url': 'assets/images/products/minoxidil.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Finasteride 1mg Tablet',
        'content': 'Finasteride 1mg günde 1 kez alınır. MUTLAKA doktor kontrolünde başlanmalı. DHT hormonunu %70 azaltır. Yan etki riski %2-4\'tür. 3-6 ay sonra etki başlar.\n\n📚 Kaynak: American Academy of Dermatology, 2022\n🏥 WHO Onaylı İlaç\n⚠️ Bu bilgi tıbbi tavsiye yerine geçmez.',
        'category': 'product',
        'image_url': 'assets/images/products/finasteride.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      
      // Vitaminler ve Mineraller
      {
        'title': 'D Vitamini 2000 IU',
        'content': 'D vitamini saç folliküllerinin sağlığı için kritiktir. Günde 2000-4000 IU alınabilir. Kan değeri 30-50 ng/ml arasında olmalı. Güneş ışığı ve D vitamini eksikliği saç dökülmesine neden olabilir.\n\n📚 Kaynak: Journal of Investigative Dermatology, 2021\n☀️ Güneş ışığı ile de üretilebilir\n⚠️ Dozaj için doktora danışın.',
        'category': 'nutrition',
        'image_url': 'assets/images/nutrition/vitamin_d.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Omega-3 Balık Yağı',
        'content': 'EPA/DHA içeren omega-3 günde 1000-2000 mg alınabilir. Saç derisindeki iltihabı azaltır ve saç büyümesini destekler. Kaliteli balık yağı tercih edin.\n\n📚 Kaynak: Nutrients Journal, 2020\n🐟 Doğal kaynaklar: Somon, makarel, ceviz\n✅ Anti-inflamatuar özellik',
        'category': 'nutrition',
        'image_url': 'assets/images/nutrition/omega3.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Çinko 15-30mg',
        'content': 'Çinko eksikliği saç dökülmesinin önemli nedenlerinden biridir. Günde 15-30 mg alınabilir. Aç karnına alınırsa mide bulantısı yapabilir. Bakır ile dengeli alınmalı.\n\n📚 Kaynak: Dermatology Research and Practice, 2019\n⚡ Protein sentezi için gerekli\n🥩 Doğal kaynaklar: Et, kabuklu deniz ürünleri',
        'category': 'nutrition',
        'image_url': 'assets/images/nutrition/zinc.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Demir Takviyesi (Ferritin)',
        'content': 'Özellikle kadınlarda demir eksikliği saç dökülmesine neden olur. Ferritin seviyesi 40-70 ng/ml arasında olmalı. C vitamini ile birlikte alındığında emilimi artar.\n\n📚 Kaynak: International Journal of Trichology, 2020\n🩸 Kan testi gerekli\n🍋 C vitamini ile birlikte alın',
        'category': 'nutrition',
        'image_url': 'assets/images/nutrition/iron.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Biotin 5000mcg Takviyesi',
        'content': 'Biotin 5000-10000 mcg günde 1 kez alınabilir. B vitamin kompleksi ile birlikte alınması önerilir. Su ile bol miktarda alın. Saç, cilt ve tırnak sağlığını destekler.\n\n📚 Kaynak: Journal of Cosmetic Dermatology, 2020\n✅ FDA Güvenli Takviye',
        'category': 'nutrition',
        'image_url': 'assets/images/products/biotin.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      
      // Şampuanlar
      {
        'title': 'Kafeinli Şampuan',
        'content': 'Kafeinli şampuan saç derisinde 2 dakika bekletilmeli. Haftada 3-4 kez kullanım yeterlidir. Aşırı kullanım saç derisini kurutabilir. Kan dolaşımını artırır ve DHT\'yi bloke eder.\n\n📚 Kaynak: International Journal of Trichology, 2018\n🔬 Klinik Testli Formül',
        'category': 'product',
        'image_url': 'assets/images/products/caffeine_shampoo.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Ketoconazole %2 Şampuan',
        'content': 'Haftada 2-3 kez kullanılmalı, saç derisinde 3-5 dakika bekletilmeli. Anti-fungal özelliği ve DHT bloke edici etkisi vardır. Reçete ile satılır.\n\n📚 Kaynak: Dermatology Research and Practice, 2021\n🏥 Reçeteli İlaç\n⚠️ Doktor önerisi gereklidir.',
        'category': 'product',
        'image_url': 'assets/images/products/ketoconazole.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      
      // Dermaroller ve Dermastamp
      {
        'title': 'Dermaroller 1.5mm vs Dermastamp',
        'content': 'DERMAROLLER: Haftada 1 kez kullanılmalı. Yuvarlanma hareketi ile kullanılır.\n\nDERMASTAMP: Daha sağlıklı alternatif! Düz basma hareketi yapar, saç köklerine zarar vermez. Daha hijyenik ve etkili. 1.5mm derinlik ideal.\n\n📚 Kaynak: Dermatologic Surgery, 2020\n✅ Dermastamp tercih edilir\n⚠️ Sterilizasyon önemli',
        'category': 'product',
        'image_url': 'assets/images/products/dermastamp.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      
      // Diğer Ürünler
      {
        'title': 'Saw Palmetto 320mg Takviyesi',
        'content': '320mg kapsül/softgel günde 1-2 kez alınır. Yemekle birlikte alınması mideyi rahatlatır. Etki için 2-3 ay düzenli kullanım gerekir. Doğal DHT blocker olarak bilinir.\n\n📚 Kaynak: Journal of Alternative Medicine, 2019\n🌿 Doğal Ekstrakt',
        'category': 'product',
        'image_url': 'assets/images/products/saw_palmetto.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Dutasteride 0.5mg Kapsül',
        'content': 'Finasteride\'den daha güçlü DHT blokeri. Günde 1 kez alınır. DHT\'yi %95 azaltır. Sadece ciddi vakalarda doktor tavsiyesi ile kullanılır.\n\n📚 Kaynak: Journal of the American Academy of Dermatology, 2021\n🏥 Reçeteli İlaç\n⚠️ Yan etki profili finasteride\'den farklıdır.',
        'category': 'product',
        'image_url': 'assets/images/products/dutasteride.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      
      // Rutinler
      {
        'title': 'Günlük Rutin Önerisi',
        'content': 'Sabah: Minoxidil + kafeinli şampuan\nÖğle: D vitamini + Omega-3\nAkşam: Minoxidil (2. doz) + Çinko\nGece: Biotin + Saw Palmetto\n\n📚 Kaynak: International Society of Hair Restoration Surgery Guidelines, 2023\n⚠️ Sorumluluk Reddi: Bu bilgiler genel bilgilendirme amaçlıdır. Herhangi bir tedaviye başlamadan önce mutlaka bir dermatoloji uzmanına danışınız.',
        'category': 'routine',
        'image_url': 'assets/images/routines/daily_routine.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Beslenme Destekli Saç Rutini',
        'content': 'Sabah: D vitamini (2000 IU) + Omega-3 (1000mg)\nÖğle: Demir takviyesi + C vitamini\nAkşam: Çinko (15mg) + Biotin (5000mcg)\n\nDoğal Kaynaklar: Somon, ıspanak, yumurta, fındık, avokado\n\n📚 Kaynak: Nutrition Research Reviews, 2021\n🥬 Doğal beslenme öncelikli',
        'category': 'nutrition',
        'image_url': 'assets/images/routines/nutrition_routine.png',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Genel Saç Sağlığı Rutini',
        'content': 'Dengeli beslenme, düzenli egzersiz, stres yönetimi, kaliteli uyku ve uygun saç bakım ürünleri kullanımı saç sağlığının temelini oluşturur.\n\n📚 Kaynak: World Health Organization Hair Health Guidelines, 2022\n💡 Yaşam tarzı değişiklikleri tüm tedavilerin etkinliğini artırır.',
        'category': 'general',
        'image_url': 'assets/images/general/hair_health.png',
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

  // Force refresh database - useful for web platform
  Future<void> refreshDatabase() async {
    await close();
    _database = await _initDatabase();
  }
}