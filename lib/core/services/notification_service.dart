import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/app_constants.dart';
import '../constants/motivational_messages.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permission
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isDenied) {
      // Handle permission denied
      return;
    }

    // For Android 13+ (API level 33+), request specific permission
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
  }

  Future<void> scheduleDailyReminder({
    required String time, // "HH:mm" format
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelDailyReminder();
      return;
    }

    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      AppConstants.dailyReminderNotificationId,
      _getRandomReminderTitle(),
      _getRandomReminderBody(),
      tz.TZDateTime.from(_nextInstanceOfTime(hour, minute), tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2E7D32),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    await _flutterLocalNotificationsPlugin
        .cancel(AppConstants.dailyReminderNotificationId);
  }

  Future<void> showInstantMotivationalNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 1000,
      _getRandomMotivationalTitle(),
      _getRandomMotivationalBody(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel',
          'Motivasyon Bildirimleri',
          channelDescription: 'Ani motivasyon mesajları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF4CAF50),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showTaskCompletionNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 1000,
      '🎉 Görev Tamamlandı!',
      MotivationalMessages.getRandomTaskCompletionMessage(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'completion_channel',
          'Tamamlama Bildirimleri',
          channelDescription: 'Görev tamamlama kutlamaları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF4CAF50),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  String _getRandomReminderTitle() {
    final titles = [
      '💊 Rutin Zamanı!',
      '🌟 Hedefe Bir Adım Daha!',
      '⏰ Saç Bakım Saatin Geldi!',
      '🚀 Başarıya Doğru!',
      '💪 Güçlü Kal!',
      '🎯 Hedefe Odaklan!',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % titles.length;
    return titles[random];
  }

  String _getRandomReminderBody() {
    final bodies = [
      'Günlük saç bakım rutininizi uygulamayı unutmayın! 💫',
      'Tutarlılık başarının anahtarıdır. Hadi başlayalım! 🔥',
      'Küçük adımlar, büyük değişimler yaratır. 🌱',
      'Bugün kendine iyi davran. Rutinini tamamla! ⭐',
      'Sen yapabilirsin! Hedefe bir adım daha yakın! 🏆',
      'Saç sağlığın için harekete geç! 💎',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % bodies.length;
    return bodies[random];
  }

  String _getRandomMotivationalTitle() {
    final titles = [
      '🌟 Motivasyon Zamanı!',
      '💫 İlham Verici Mesaj!',
      '🚀 Güç Ver Kendine!',
      '⭐ Parlama Zamanı!',
      '🔥 Enerji Yükle!',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % titles.length;
    return titles[random];
  }

  String _getRandomMotivationalBody() {
    return MotivationalMessages.getRandomEncouragementMessage();
  }
}
