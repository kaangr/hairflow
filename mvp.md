Proje Adı: HairFlow - Erkek Saç Sağlığı Asistanı
1. Proje Özeti (Executive Summary)
Bu proje, erkek kullanıcıların saç sağlığını iyileştirmelerine ve sürdürmelerine yardımcı olmak için tasarlanmış, modern ve kullanıcı dostu bir mobil uygulama geliştirmeyi amaçlamaktadır. Uygulama, kişiselleştirilmiş tavsiyeler, rutin takip mekanizması ve motive edici bildirimler sunarak kullanıcıların saç bakım alışkanlıklarını düzenli hale getirmelerini teşvik edecektir. Projenin ana hedefi, portfolyoda öne çıkacak, görsel olarak çekici, bol animasyonlu ve işlevsel bir MVP (Minimum Viable Product) oluşturmaktır. Uygulama, Android platformuna odaklanarak lokal (çevrimdışı) çalışacak ve tek seferlik cüzi bir ücretle sunulacaktır.

2. Teknoloji Seçimi ve Mimarisi
Framework: Flutter (Önerilen)

Avantajları: Google tarafından geliştirilmiştir. Kendi render motoru (Skia) sayesinde platformdan bağımsız, son derece akıcı ve estetik açıdan zengin arayüzler oluşturmayı kolaylaştırır. "Pixel-perfect" kontrol sağlar. Zengin widget kütüphanesi ve özellikle animasyon yetenekleri, projenin görsel hedefleri için idealdir.

Animasyon: Rive (rive.app)

Flutter ile tam entegre çalışabilen Rive, interaktif ve yüksek performanslı vektör animasyonları oluşturmak için kullanılacaktır. Bu, uygulamanın statik görseller yerine canlı ve hareketli grafiklerle zenginleştirilmesini sağlayacaktır. Onboarding ekranları, başarı bildirimleri ve ilerleme göstergeleri gibi alanlarda Rive animasyonları kullanılacaktır.

Dezavantajları: Dart dilini öğrenmeyi gerektirir.

3. Proje Gereksinimleri (Project Requirements)
Fonksiyonel Gereksinimler (Functional Requirements)
Kullanıcı Kurulumu (Onboarding):

Uygulama ilk açıldığında, Rive ile hazırlanmış akıcı animasyonlarla uygulamanın amacını anlatan kısa ve çekici ekranlar.

Kullanıcıdan saç tipi ve ana hedefi gibi temel bilgileri alma.

Ana Sayfa (Dashboard):

Modern ve temiz bir tasarım.

"Günün Tavsiyesi" bölümü.

Kullanıcının o gün yapması gereken rutinleri gösteren interaktif bir kart.

Rutin tamamlama ilerlemesini gösteren hareketli bir grafik veya animasyon.

Rutin Takipçisi (Routine Tracker):

Kullanıcıların kendi günlük/haftalık saç bakım rutinlerini oluşturabilmesi.

Oluşturulan rutinlerdeki görevleri "tamamlandı" olarak işaretleyebilme (örneğin, kaydırarak veya dokunarak).

Geçmişe dönük olarak görevlerin yapıldığını gösteren basit bir takvim veya liste görünümü.

Bilgi Bankası (Tips & Tricks):

Saç sağlığı ile ilgili genel tavsiyelerin, makalelerin ve ipuçlarının bulunduğu bir bölüm.

İlk etapta Minoxidil, Finasteride, Biotin, DHT-Blokajlı Şampuanlar ve Saw Palmetto hakkında detaylı kullanım bilgileri yer alacaktır.

İçerikler, görsellerle desteklenmiş, okunması kolay bir formatta sunulmalı.

Bildirimler (Notifications):

Rutin zamanları için hatırlatma bildirimleri.

Kullanıcıyı motive edici bildirimler.

Bildirimlerin ayarlar menüsünden açılıp kapatılabilmesi.

Fonksiyonel Olmayan Gereksinimler (Non-Functional Requirements)
Kullanıcı Arayüzü ve Deneyimi (UI/UX):

Minimalist, modern ve estetik bir tasarım. Akıcı animasyonlar ve Rive ile zenginleştirilmiş mikro-etkileşimler projenin merkezinde olacaktır.

Koyu Mod (Dark Mode) desteği.

Kolay ve sezgisel bir navigasyon (Bottom Navigation Bar).

Performans:

Uygulama hızlı açılmalı ve 60 FPS animasyon performansından ödün vermemeli.

Veri Depolama:

Tüm kullanıcı verileri cihazın lokal deposunda saklanacaktır (sqflite veya Hive paketi kullanılabilir).

4. Uygulama Mimarisi ve Kullanıcı Akışı
Katmanlı Mimari (Layered Architecture)
Uygulama, yönetimi ve testi kolaylaştırmak için 3 ana katmandan oluşacaktır:

UI Katmanı (Presentation Layer):

Tüm Widget'lar, ekranlar ve animasyonlar bu katmanda yer alır.

Kullanıcı etkileşimlerini alır ve bunları iş mantığı katmanına iletir.

State Management için Provider veya Riverpod gibi bir çözüm kullanılacaktır.

İş Mantığı Katmanı (Business Logic / Domain Layer):

Uygulamanın beynidir. Rutin tamamlama, bildirim zamanlama gibi mantıksal işlemler burada gerçekleşir.

UI katmanından bağımsızdır.

Veri Katmanı (Data Layer):

Lokal veritabanı (örn: sqflite) ile olan tüm iletişimi yönetir.

