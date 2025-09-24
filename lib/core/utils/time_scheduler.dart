
class TimeScheduler {
  /// Otomatik saat ataması yapan yardımcı sınıf
  /// Görevleri mantıklı saatlere dağıtır
  
  static List<DateTime> assignTimesToTasks(List<String> tasks, DateTime baseDate) {
    final assignedTimes = <DateTime>[];
    
    // Saat dilimleri - günün farklı zamanları
    final timeSlots = _getOptimalTimeSlots();
    
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final timeSlot = _getBestTimeSlotForTask(task, timeSlots, i);
      
      final scheduledTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        timeSlot.hour,
        timeSlot.minute,
      );
      
      assignedTimes.add(scheduledTime);
    }
    
    return assignedTimes;
  }
  
  /// Gün içindeki optimal zaman dilimlerini döndürür
  static List<TimeSlot> _getOptimalTimeSlots() {
    return [
      TimeSlot(7, 0, 'Sabah Erken'),      // 07:00
      TimeSlot(8, 30, 'Sabah'),           // 08:30
      TimeSlot(12, 0, 'Öğle'),            // 12:00
      TimeSlot(18, 0, 'Akşam'),           // 18:00
      TimeSlot(21, 0, 'Gece'),            // 21:00
      TimeSlot(9, 0, 'Sabah Geç'),        // 09:00
      TimeSlot(15, 0, 'Öğleden Sonra'),   // 15:00
      TimeSlot(22, 30, 'Gece Geç'),       // 22:30
      TimeSlot(6, 30, 'Sabah Çok Erken'), // 06:30
      TimeSlot(13, 30, 'Öğle Sonrası'),   // 13:30
      TimeSlot(19, 30, 'Akşam Geç'),      // 19:30
      TimeSlot(23, 0, 'Gece Çok Geç'),    // 23:00
    ];
  }
  
  /// Göreve göre en uygun zaman dilimini bulur
  static TimeSlot _getBestTimeSlotForTask(String task, List<TimeSlot> timeSlots, int index) {
    final taskLower = task.toLowerCase();
    
    // Minoxidil - Sabah ve akşam
    if (taskLower.contains('minoxidil')) {
      if (index % 2 == 0) {
        return timeSlots.firstWhere((slot) => slot.hour == 7, orElse: () => timeSlots[0]);
      } else {
        return timeSlots.firstWhere((slot) => slot.hour == 21, orElse: () => timeSlots[4]);
      }
    }
    
    // Şampuan - Sabah
    if (taskLower.contains('şampuan') || taskLower.contains('shampoo')) {
      return timeSlots.firstWhere((slot) => slot.hour == 8, orElse: () => timeSlots[1]);
    }
    
    // Vitamin/Takviye - Öğün zamanları
    if (taskLower.contains('vitamin') || 
        taskLower.contains('takviye') || 
        taskLower.contains('biotin') ||
        taskLower.contains('finasteride') ||
        taskLower.contains('saw palmetto') ||
        taskLower.contains('çinko') ||
        taskLower.contains('omega') ||
        taskLower.contains('demir')) {
      
      // Sabah vitaminleri
      if (taskLower.contains('d vitamin') || taskLower.contains('finasteride')) {
        return timeSlots.firstWhere((slot) => slot.hour == 9, orElse: () => timeSlots[5]);
      }
      
      // Öğle vitaminleri
      if (taskLower.contains('demir') || taskLower.contains('c vitamin')) {
        return timeSlots.firstWhere((slot) => slot.hour == 12, orElse: () => timeSlots[2]);
      }
      
      // Akşam vitaminleri
      if (taskLower.contains('çinko') || taskLower.contains('omega') || taskLower.contains('saw palmetto')) {
        return timeSlots.firstWhere((slot) => slot.hour == 19, orElse: () => timeSlots[10]);
      }
      
      // Gece vitaminleri
      if (taskLower.contains('biotin')) {
        return timeSlots.firstWhere((slot) => slot.hour == 22, orElse: () => timeSlots[7]);
      }
    }
    
    // Dermaroller/Dermastamp - Akşam
    if (taskLower.contains('derma')) {
      return timeSlots.firstWhere((slot) => slot.hour == 21, orElse: () => timeSlots[4]);
    }
    
    // Masaj - Sabah veya akşam
    if (taskLower.contains('masaj')) {
      return timeSlots.firstWhere((slot) => slot.hour == 19, orElse: () => timeSlots[10]);
    }
    
    // Su içme, beslenme - Öğle
    if (taskLower.contains('su') || taskLower.contains('beslenme') || taskLower.contains('atıştırmalık')) {
      return timeSlots.firstWhere((slot) => slot.hour == 13, orElse: () => timeSlots[9]);
    }
    
    // Egzersiz, nefes - Öğleden sonra
    if (taskLower.contains('egzersiz') || taskLower.contains('nefes') || taskLower.contains('spor')) {
      return timeSlots.firstWhere((slot) => slot.hour == 15, orElse: () => timeSlots[6]);
    }
    
    // Yeşil çay - Öğleden sonra
    if (taskLower.contains('çay') || taskLower.contains('tea')) {
      return timeSlots.firstWhere((slot) => slot.hour == 15, orElse: () => timeSlots[6]);
    }
    
    // Güneş kremi - Sabah
    if (taskLower.contains('güneş') || taskLower.contains('krem')) {
      return timeSlots.firstWhere((slot) => slot.hour == 8, orElse: () => timeSlots[1]);
    }
    
    // Default: Rastgele ama index'e göre dağıtılmış
    final availableSlots = [
      timeSlots[0], // 07:00
      timeSlots[2], // 12:00
      timeSlots[3], // 18:00
      timeSlots[4], // 21:00
    ];
    
    return availableSlots[index % availableSlots.length];
  }
  
  /// Saat formatını string'e çevirir
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// String saat formatını DateTime'a çevirir
  static DateTime? parseTimeString(String timeString, DateTime baseDate) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}

class TimeSlot {
  final int hour;
  final int minute;
  final String name;
  
  TimeSlot(this.hour, this.minute, this.name);
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ($name)';
}
