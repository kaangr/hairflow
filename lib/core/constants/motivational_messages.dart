class MotivationalMessages {
  static const List<String> dailyMotivation = [
    "🌟 Harika gidiyorsun! Her adım seni hedefe yaklaştırıyor.",
    "💪 Tutarlılık başarının anahtarıdır. Devam et!",
    "🚀 Bugün yeni bir fırsat! Rutinini tamamlamaya ne dersin?",
    "⭐ Küçük adımlar, büyük değişimler yaratır.",
    "🎯 Hedefe odaklan, sonuçlar gelecek!",
    "🔥 Motivasyonun düştüğü günlerde bile devam et.",
    "💫 Sen yapabilirsin! İnancını kaybetme.",
    "🌈 Her tamamladığın görev seni daha güçlü yapıyor.",
    "🏆 Şampiyonlar her gün antrenman yapar.",
    "💎 Sabır ve tutarlılık en değerli hazinelerdir.",
  ];

  static const List<String> taskCompletionMessages = [
    "🎉 Harika! Bir adım daha hedefe yaklaştın!",
    "✨ Mükemmel! Rutinini sürdürüyorsun!",
    "🌟 Süpersin! Böyle devam et!",
    "💪 Güçlü kalıyorsun! Tebrikler!",
    "🚀 Roket gibi ilerliyorsun!",
    "⚡ Hızlı ve etkili! Bravo!",
    "🎯 Tam isabet! Hedefine kilitledin!",
    "🔥 Ateş gibisin! Durma devam et!",
    "💫 Parlıyorsun! Bu enerjiyi koru!",
    "🏃‍♂️ Koşar adım hedefe gidiyorsun!",
  ];

  static const List<String> allTasksCompletedMessages = [
    "🏆 WOW! Tüm görevleri tamamladın! Sen bir şampiyonsun!",
    "🎊 İnanılmaz! Bugün mükemmel bir performans sergiledi!",
    "🌟 Süpersin! Tüm rutinini tamamladın! Kendini ödüllendir!",
    "🎉 Fantastic! 100% tamamlama oranı! Harikasın!",
    "💫 Efsane! Bugün kendini aştın! Tebrik ederim!",
    "🚀 Roket gibisin! Tüm hedefleri vurdun!",
    "⭐ Yıldız gibi parlıyorsun! Mükemmel gün geçirdin!",
    "🔥 Ateş gibi yanıyorsun! Bu motivasyonu koru!",
    "🏅 Altın madalya kazandın! Gerçek bir şampiyon!",
    "💎 Elmas gibi değerlisin! Harika bir performans!",
  ];

  static const List<String> encouragementMessages = [
    "💭 Unutma: Saç sağlığı bir maraton, sprint değil.",
    "🌱 Sabırlı ol, sonuçlar zamanla görünecek.",
    "🧠 Tutarlılık, yetenek'ten daha önemlidir.",
    "🎯 Her gün küçük bir adım bile büyük fark yaratır.",
    "💪 Kendine inan, sen bu yolculuğu başarabilirsin.",
    "🌟 En karanlık gece bile sabaha kavuşur.",
    "🚀 Bugün başlangıç, yarın başarı!",
    "⭐ Sen eşsizsin ve hedeflerine layıksın.",
    "🔥 İçindeki ateşi söndürme, yakmaya devam et.",
    "🌈 Her zorluk yeni bir fırsatın kapısıdır.",
  ];

  static const List<String> streakMessages = [
    "🔥 {count} gün üst üste! Streak'in harika!",
    "💪 {count} günlük başarı serisı! Süper!",
    "🚀 {count} gün boyunca duraksız! İnanılmaz!",
    "⭐ {count} günlük mükemmellik! Devam et!",
    "🏆 {count} günlük şampiyonluk! Efsanesin!",
    "🌟 {count} gün boyunca parlıyorsun!",
    "💫 {count} günlük istikrar! Harikasın!",
    "🎯 {count} gün hedef vuruşu! Mükemmel!",
  ];

  static String getRandomDailyMotivation() {
    final now = DateTime.now();
    final index = now.day % dailyMotivation.length;
    return dailyMotivation[index];
  }

  static String getRandomTaskCompletionMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % taskCompletionMessages.length;
    return taskCompletionMessages[random];
  }

  static String getRandomAllTasksCompletedMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % allTasksCompletedMessages.length;
    return allTasksCompletedMessages[random];
  }

  static String getRandomEncouragementMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % encouragementMessages.length;
    return encouragementMessages[random];
  }

  static String getStreakMessage(int count) {
    final random = DateTime.now().millisecondsSinceEpoch % streakMessages.length;
    return streakMessages[random].replaceAll('{count}', count.toString());
  }
}
