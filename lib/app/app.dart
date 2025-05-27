import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../features/auth/pages/login_page.dart';
import '../navigation/bottom_nav.dart';
import '../notification_service.dart';

/// Global notifier to control the theme
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Request permission for Firebase Messaging
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and save FCM token
    final user = FirebaseAuth.instance.currentUser;
    final token = await _messaging.getToken();
    if (user != null && token != null) {
      await FirebaseAuth.instance.currentUser?.reload();
      // Optionally save token to Firestore:
      // FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': token});
    }

    // Initialize local notifications and request permissions
    await NotificationService.initialize();
    await NotificationService.requestPermissionIfNeeded();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        NotificationService.showNotification(notification.title, notification.body);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Team Chat',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) {
                return const BottomNavScreen();
              } else {
                return const LoginPage();
              }
            },
          ),
        );
      },
    );
  }
}
