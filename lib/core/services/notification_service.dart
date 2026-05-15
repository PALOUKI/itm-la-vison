import 'dart:convert';
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

// Handler pour les messages en arrière-plan (doit être une fonction globale)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 1. Initialiser Firebase
  await Firebase.initializeApp();
  
  debugPrint('--- [BACKGROUND] MESSAGE RECEIVED ---');
  
  // 2. Préparer le contenu
  final notification = message.notification;
  final data = message.data;

  // On essaie de trouver un titre et un corps dans les données si le bloc notification est vide
  String title = notification?.title ?? data['title'] ?? data['subject'] ?? 'ITM LA VISION';
  String body = notification?.body ?? data['body'] ?? data['message'] ?? 'Nouvelle mise à jour disponible.';

  // 3. Configuration pour le background
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'Notifications Importantes',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
    playSound: true,
    enableVibration: true,
    showWhen: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
  );

  // 4. Afficher avec un ID stable
  final int id = (message.messageId ?? DateTime.now().toIso8601String()).hashCode.abs() % 100000;
  await _bgLocalNotifications.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: platformDetails,
    payload: jsonEncode(data),
  );
}

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    debugPrint('Initialisation du NotificationService...');
    
    // Configurer le background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final storage = _ref.read(localStorageServiceProvider);
    
    // 1. Demander la permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permission notifications : ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // 2. Configurer les notifications locales
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );

      // Créer le canal Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notifications Importantes',
        description: 'Ce canal est utilisé pour les notifications scolaires cruciales.',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          _handleNotificationClick(null, payload: details.payload);
        },
      );

      // 3. Écouter les messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

      // 4. Gérer le Token FCM (Seulement si l'utilisateur est activé dans ses réglages)
      if (storage.isNotificationsEnabled()) {
        String? token = await _fcm.getToken();
        if (token != null) {
          debugPrint('FCM Token synchronisé : $token');
          await _sendTokenToBackend(token);
        }
      }

      _fcm.onTokenRefresh.listen((token) {
        if (storage.isNotificationsEnabled()) {
          _sendTokenToBackend(token);
        }
      });
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('--- [FOREGROUND] MESSAGE RECEIVED ---');
    
    if (!isEnabled()) {
      debugPrint('Notifications désactivées dans les réglages, ignore le message.');
      return;
    }

    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    String title = notification?.title ?? data['title'] ?? data['subject'] ?? 'ITM LA VISION';
    String body = notification?.body ?? data['body'] ?? data['message'] ?? 'Nouvelle information scolaire.';

    final int id = (message.messageId ?? DateTime.now().toIso8601String()).hashCode.abs() % 100000;
    
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Notifications Importantes',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
    
    // ATTENTION : On attend un peu que le serveur finisse d'écrire en DB
    // avant de rafraîchir la liste, sinon on va fetch l'ancienne liste.
    debugPrint('Attente avant rafraîchissement des données...');
    await Future.delayed(const Duration(seconds: 2));
    
    debugPrint('Rafraîchissement des providers...');
    _ref.invalidate(unreadNotificationsCountProvider);
    _ref.invalidate(notificationsListProvider(1));
  }

  Future<void> toggleNotifications(bool enable) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.setNotificationsEnabled(enable);

    if (enable) {
      await initialize();
      
      await _localNotifications.show(
        id: 999,
        title: 'Notifications activées',
        body: 'Vous recevrez désormais les alertes de suivi en temps réel concernant vos enfants.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Notifications Importantes',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            playSound: true,
          ),
        ),
      );
    } else {
      await _sendTokenToBackend("");
    }
  }

  bool isEnabled() => _ref.read(localStorageServiceProvider).isNotificationsEnabled();

  void _handleNotificationClick(RemoteMessage? message, {String? payload}) {
    _ref.read(navigationProvider.notifier).goToTab(2);
  }

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
