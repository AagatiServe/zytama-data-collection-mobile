import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

const _fcmTokenKey = 'fcm_token';

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
      'Background message: ${message.messageId} | data: ${message.data}');
}

class FcmService {
  final SharedPreferences _prefs;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FcmService(this._prefs);

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS local notification permissions
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Initialize local notifications plugin
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );

    // iOS foreground presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request FCM permission (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS APN token
    if (Platform.isIOS) {
      final apn = await _messaging.getAPNSToken();
      debugPrint('APN TOKEN: $apn');
    }

    // FCM token
    await _refreshToken();
    _messaging.onTokenRefresh.listen(_persistToken);

    // Foreground message — show local notification
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Tapped while app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // Tapped while app was terminated
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationOpened(initial);
  }

  String? getToken() => _prefs.getString(_fcmTokenKey);

  Future<void> _refreshToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _persistToken(token);
  }

  Future<void> _persistToken(String token) async {
    await _prefs.setString(_fcmTokenKey, token);
    debugPrint('FCM TOKEN: $token');
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('FG message: ${message.messageId}');
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification == null || android == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          color: const Color(0xff0C6170),
          playSound: true,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  void _onNotificationOpened(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(notification.title ?? ''),
        content: Text(notification.body ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}

/// Global navigator key — set on MaterialApp so FcmService can access context
/// from outside the widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
