class PredefinedTasks {
  static const Map<String, List<String>> taskCategories = {
    'Sabah Rutini': [
      '☀️ Sabah Minoxidil uygulaması (1 ml)',
      '🧴 Kafeinli şampuan ile saç yıkama',
      '💊 Biotin takviyesi alma',
      '🚿 Soğuk su ile durulama',
      '💆‍♂️ Saç derisi masajı (5 dakika)',
      '🥤 Bol su içme (sabah 2 bardak)',
    ],
    'Öğle Rutini': [
      '💊 Finasteride 1mg alma',
      '🌿 Saw Palmetto takviyesi',
      '🥗 Saç sağlığı için beslenme',
      '💧 Su içme hatırlatması',
      '🧘‍♂️ Stres azaltma egzersizi',
    ],
    'Akşam Rutini': [
      '🌙 Akşam Minoxidil uygulaması (1 ml)',
      '💊 B vitamin kompleksi',
      '🧴 Ketoconazole şampuan (haftada 2 kez)',
      '💆‍♂️ Dermaroller kullanımı (haftada 1 kez)',
      '🛌 Erken yatma hatırlatması',
    ],
    'Haftalık Görevler': [
      '📏 Saç uzunluğu ölçümü',
      '📸 İlerleme fotoğrafı çekme',
      '🧴 Ürün stok kontrolü',
      '📊 Haftalık değerlendirme',
      '🩺 Yan etki kontrolü',
    ],
    'Aylık Görevler': [
      '🏥 Doktor kontrolü',
      '📈 Aylık ilerleme raporu',
      '💰 Ürün yenileme',
      '📋 Rutin değerlendirmesi',
      '🎯 Hedef güncelleme',
    ],
    'Beslenme & Yaşam Tarzı': [
      '🍗 Protein açısından zengin yemek',
      '🥬 Demir içeren besinler',
      '🥜 Omega-3 kaynakları',
      '🏃‍♂️ 30 dakika egzersiz',
      '😴 7-8 saat kaliteli uyku',
      '🚭 Sigara içmeme',
      '🍷 Alkol sınırlaması',
    ],
  };

  static List<String> getAllTasks() {
    List<String> allTasks = [];
    for (final tasks in taskCategories.values) {
      allTasks.addAll(tasks);
    }
    return allTasks;
  }

  static List<String> getTasksByCategory(String category) {
    return taskCategories[category] ?? [];
  }

  static List<String> getCategories() {
    return taskCategories.keys.toList();
  }

  static String getCategoryForTask(String task) {
    for (final entry in taskCategories.entries) {
      if (entry.value.contains(task)) {
        return entry.key;
      }
    }
    return 'Diğer';
  }
}
