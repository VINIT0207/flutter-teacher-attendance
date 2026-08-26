import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/timetable_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      if (!e.toString().contains('MissingPluginException')) {
        debugPrint('NotificationService init error: $e');
      }
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final grantedNotifications =
          await androidImplementation?.requestNotificationsPermission() ?? true;
      try {
        await androidImplementation?.requestExactAlarmsPermission();
      } catch (_) {}

      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final grantedIos = await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;

      return grantedNotifications && grantedIos;
    } catch (e) {
      if (!e.toString().contains('MissingPluginException')) {
        debugPrint('Error requesting notification permissions: $e');
      }
      return true;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'classtrack_lectures',
        'ClassTrack Lecture Reminders',
        channelDescription:
            'Notifications to remind teachers before scheduled lectures',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      if (!e.toString().contains('MissingPluginException')) {
        debugPrint('Error displaying notification: $e');
      }
    }
  }

  Future<void> scheduleLectureReminder({
    required TimetableModel slot,
    required int leadMinutes,
  }) async {
    try {
      final title = 'Class Reminder: ${slot.className}';
      final body =
          'Your ${slot.subject} lecture starts in $leadMinutes mins at ${slot.startTime} (Room: ${slot.roomNumber.isNotEmpty ? slot.roomNumber : "N/A"})';

      await showNotification(
        id: slot.id ?? DateTime.now().millisecond,
        title: title,
        body: body,
        payload: 'timetable_${slot.classId}',
      );
    } catch (e) {
      if (!e.toString().contains('MissingPluginException')) {
        debugPrint('Error scheduling lecture reminder: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      if (!e.toString().contains('MissingPluginException')) {
        debugPrint('Error cancelling notifications: $e');
      }
    }
  }

  static const MethodChannel _settingsChannel =
      MethodChannel('com.example.attendance/settings');

  Future<void> openNotificationSettings() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _settingsChannel.invokeMethod('openNotificationSettings');
        return;
      } catch (e) {
        debugPrint('Error opening native notification settings: $e');
      }
    }

    try {
      await launchUrlString('app-settings:');
    } catch (_) {}
  }
}
