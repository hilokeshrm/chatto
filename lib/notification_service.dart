import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'chat_messages',
          channelName: 'Chat Messages',
          channelDescription: 'This channel is used for chat message notifications.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ],
      debug: true,
    );
  }

  static Future<void> requestPermissionIfNeeded() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> showNotification(String? title, String? body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'chat_messages',
        title: title ?? 'New Message',
        body: body ?? '',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
