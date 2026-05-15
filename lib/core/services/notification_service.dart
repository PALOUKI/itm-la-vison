import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/messages_repository.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:vision/core/services/local_storage_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

// Instance globale pour le background handler
final FlutterLocalNotificationsPlugin _bgLocalNotifications = FlutterLocalNotificationsPlugin();

// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('--- [BACKGROUND] MESSAGE RECEIVED ---');
  
  // Sur Android, si le payload contient un bloc 'notification', Firebase affiche la notif
  // automatiquement si le channel ID dans le manifest est correct.
  // Pour les messages 'data' uniquement, on pourrait ajouter une logique ici.
}

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    debugPrint('Initialisation du NotificationService...');
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final storage = _ref.read(localStorageServiceProvider);
    
    // 1. Demander la permission Firebase
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // 2. Demander la permission Android 13+ pour les bannières locales
      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      }

      // 3. Configurer les notifications locales
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon'); 
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );

      // Création du canal haute importance
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'vision_notifications_channel',
        'Alertes Scolaires',
        description: 'Notifications prioritaires pour le suivi des élèves.',
        importance: Importance.max,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Clic sur notification locale détecté');
          _handleNotificationClick(null, payload: details.payload);
        },
      );

      // 4. Écouteurs de messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App ouverte via notification FCM');
        _handleNotificationClick(message);
      });

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App démarrée via notification FCM');
        _handleNotificationClick(initialMessage);
      }

      // 5. Synchronisation du Token
      Future.delayed(const Duration(seconds: 5), () async {
        if (storage.isNotificationsEnabled()) {
          try {
            String? token = await _fcm.getToken();
            if (token != null) {
              debugPrint('FCM Token synchronisé : $token');
              await _sendTokenToBackend(token);
            }
          } catch (e) {
            debugPrint('Erreur synchronisation FCM Token: $e');
          }
        }
      });

      _fcm.onTokenRefresh.listen((token) {
        if (storage.isNotificationsEnabled()) {
          _sendTokenToBackend(token);
        }
      });
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('--- [FOREGROUND] MESSAGE RECEIVED ---');
    
    if (!isEnabled()) return;

    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    String title = notification?.title ?? data['title'] ?? data['subject'] ?? 'ITM LA VISION';
    String body = notification?.body ?? data['body'] ?? data['message'] ?? 'Nouvelle information scolaire.';

    // On utilise un ID stable pour éviter les doublons
    final int notificationId = (message.messageId ?? DateTime.now().toIso8601String()).hashCode.abs() % 100000;

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'vision_notifications_channel',
          'Alertes Scolaires',
          channelDescription: 'Notifications prioritaires pour le suivi des élèves.',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
    
    // Rafraîchir les compteurs
    _ref.invalidate(unreadNotificationsCountProvider);
    _ref.invalidate(notificationsListProvider(1));
  }

  void _handleNotificationClick(RemoteMessage? message, {String? payload}) {
    _ref.read(navigationProvider.notifier).goToTab(2);
  }

  Future<void> toggleNotifications(bool enable) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.setNotificationsEnabled(enable);
    if (enable) {
      await initialize();
      
      // Envoi d'une notification de test pour confirmer le bon fonctionnement
      await _localNotifications.show(
        id: 999,
        title: 'Notifications activées',
        body: 'Vous recevrez désormais les alertes de suivi en temps réel.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'vision_notifications_channel',
            'Alertes Scolaires',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );
    } else {
      await _sendTokenToBackend("");
    }
  }

  bool isEnabled() => _ref.read(localStorageServiceProvider).isNotificationsEnabled();

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final repo = _ref.read(messagesRepositoryProvider);
      await repo.updateFcmToken(token);
    } catch (e) {
      debugPrint('FCM Token sync error: $e');
    }
  }
}

// Providers
final notificationsListProvider = FutureProvider.family.autoDispose<NotificationsResponse, int>((ref, page) async {
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.getNotifications(page: page);
});

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(messagesRepositoryProvider);
  final response = await repo.getNotifications(page: 1);
  return response.unreadCount;
});

final childNotificationsCountProvider = Provider.family<int, int>((ref, studentId) {
  final notificationsState = ref.watch(notificationsListProvider(1));
  return notificationsState.maybeWhen(
    data: (response) {
      int count = 0;
      for (var notif in response.notifications) {
        if (!notif.isRead) {
          try {
            dynamic data = notif.data;
            if (data is String) data = jsonDecode(data);
            if (data is Map && (data['student_id']?.toString() == studentId.toString())) count++;
          } catch (e) {}
        }
      }
      return count;
    },
    orElse: () => 0,
  );
});

final childSectionNotificationProvider = Provider.family<int, ({int studentId, String type})>((ref, params) {
  final notificationsState = ref.watch(notificationsListProvider(1));
  return notificationsState.maybeWhen(
    data: (response) {
      int count = 0;
      for (var notif in response.notifications) {
        if (!notif.isRead && notif.type == params.type) {
          try {
            dynamic data = notif.data;
            if (data is String) data = jsonDecode(data);
            if (data is Map && (data['student_id']?.toString() == params.studentId.toString())) count++;
          } catch (e) {}
        }
      }
      return count;
    },
    orElse: () => 0,
  );
});
