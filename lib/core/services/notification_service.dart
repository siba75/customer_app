import 'dart:async';

import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/dio/notifications_api.dart';
import 'package:customer_app/pages/notifications_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showBackgroundMessage(message);
}

class NotificationService {
  NotificationService._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _api = NotificationsApi();
  static socket_io.Socket? _socket;
  static _NotificationLifecycleObserver? _lifecycleObserver;
  static Timer? _inboxPollingTimer;
  static final Set<String> _seenInboxNotificationIds = {};
  static bool _inboxPollingSeeded = false;
  static bool _localNotificationsReady = false;

  static const _androidChannel = AndroidNotificationChannel(
    'customer_app_notifications',
    'إشعارات المتجر',
    description: 'تنبيهات الطلبات والعروض وتحديثات الحساب',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (!_isAndroid) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _initializeLocalNotifications();
      await _requestPermission();
      _registerLifecycleObserver();
      await prepareForSignedInUser();

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        unawaited(_sendTokenToBackend(token));
      });

      FirebaseMessaging.onMessage.listen(_showRemoteMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_openNotificationsScreen);

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openNotificationsScreen(initialMessage);
        });
      }
    } catch (_) {
      // Notification setup should never block the main customer experience.
    }
  }

  static Future<void> registerDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }
      await SecureStorage.write('fcm_token', token);
      await _sendTokenToBackend(token);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to get/register FCM token: $error');
      }
      // FCM can fail on devices without Google Play Services or while offline.
    }
  }

  static Future<void> prepareForSignedInUser() async {
    await connectSocketNotifications();
    await startInboxFallbackPolling();
  }

  static Future<void> connectSocketNotifications() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);
    if (token == null || token.isEmpty) return;

    final currentSocket = _socket;
    if (currentSocket?.connected ?? false) return;

    currentSocket?.dispose();

    final socket = socket_io.io(
      ApiConfig.notificationsSocketUrl,
      socket_io.OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1500)
          .build(),
    );

    _socket = socket;

    socket.onConnect((_) {
      if (kDebugMode) {
        debugPrint(
          'Socket notifications connected: ${ApiConfig.notificationsSocketUrl}',
        );
      }
      socket.emitWithAck(
        'login',
        token,
        ack: (data) {
          if (kDebugMode) {
            debugPrint('Socket notifications login response: $data');
          }
        },
      );
    });

    socket.on('recieve-message', _showSocketNotification);
    socket.on('receive-message', _showSocketNotification);

    socket.onDisconnect((reason) {
      if (kDebugMode) {
        debugPrint('Socket notifications disconnected: $reason');
      }
    });

    socket.onConnectError((error) {
      if (kDebugMode) {
        debugPrint('Socket notifications connection error: $error');
      }
    });

    socket.onError((error) {
      if (kDebugMode) {
        debugPrint('Socket notifications error: $error');
      }
    });

    socket.connect();
  }

  static void disconnectSocketNotifications() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _inboxPollingTimer?.cancel();
    _inboxPollingTimer = null;
    _seenInboxNotificationIds.clear();
    _inboxPollingSeeded = false;
  }

  static void _registerLifecycleObserver() {
    if (_lifecycleObserver != null) return;

    _lifecycleObserver = _NotificationLifecycleObserver();
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  static Future<void> startInboxFallbackPolling() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);
    if (token == null || token.isEmpty) return;

    await _pollUnreadInbox(showNewNotifications: _inboxPollingSeeded);
    _inboxPollingSeeded = true;

    _inboxPollingTimer ??= Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(_pollUnreadInbox(showNewNotifications: true));
    });
  }

  static Future<void> _pollUnreadInbox({
    required bool showNewNotifications,
  }) async {
    try {
      final page = await _api.getMyNotifications(
        limit: 10,
        offset: 0,
        unreadOnly: true,
      );

      for (final notification in page.notifications.reversed) {
        final wasSeen = !_seenInboxNotificationIds.add(notification.id);
        if (wasSeen || !showNewNotifications) continue;

        await _showLocalNotification(
          title: notification.title,
          body: notification.message,
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Inbox notification polling failed: $error');
      }
    }
  }

  static Future<void> showBackgroundMessage(RemoteMessage message) async {
    if (!_isAndroid) return;

    // Android shows notification payloads automatically in background. If the
    // backend sends a data-only message, we display it locally.
    if (message.notification != null) return;

    try {
      await _initializeLocalNotifications();
      await _showRemoteMessage(message);
    } catch (_) {
      // Background notification display is best-effort.
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsReady) return;

    const androidSettings = AndroidInitializationSettings('ic_notification');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (_) => _openNotificationsScreen(null),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _localNotificationsReady = true;
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('FCM permission status: ${settings.authorizationStatus}');
    }

    if (_isAndroid) {
      final granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      if (kDebugMode) {
        debugPrint('Android local notification permission granted: $granted');
      }
    }
  }

  static Future<void> _subscribeToTopics() async {
    try {
      const topics = ['all', 'ALL', 'customer', 'customers', 'CUSTOMER'];

      for (final topic in topics) {
        await _messaging.subscribeToTopic(topic);
        if (kDebugMode) {
          debugPrint('Subscribed to FCM topic: $topic');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to subscribe to FCM topics: $error');
      }
      // Topic subscription requires network access and Google Play Services.
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    final authToken = await SecureStorage.read(SecureStorage.authTokenKey);
    if (authToken == null || authToken.isEmpty) return;

    try {
      await _api.registerDeviceToken(token: token);
      if (kDebugMode) {
        debugPrint('FCM token registered with backend.');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to register FCM token with backend: $error');
      }
      // The backend endpoint may not exist yet. Push display still works once
      // the backend stores and sends to this FCM token.
    }
  }

  static Future<void> _showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    await _showLocalNotification(title: title, body: body);
  }

  static void _showSocketNotification(dynamic data) {
    if (kDebugMode) {
      debugPrint('Socket notification received: $data');
    }

    final map = data is Map ? data : const {};
    final title = map['title']?.toString();
    final body =
        map['message']?.toString() ??
        map['body']?.toString() ??
        map['description']?.toString();

    unawaited(_showLocalNotification(title: title, body: body));
  }

  static Future<void> _showLocalNotification({
    required String? title,
    required String? body,
  }) async {
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _initializeLocalNotifications();
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title ?? 'إشعار جديد',
      body: body ?? 'لديك تحديث جديد.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          color: const Color(0xFF4F46E5),
        ),
      ),
    );
  }

  static void _openNotificationsScreen(RemoteMessage? _) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  static bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
}

class _NotificationLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationService.connectSocketNotifications());
      unawaited(NotificationService.startInboxFallbackPolling());
    }
  }
}
