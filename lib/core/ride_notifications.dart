import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RideNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> showRequestSent() => showUpdate(
    'Ride request sent',
    'Your request is waiting for the driver to respond.',
  );

  static Future<void> showUpdate(String title, String body) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      if (!_ready) {
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        );
        _ready = true;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (await android?.requestNotificationsPermission() != true) return;
      await _plugin.show(
        id: 1,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'ride_updates',
            'Ride updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } on PlatformException catch (error) {
      debugPrint('Ride notification unavailable: ${error.code}');
    }
  }
}
