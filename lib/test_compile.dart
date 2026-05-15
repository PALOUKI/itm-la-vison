import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  _localNotifications.show(
    id: 1,
    title: 'Test',
    body: 'Test',
    notificationDetails: null,
  );
}