Veri ekleme, silme, güncelleme ve okuma işlemlerinden sorumludur.

Kullanıcı Akışı (User Flow)
İlk Açılış: Kullanıcı uygulamayı ilk kez açar -> Rive animasyonlu Onboarding ekranları gelir -> Kullanıcı saç tipi/hedefi seçer -> Ana Sayfa'ya yönlendirilir.

Normal Açılış: Kullanıcı uygulamayı açar -> Splash Screen (logo animasyonu) -> Ana Sayfa (Dashboard) direkt olarak yüklenir.

Navigasyon: Kullanıcı, ekranın altındaki Bottom Navigation Bar aracılığıyla 4 ana bölüm arasında geçiş yapar:

Ana Sayfa (Home): Günlük rutin ve ilerleme.

Rutinlerim (Tracker): Tüm rutinleri yönetme ve takvimi görme.

Bilgi Bankası (Learn): Ürünler ve ipuçları.

Ayarlar (Settings): Bildirim ayarları, tema seçimi.

Rutin Tamamlama: Ana Sayfa'daki görev kartına tıklar -> Görevi "tamamlandı" olarak işaretler -> Animasyonlu bir onay gösterilir ve ilerleme grafiği güncellenir.

5. MVP (Minimum Viable Product) Tanımı
Tek Adımlı Kurulum: Sadece ana hedefi seçtirme.

Sabit Rutin: Başlangıç için 3-4 adımlık varsayılan bir "Temel Saç Bakım Rutini" sunma.

Ana Sayfa: Günlük rutini ve tamamlanma durumunu göstersin.

Bilgi Bankası: Aşağıdaki 5 ürün hakkında hazır bilgi içeren statik bir sayfa.

Basit Bildirimler: Sadece günlük rutin için tek bir hatırlatma.

6. Proje Yol Haritası (Roadmap)
Faz 1: Tasarım ve Prototipleme (1-2 Hafta)

Uygulamanın renk paleti, tipografi ve ikon setinin belirlenmesi.

Figma'da tüm ana ekranların detaylı tasarımlarının yapılması.

Rive'da kullanılacak temel animasyonların (onboarding, progress bar vb.) tasarlanması.

Faz 2: MVP Geliştirme (4-6 Hafta)

Flutter projesinin oluşturulması ve katmanlı mimarinin kurulması.

Tasarımı yapılan UI bileşenlerinin koda dökülmesi.

Rive animasyonlarının Flutter projesine entegre edilmesi.

Lokal veritabanı yapısının kurulması (sqflite).

Rutin takip etme mantığının geliştirilmesi ve bildirim sisteminin entegre edilmesi.

Faz 3: Test ve Yayınlama (1-2 Hafta)

Uygulamanın farklı Android cihazlarda test edilmesi.

Hata ayıklama ve performans optimizasyonu.

Google Play Store için materyallerin hazırlanması ve uygulamanın yayınlanması.

7. Eklenen İçerik: Temel Ürün Bilgileri
Bu bölüm, "Bilgi Bankası"nın ilk içeriğini oluşturacaktır.

1️⃣ Minoxidil (topikal)
Versiyonlar: %5 erkekler için en yaygın (sprey veya köpük). %2 daha çok kadınlarda.

Kullanım Sıklığı: Günde 2 kez (sabah ve akşam) veya en az 1 kez düzenli.

Uygulama: Saçın kuru olduğundan emin ol. Yaklaşık 1 ml ürünü seyrekleşen alanlara masajla yedir. Uyguladıktan sonra en az 4 saat saçını yıkama.

Not: Düzenli kullanım bırakıldığında etkiler kaybolur.

2️⃣ Finasteride (oral)
Versiyon: 1 mg tablet (Propecia / generikleri).

Kullanım Sıklığı: Günde 1 tablet (doktor gözetiminde).

Uygulama: Yemekten bağımsız alınabilir. Etkisi 3–6 ayda gözlemlenir.

Not: Yan etki potansiyeli nedeniyle doktor kontrolü şart.

3️⃣ Biotin + B Vitamin Kompleksi (takviye)
Versiyon: 2.500–5.000 mcg biotin içeren tablet/kapsül.

Kullanım Sıklığı: Günde 1 kapsül.

Uygulama: Yemekle birlikte alınması emilimi artırır. Düzenli kullanımda saç teli kalınlaşması desteklenir.

4️⃣ Kafeinli / DHT-blokajlı Şampuanlar
Versiyon: Alpecin C1, Ducray Anaphase+, Revita Shampoo gibi.

Kullanım Sıklığı: Haftada 3–5 kez (normal şampuan yerine).

Uygulama: Saç derisine masajla köpürt. En az 2 dakika beklet, sonra durula.

5️⃣ Saw Palmetto (Serenoa Repens) Takviyeleri
Versiyon: 160 mg kapsül / softgel.

Kullanım Sıklığı: Günde 1–2 kapsül (markaya göre değişir).

Uygulama: Yemekle birlikte alınması mideyi rahatlatır. Etki için 2–3 ay düzenli kullanım gerekir.

🔹 Genel Kombin Önerisi
Sabah: Minoxidil + kafeinli şampuan

Akşam: Minoxidil (2. doz)

Günlük: Finasteride (tablet) + Biotin takviyesi

Takviye: Saw Palmetto (yemekle)

8. Gelecek Sürümler (Post-MVP)
Kişiselleştirilebilir rutinler ekleme.

İlerleme takibi için fotoğraf ekleme özelliği.

Daha fazla makale ve video içeriği.

İlerleme grafikleri ve istatistikler.