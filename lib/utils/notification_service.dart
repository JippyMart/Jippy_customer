import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  initInfo() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      var request = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (request.authorizationStatus == AuthorizationStatus.authorized ||
          request.authorizationStatus == AuthorizationStatus.provisional) {
        const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        var iosInitializationSettings = const DarwinInitializationSettings();
        final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings);
        await flutterLocalNotificationsPlugin.initialize(initializationSettings,
            onDidReceiveNotificationResponse: (payload) {});
        await setupInteractedMessage();
      }
    } catch (e) {
      log("Error initializing notifications: $e");
    }
  }

  Future<void> setupInteractedMessage() async {
    try {
      RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        FirebaseMessaging.onBackgroundMessage(
                (message) => firebaseMessageBackgroundHandle(message));
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("::::::::::::onMessage:::::::::::::::::");
        if (message.notification != null) {
          log(message.notification.toString());
          display(message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("::::::::::::onMessageOpenedApp:::::::::::::::::");
        if (message.notification != null) {
          log(message.notification.toString());
        }
      });

      log("::::::::::::Permission authorized:::::::::::::::::");
      await FirebaseMessaging.instance.subscribeToTopic("customer");
    } catch (e) {
      log("Error setting up message interaction: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      // Check if running on iOS simulator
      if (Platform.isIOS) {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        final bool isSimulator = !iosDeviceInfo.isPhysicalDevice;
        if (isSimulator) {
          log('DEBUG: iOS Simulator detected - Push notifications not available');
          return null;
        }
        // For physical iOS device, check APNS token availability
        try {
          // First check if we can get APNS token (this might throw the error)
          final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            log('DEBUG: APNS token not available on iOS device');
            // Continue anyway as FCM might still work
          }
        } catch (apnsError) {
          log('DEBUG: APNS token check failed: $apnsError');
          // Continue to try getting FCM token anyway
        }
      }

      // Get FCM token with timeout
      String? token = await FirebaseMessaging.instance.getToken();
      log('DEBUG: FCM Token retrieved: ${token != null ? "Yes" : "No"}');
      return token;
    } catch (e) {
      log('DEBUG: Error getting FCM token: $e');

      // Specific handling for APNS token error
      if (e.toString().contains('apns-token-not-set')) {
        log('DEBUG: APNS token not set - push notifications unavailable on this iOS device');
        return null;
      }

      return null;
    }
  }

  void display(RemoteMessage message) async {
    try {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.notification!.body.toString()}');

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        '0',
        'goRide-customer',
        description: 'Show QuickLAI Notification',
        importance: Importance.max,
      );

      AndroidNotificationDetails notificationDetails =
      AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: 'your channel Description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetailsBoth = NotificationDetails(
        android: notificationDetails,
        iOS: darwinNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log('Error displaying notification: $e');
    }
  }

  // Additional method to check notification permissions
  static Future<bool> hasNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('Error checking notification permissions: $e');
      return false;
    }
  }

  // Method to safely initialize notifications with fallback
  Future<void> safeInit() async {
    try {
      await initInfo();
    } catch (e) {
      log('Notification service initialization failed: $e');
      // Continue without notifications - don't block app startup
    }
  }
}