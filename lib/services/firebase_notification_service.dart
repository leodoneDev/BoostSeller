import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseNotificationService {
  static final msgService = FirebaseMessaging.instance;

  static initFCM() async {
    await Firebase.initializeApp();
    await msgService.requestPermission();
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    // Background (when user taps the notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    // Cold start
    RemoteMessage? initialMessage = await msgService.getInitialMessage();
    if (initialMessage != null) {}

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  }

  Future<String?> getDeviceToken() async {
    final token = await msgService.getToken();
    return token;
  }
}
