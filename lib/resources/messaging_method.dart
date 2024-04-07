import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:instagram_clon/main.dart';
import 'package:instagram_clon/resources/firestore_method.dart';

import '../screens/sub_post_screen.dart';



Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("title: ${message.notification!.title}");
  MessagingMethod().handleMessage(message);
}

class MessagingMethod {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidNotificationChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => PostSearchScreen(
              postId: message.data['postId'],
              uid: message.data['uid'],
            )));
  }

  Future<void> initLocalNotification() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const setting = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      setting,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            if (notificationResponse.payload != null) {
              final message = RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
              handleMessage(message);
            }
            break;
          case NotificationResponseType.selectedNotificationAction:

            break;
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!;
    await platform.createNotificationChannel(_androidNotificationChannel);
  }

  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.instance.getInitialMessage().then((message) {
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if(notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidNotificationChannel.id,
            _androidNotificationChannel.name,
            channelDescription:  _androidNotificationChannel.description,
            icon: '@drawable/ic_launcher',

          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initNotifications() async {
    _firebaseMessaging.requestPermission();
    initPushNotification();
    initLocalNotification();
  }

  void uploadTokenToServer() {
    _firebaseMessaging.getToken().then((token) {
      FirestoreMethods().uploadTokenToServer(token!);
    });
  }

  void deleteTokenFromServer() {
    _firebaseMessaging.getToken().then((token) {
      FirestoreMethods().deleteTokenFromServer();
    });
  }
}
