import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared/shared.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  logger.warning("Handling a background message: ${message.messageId}");
  // logger.warning('Message data: ${message.data}');
  // logger.warning('Message notification: ${message.notification?.title}');
  // logger.warning('Message notification: ${message.notification?.body}');
}
