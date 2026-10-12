import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../storage/hive_service.dart';
import '../../features/call/controllers/call_controller.dart';
import '../../features/chat/services/socket_service.dart';

const String kCallChannelId = 'call_channel';
const String kCallChannelName = 'Incoming Calls';
const String kCallChannelDesc = 'Channel for incoming audio and video calls';

const String kActionAccept = 'action_accept_call';
const String kActionDecline = 'action_decline_call';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Handling background notification response: ${response.actionId}");
  try {
    await HiveService.init();
  } catch (_) {}
  PushNotificationService.handleNotificationAction(response);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  final data = message.data;
  if (data['type'] == 'CALL_INCOMING') {
    await PushNotificationService.showCallNotification(
      title: data['callType'] == 'audio'
          ? 'Incoming Audio Call'
          : 'Incoming Video Call',
      body: '${data['callerName'] ?? 'Someone'} is calling you...',
      payload: jsonEncode(data),
    );
  }
}

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationAction(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Call Notification Channel (High Importance, Max Priority)
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      kCallChannelId,
      kCallChannelName,
      description: kCallChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(callChannel);
    await androidPlugin?.createNotificationChannel(defaultChannel);

    // Foreground messages handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      if (data['type'] == 'CALL_INCOMING') {
        _dispatchIncomingCall(data);
        return;
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              defaultChannel.id,
              defaultChannel.name,
              channelDescription: defaultChannel.description,
              icon: '@mipmap/ic_launcher',
              priority: Priority.high,
              importance: Importance.max,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(data),
        );
      }
    });

    // When notification is clicked from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'CALL_INCOMING') {
        _dispatchIncomingCall(message.data);
      }
    });

    // Check if app was opened from terminated/killed state via notification
    _checkInitialMessage();
  }

  /// Show incoming call notification with Accept and Decline actions
  static Future<void> showCallNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      kCallChannelId,
      kCallChannelName,
      channelDescription: kCallChannelDesc,
      icon: '@mipmap/ic_launcher',
      priority: Priority.max,
      importance: Importance.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      autoCancel: false,
      ongoing: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          kActionDecline,
          'Decline',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          kActionAccept,
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _localNotificationsPlugin.show(
      id: 9999, // Dedicated call notification ID
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  static Future<void> cancelCallNotification() async {
    await _localNotificationsPlugin.cancel(id: 9999);
  }

  static Future<void> _checkInitialMessage() async {
    // 1. Check if launched from Firebase direct notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.data['type'] == 'CALL_INCOMING') {
      debugPrint('📞 [PushNotificationService] App launched from Firebase getInitialMessage');
      Future.delayed(const Duration(milliseconds: 600), () {
        _dispatchIncomingCall(initialMessage.data);
      });
      return;
    }

    // 2. Check if launched from local notification action (Accept/Decline/Tap)
    final launchDetails =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      debugPrint('📞 [PushNotificationService] App launched from LocalNotification response: ${launchDetails.notificationResponse?.actionId}');
      Future.delayed(const Duration(milliseconds: 600), () {
        handleNotificationAction(launchDetails.notificationResponse!);
      });
    }
  }

  static void handleNotificationAction(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);
      if (data is! Map<String, dynamic> || data['type'] != 'CALL_INCOMING') {
        return;
      }

      cancelCallNotification();

      if (response.actionId == kActionDecline) {
        debugPrint('📞 ❌ Notification Action: Decline Call for caller: ${data['callerId']}');
        SocketService.initSocket();
        SocketService.emit('reject_call', {
          'callerId': data['callerId'],
          'reason': 'Call declined from notification',
        });
        if (Get.isRegistered<CallController>()) {
          Get.find<CallController>().rejectCall(
            reason: 'Call declined from notification',
          );
        }
      } else if (response.actionId == kActionAccept) {
        debugPrint('📞 🟢 Notification Action: Accept Call for caller: ${data['callerId']}');
        _dispatchIncomingCall(data);
        // Wait for app state, root navigator, and controllers to mount
        Future.delayed(const Duration(milliseconds: 700), () {
          if (Get.isRegistered<CallController>()) {
            debugPrint('📞 [PushNotificationService] Triggering CallController.acceptCall()...');
            Get.find<CallController>().acceptCall();
          } else {
            debugPrint('⚠️ [PushNotificationService] CallController is not yet registered!');
          }
        });
      } else {
        // Tapped on the notification body directly
        debugPrint('📞 👆 Notification Body Tapped for caller: ${data['callerId']}');
        _dispatchIncomingCall(data);
      }
    } catch (e, st) {
      debugPrint('Error handling notification response: $e\n$st');
    }
  }

  static void _dispatchIncomingCall(Map<String, dynamic> data) {
    try {
      SocketService.initSocket();

      dynamic parsedOffer = data['offer'];
      if (parsedOffer is String && parsedOffer.isNotEmpty) {
        try {
          parsedOffer = jsonDecode(parsedOffer);
        } catch (_) {}
      }

      final callPayload = {
        'callerId': data['callerId'],
        'callerName': data['callerName'],
        'callerAvatar': data['callerAvatar'],
        'callType': data['callType'],
        'offer': parsedOffer,
      };

      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().handleIncomingCallPayload(callPayload);
      }
    } catch (e) {
      debugPrint('Error handling incoming call push: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('================ FCM TOKEN ================');
      debugPrint(token);
      debugPrint('===========================================');
      return token;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
}
