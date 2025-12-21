import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase veritabanına varsayılan verileri ekleyen servis
class FirebaseSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Varsayılan ürünleri Firebase'e ekle
  Future<void> seedProducts() async {
    final productsRef = _firestore.collection('products');
    
    // Mevcut ürün sayısını kontrol et
    final existing = await productsRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('Ürünler zaten mevcut, seed atlanıyor.');
      return;
    }

    final products = [
      // Minoxidil ürünleri
      {
        'name': 'Minoxidil %5 Solüsyon',
        'brand': 'Kirkland',
        'category': 'minoxidil',
        'description': 'FDA onaylı saç dökülmesi tedavisi. Günde 2 kez 1ml uygulayın.',
        'dosage': '1ml günde 2 kez',
        'usage': 'Saç derisi kuru iken uygulayın. 4 saat yıkamayın.',
        'sideEffects': 'Saç derisinde kaşıntı, kızarıklık olabilir. İlk 2-4 hafta dökülme artabilir (shedding).',
        'imageUrl': 'assets/images/products/minoxidil_kirkland.png',
        'effectiveness': 4.5,
        'price': '₺350-500',
        'purchaseLinks': ['trendyol.com', 'amazon.com.tr'],
        'tags': ['fda-onaylı', 'topikal', 'erkek-tipi-dökülme'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Minoxidil %5 Foam',
        'brand': 'Rogaine',
        'category': 'minoxidil',
        'description': 'Köpük formunda minoxidil. Daha hızlı kurur, daha az yağlı his.',
        'dosage': 'Yarım kapak günde 2 kez',
        'usage': 'Kuru saç derisine uygulayın. Masaj yaparak yayın.',
        'sideEffects': 'Saç derisinde kaşıntı olabilir.',
        'imageUrl': 'assets/images/products/minoxidil_foam.png',
        'effectiveness': 4.5,
        'price': '₺600-800',
        'purchaseLinks': ['amazon.com'],
        'tags': ['fda-onaylı', 'köpük', 'hızlı-kuruyan'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Finasteride
      {
        'name': 'Finasteride 1mg',
        'brand': 'Proscar/Propecia',
        'category': 'finasteride',
        'description': 'DHT bloker. Saç dökülmesini %90 oranında durdurur. MUTLAKA doktor kontrolünde kullanın.',
        'dosage': '1mg günde 1 kez',
        'usage': 'Her gün aynı saatte alın. Yemekle veya aç karnına alınabilir.',
        'sideEffects': 'Cinsel yan etkiler (%1-2), depresyon riski. Yan etkiler genellikle geçicidir.',
        'warning': '⚠️ Reçeteli ilaçtır. Doktor kontrolü şarttır!',
        'imageUrl': 'assets/images/products/finasteride.png',
        'effectiveness': 4.8,
        'price': '₺150-300',
        'purchaseLinks': ['eczane'],
        'tags': ['reçeteli', 'oral', 'dht-bloker'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Şampuanlar
      {
        'name': 'Ketokonazol %2 Şampuan',
        'brand': 'Nizoral',
        'category': 'shampoo',
        'description': 'Antifungal şampuan. DHT\'yi saç derisinde azaltır. Kepek ve kaşıntıya da iyi gelir.',
        'dosage': 'Haftada 2-3 kez',
        'usage': 'Saç derisinde 3-5 dakika bekletin, sonra durulayın.',
        'sideEffects': 'Saç kuruluğu olabilir.',
        'imageUrl': 'assets/images/products/nizoral.png',
        'effectiveness': 3.5,
        'price': '₺200-350',
        'purchaseLinks': ['eczane', 'trendyol.com'],
        'tags': ['şampuan', 'antifungal', 'dht-azaltıcı'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Kafeinli Şampuan',
        'brand': 'Alpecin C1',
        'category': 'shampoo',
        'description': 'Kafein içerikli şampuan. Saç köklerini uyarır, DHT etkilerini azaltır.',
        'dosage': 'Her gün veya günaşırı',
        'usage': 'Saç derisinde 2 dakika masaj yaparak bekletin.',
        'sideEffects': 'Genellikle yan etkisi yoktur.',
        'imageUrl': 'assets/images/products/alpecin.png',
        'effectiveness': 3.0,
        'price': '₺150-250',
        'purchaseLinks': ['trendyol.com', 'hepsiburada.com'],
        'tags': ['şampuan', 'kafein', 'günlük-kullanım'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Takviyeler
      {
        'name': 'Biotin 10000mcg',
        'brand': 'Now Foods',
        'category': 'supplement',
        'description': 'B7 vitamini. Saç, cilt ve tırnak sağlığını destekler.',
        'dosage': '1 kapsül günde 1 kez',
        'usage': 'Yemekle birlikte alın.',
        'sideEffects': 'Yüksek dozda akne yapabilir.',
        'imageUrl': 'assets/images/products/biotin.png',
        'effectiveness': 3.0,
        'price': '₺150-250',
        'purchaseLinks': ['iherb.com', 'vitaminler.com'],
        'tags': ['takviye', 'vitamin', 'biotin'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'D3 Vitamini 5000IU',
        'brand': 'Solgar',
        'category': 'supplement',
        'description': 'Güneş vitamini. Saç folliküllerinin sağlıklı çalışması için gerekli.',
        'dosage': '1 kapsül günde 1 kez',
        'usage': 'Yağlı bir öğünle birlikte alın.',
        'sideEffects': 'Aşırı dozda toksik olabilir.',
        'imageUrl': 'assets/images/products/vitamin_d.png',
        'effectiveness': 3.5,
        'price': '₺200-300',
        'purchaseLinks': ['iherb.com', 'vitaminler.com'],
        'tags': ['takviye', 'vitamin', 'd-vitamini'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Omega-3 Balık Yağı',
        'brand': 'Nordic Naturals',
        'category': 'supplement',
        'description': 'EPA ve DHA içerir. Saç derisini besler, iltihabı azaltır.',
        'dosage': '2 kapsül günde 1 kez',
        'usage': 'Yemekle birlikte alın.',
        'sideEffects': 'Balık tadı, mide rahatsızlığı olabilir.',
        'imageUrl': 'assets/images/products/omega3.png',
        'effectiveness': 3.0,
        'price': '₺300-500',
        'purchaseLinks': ['iherb.com', 'vitaminler.com'],
        'tags': ['takviye', 'omega-3', 'balık-yağı'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Çinko 50mg',
        'brand': 'Solgar',
        'category': 'supplement',
        'description': 'Saç büyümesi için önemli mineral. DHT metabolizmasında rol oynar.',
        'dosage': '1 tablet günde 1 kez',
        'usage': 'Yemekle birlikte alın. Bakır ile dengelenmeli.',
        'sideEffects': 'Mide bulantısı olabilir.',
        'imageUrl': 'assets/images/products/zinc.png',
        'effectiveness': 3.0,
        'price': '₺100-200',
        'purchaseLinks': ['iherb.com', 'vitaminler.com'],
        'tags': ['takviye', 'mineral', 'çinko'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Dermaroller
      {
        'name': 'Dermaroller 1.5mm',
        'brand': 'Dr. Pen',
        'category': 'device',
        'description': 'Mikroneedling cihazı. Minoxidil emilimini artırır, kollajen üretimini tetikler.',
        'dosage': 'Haftada 1 kez',
        'usage': 'Temiz saç derisine uygulayın. Minoxidil\'den 24 saat önce veya sonra kullanın.',
        'sideEffects': 'Kızarıklık, hafif kanama normal.',
        'warning': '⚠️ Hijyene dikkat edin. Her kullanımdan önce dezenfekte edin.',
        'imageUrl': 'assets/images/products/dermaroller.png',
        'effectiveness': 4.0,
        'price': '₺50-150',
        'purchaseLinks': ['amazon.com.tr', 'trendyol.com'],
        'tags': ['cihaz', 'mikroneedling', 'dermaroller'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Saw Palmetto
      {
        'name': 'Saw Palmetto 320mg',
        'brand': 'Now Foods',
        'category': 'supplement',
        'description': 'Bitkisel DHT bloker. Finasteride\'e hafif alternatif.',
        'dosage': '1 kapsül günde 1-2 kez',
        'usage': 'Yemekle birlikte alın.',
        'sideEffects': 'Mide rahatsızlığı, baş ağrısı olabilir.',
        'imageUrl': 'assets/images/products/saw_palmetto.png',
        'effectiveness': 2.5,
        'price': '₺200-350',
        'purchaseLinks': ['iherb.com', 'vitaminler.com'],
        'tags': ['takviye', 'bitkisel', 'dht-bloker'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Batch write ile ekle
    final batch = _firestore.batch();
    for (final product in products) {
      batch.set(productsRef.doc(), product);
    }
    await batch.commit();
    
    print('${products.length} ürün eklendi.');
  }

  /// Varsayılan ipuçlarını Firebase'e ekle
  Future<void> seedTips() async {
    final tipsRef = _firestore.collection('tips');
    
    // Mevcut ipucu sayısını kontrol et
    final existing = await tipsRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('İpuçları zaten mevcut, seed atlanıyor.');
      return;
    }

    final tips = [
      // Ürün kullanım ipuçları
      {
        'title': 'Minoxidil Nasıl Uygulanır?',
        'content': '''1. Saç derinizi tamamen kurutun
2. Damlalık ile 1ml ölçün
3. Dökülme bölgelerine damlatın
4. Parmak uçlarıyla masaj yaparak yayın
5. En az 4 saat yıkamayın
6. Günde 2 kez (sabah ve akşam) uygulayın

💡 İpucu: Gece yatmadan önce uygulamak yastığa bulaşmasını engellemez, şapka veya havlu kullanabilirsiniz.''',
        'category': 'product',
        'imageUrl': 'assets/images/tips/minoxidil_usage.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Minoxidil Shedding Nedir?',
        'content': '''İlk 2-4 haftada dökülme artışı normal! Bu "shedding" olarak adlandırılır.

🔬 Neden olur?
Minoxidil zayıf saçları döküp yerine güçlü saçlar çıkarmak için follikülleri uyandırır.

⏱️ Ne kadar sürer?
Genellikle 2-8 hafta. Sonrasında azalır.

✅ Ne yapmalı?
- Panik yapmayın, bu iyi bir işaret!
- Kullanmaya devam edin
- 3-6 ay sonra sonuçları görmeye başlarsınız''',
        'category': 'product',
        'imageUrl': 'assets/images/tips/shedding.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      
      // Beslenme ipuçları
      {
        'title': 'Saç Sağlığı İçin Beslenme',
        'content': '''🥩 Protein
- Saç %90 keratinden (protein) oluşur
- Günde 1.2-1.6g/kg protein alın
- Kaynaklar: et, balık, yumurta, baklagiller

🥬 Demir
- Eksikliği saç dökülmesine neden olur
- Kaynaklar: kırmızı et, ıspanak, mercimek

🐟 Omega-3
- Saç derisini besler
- Kaynaklar: somon, uskumru, ceviz

🥕 A Vitamini
- Sebum üretimini düzenler
- Kaynaklar: havuç, tatlı patates

💊 Çinko
- Saç büyümesi ve onarımı için kritik
- Kaynaklar: kabak çekirdeği, et, yumurta''',
        'category': 'nutrition',
        'imageUrl': 'assets/images/tips/nutrition.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Saç Dökülmesine Neden Olan Yiyecekler',
        'content': '''❌ Bunlardan kaçının veya azaltın:

🍭 Şeker ve işlenmiş karbonhidratlar
- İnsülin direnci → saç dökülmesi

🍟 Trans yağlar
- İltihaplanmayı artırır

🍺 Alkol
- Vitamin emilimini engeller

🥛 Süt ürünleri (bazı kişilerde)
- IGF-1 artışı → DHT artışı

☕ Aşırı kafein
- Demir emilimini azaltır

🍗 Kızarmış yiyecekler
- Yağ bezlerini uyarır''',
        'category': 'nutrition',
        'imageUrl': 'assets/images/tips/avoid_foods.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Rutin ipuçları
      {
        'title': 'Etkili Sabah Rutini',
        'content': '''☀️ İdeal Sabah Rutini:

1. 🚿 Kafeinli şampuan ile yıka (2 dk beklet)
2. 💧 Saç kuruduktan sonra Minoxidil uygula
3. 💊 Kahvaltıda takviyelerini al:
   - Biotin
   - D3 vitamini
   - Omega-3

⏰ En iyi zaman: Uyanır uyanmaz

💡 İpucu: Rutinini her gün aynı saatte yap, alışkanlık haline getir.''',
        'category': 'routine',
        'imageUrl': 'assets/images/tips/morning_routine.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Etkili Akşam Rutini',
        'content': '''🌙 İdeal Akşam Rutini:

1. 💧 Minoxidil uygula (sabahtan en az 8 saat sonra)
2. 💊 Finasteride al (doktor önerisiyle)
3. 🛏️ Saten yastık kılıfı kullan (sürtünmeyi azaltır)

📅 Haftada 1 kez:
- Dermaroller uygula (Minoxidil'den 24 saat önce)
- Ketokonazol şampuan kullan

⏰ En iyi zaman: Yatmadan 1-2 saat önce

💡 İpucu: Minoxidil kurumadan yatma, yastığına bulaşır.''',
        'category': 'routine',
        'imageUrl': 'assets/images/tips/evening_routine.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Genel bilgi
      {
        'title': 'DHT Nedir?',
        'content': '''🧬 DHT (Dihidrotestosteron):

Testosteronun 5-alfa-redüktaz enzimi tarafından dönüştürülmüş hali.

❓ Neden saç döker?
- Genetik olarak hassas follikülleri küçültür
- Saç büyüme döngüsünü kısaltır
- Sonunda follikül ölür

🛡️ DHT'yi nasıl engelleriz?
- Finasteride (oral, %70 azaltır)
- Dutasteride (oral, %90 azaltır - off-label)
- Saw Palmetto (bitkisel, hafif etki)
- Ketokonazol şampuan (topikal)

💡 Gerçek: DHT vücudun diğer yerlerindeki kılları kalınlaştırır, sadece kafa derisinde dökülmeye neden olur!''',
        'category': 'general',
        'imageUrl': 'assets/images/tips/dht.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Norwood Skalası',
        'content': '''📊 Erkek tipi saç dökülmesi evreleri:

Stage 1: Normal saç çizgisi

Stage 2: Hafif çekilme (olgunlaşma)

Stage 3: Belirgin M şekli
- 3A: Sadece ön çekilme
- 3V: Tepe seyrelme başlangıcı

Stage 4: Daha derin çekilme + tepe seyrelme

Stage 5: Ön ve tepe birleşmeye başlar

Stage 6: Ön ve tepe birleşti, yan bantlar kaldı

Stage 7: Sadece yan ve arka bantlar kaldı

💡 Erken müdahale önemli! Stage 2-3'te başlamak en iyi sonuçları verir.''',
        'category': 'general',
        'imageUrl': 'assets/images/tips/norwood.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Saç Ekimi Hakkında',
        'content': '''💇 Saç Ekimi Rehberi:

✅ Ne zaman düşünmeli?
- İlaç tedavisi stabilize olduktan sonra (1+ yıl)
- Dökülme durduğunda
- Donör bölge yeterliyse

🔬 Teknikler:
- FUE: Tek tek folikül alımı, iz kalmaz
- DHI: Doğrudan implantasyon, daha yoğun
- Safir FUE: Daha ince kesiler

💰 Maliyetler (Türkiye):
- 2000-5000 greft: ₺15.000-50.000
- Yurtdışında 2-3 kat daha pahalı

⚠️ Önemli:
- Ekim sonrası da ilaç kullanmaya devam edin
- Aksi halde native saçlar dökülür
- Sonuçlar 12-18 ayda tam görülür''',
        'category': 'general',
        'imageUrl': 'assets/images/tips/hair_transplant.png',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Batch write ile ekle
    final batch = _firestore.batch();
    for (final tip in tips) {
      batch.set(tipsRef.doc(), tip);
    }
    await batch.commit();
    
    print('${tips.length} ipucu eklendi.');
  }

  /// Tüm seed verilerini ekle
  Future<void> seedAll() async {
    await seedProducts();
    await seedTips();
    print('Tüm seed verileri eklendi!');
  }
}

