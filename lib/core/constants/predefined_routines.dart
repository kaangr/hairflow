import '../../domain/entities/routine.dart';

enum HairType {
  dry,     // Kuru
  oily,    // Yağlı
  normal,  // Normal
  sensitive, // Hassas
}

enum HairLossStage {
  prevention, // Önleyici
  early,     // Erken dönem
  moderate,  // Orta seviye
  advanced,  // İleri seviye
}

enum UserGoal {
  preventLoss,     // Dökülmeyi önlemek
  regrowth,        // Yeni saç çıkarmak
  strengthening,   // Güçlendirmek
  maintenance,     // Korumak
}

class PredefinedRoutines {
  static List<Map<String, dynamic>> getRecommendedRoutines({
    required HairType hairType,
    required HairLossStage stage,
    required UserGoal goal,
  }) {
    List<Map<String, dynamic>> routines = [];

    switch (stage) {
      case HairLossStage.prevention:
        routines.addAll(_getPreventionRoutines());
        break;
      case HairLossStage.early:
        routines.addAll(_getEarlyStageRoutines());
        break;
      case HairLossStage.moderate:
        routines.addAll(_getModerateStageRoutines());
        break;
      case HairLossStage.advanced:
        routines.addAll(_getAdvancedStageRoutines());
        break;
    }

    return routines;
  }

  static List<Map<String, dynamic>> _getPreventionRoutines() {
    final now = DateTime.now();
    
    return [
      {
        'routine': Routine(
          id: null,
          name: 'Önleyici Temel Rutin',
          description: 'Saç dökülmesini önlemek için günlük temel bakım rutini',
          createdAt: now,
        ),
        'tasks': [
          '🌅 Kafeinli şampuan ile saç yıkama (sabah)',
          '💊 Biotin takviyesi alma (sabah)',
          '🌿 Saw Palmetto takviyesi (akşam)',
          '💆‍♂️ Saç derisi masajı (5 dakika)',
        ],
      },
    ];
  }

  static List<Map<String, dynamic>> _getEarlyStageRoutines() {
    final now = DateTime.now();
    
    return [
      {
        'routine': Routine(
          id: null,
          name: 'Erken Dönem Kapsamlı Rutin',
          description: 'Saç dökülmesinin başladığı dönem için etkili rutin',
          createdAt: now,
        ),
        'tasks': [
          '💧 Minoxidil %5 uygulama (sabah)',
          '🧴 Kafeinli şampuan (sabah)',
          '💊 Biotin + B vitamin kompleksi',
          '💧 Minoxidil %5 uygulama (akşam)',
          '🌿 Saw Palmetto takviyesi',
        ],
      },
    ];
  }

  static List<Map<String, dynamic>> _getModerateStageRoutines() {
    final now = DateTime.now();
    
    return [
      {
        'routine': Routine(
          id: null,
          name: 'Orta Seviye Yoğun Rutin',
          description: 'Görünür saç kaybı için kombine tedavi yaklaşımı',
          createdAt: now,
        ),
        'tasks': [
          '💧 Minoxidil %5 uygulama (sabah - 1 ml)',
          '💊 Finasteride 1mg (doktor kontrolünde)',
          '🧴 DHT-blokajlı şampuan',
          '💊 Biotin 5000 mcg + B vitamin',
          '🌿 Saw Palmetto 320mg',
          '💧 Minoxidil %5 uygulama (akşam - 1 ml)',
        ],
      },
    ];
  }

  static List<Map<String, dynamic>> _getAdvancedStageRoutines() {
    final now = DateTime.now();
    
    return [
      {
        'routine': Routine(
          id: null,
          name: 'İleri Seviye Maksimum Rutin',
          description: 'Yoğun saç kaybı için en kapsamlı tedavi programı',
          createdAt: now,
        ),
        'tasks': [
          '💧 Minoxidil %5 (sabah - 1.5 ml)',
          '💊 Finasteride 1mg (sabah)',
          '🧴 Ketoconazole şampuan (haftada 2 kez)',
          '💊 Biotin 10000 mcg',
          '🌿 Saw Palmetto 320mg (çift doz)',
          '💧 Minoxidil %5 (akşam - 1.5 ml)',
          '💆‍♂️ Dermaroller (1.5mm - haftada 1 kez)',
        ],
      },
    ];
  }

  // Güvenli başlangıç sıralaması
  static List<String> getSafeStartOrder() {
    return [
      '1️⃣ İlk 2 hafta: Sadece kafeinli şampuan ve biotin takviyesi',
      '2️⃣ 3. hafta: Minoxidil ekleme (günde 1 kez akşam)',
      '3️⃣ 5. hafta: Minoxidil\'i günde 2 keze çıkarma',
      '4️⃣ 8. hafta: Saw Palmetto takviyesi ekleme',
      '5️⃣ 12. hafta: Doktor kontrolünde Finasteride değerlendirme',
      '',
      '⚠️ Önemli Notlar:',
      '• Her ürün için 2 hafta gözlem süresi bırakın',
      '• Yan etki olursa hemen durdurun',
      '• Finasteride mutlaka doktor gözetiminde başlanmalı',
      '• Minoxidil\'i bıraktığınızda etkiler kaybolur',
      '• Sonuçlar 3-6 ay içinde görünmeye başlar',
    ];
  }

  // Saç tipi belirleme soruları
  static List<Map<String, dynamic>> getHairAssessmentQuestions() {
    return [
      {
        'question': 'Saçınız genellikle nasıl hissettiriyor?',
        'options': [
          {'text': 'Kuru ve kabarmış', 'value': HairType.dry},
          {'text': 'Yağlı ve yapışkan', 'value': HairType.oily},
          {'text': 'Normal', 'value': HairType.normal},
          {'text': 'Hassas ve kolay tahriş olan', 'value': HairType.sensitive},
        ],
      },
      {
        'question': 'Saç dökülmeniz ne seviyede?',
        'options': [
          {'text': 'Henüz başlamadı, önlemek istiyorum', 'value': HairLossStage.prevention},
          {'text': 'Hafif başladı, günde 50-100 saç', 'value': HairLossStage.early},
          {'text': 'Orta seviye, görünür incelme var', 'value': HairLossStage.moderate},
          {'text': 'İleri seviye, belirgin alanlar var', 'value': HairLossStage.advanced},
        ],
      },
      {
        'question': 'Ana hedefiniz nedir?',
        'options': [
          {'text': 'Dökülmeyi durdurmak', 'value': UserGoal.preventLoss},
          {'text': 'Yeni saç çıkarmak', 'value': UserGoal.regrowth},
          {'text': 'Mevcut saçları güçlendirmek', 'value': UserGoal.strengthening},
          {'text': 'Sağlıklı saçları korumak', 'value': UserGoal.maintenance},
        ],
      },
    ];
  }
}