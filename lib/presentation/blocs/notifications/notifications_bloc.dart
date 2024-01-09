import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  // INSTANCIA DE FIREBASE MESSAGING
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationsBloc() : super(const NotificationsState()) {
    //on<NotificationsEvent>((event, emit) {
    //  // TODO: implement event handler
    //});
    // EVENTO
    on<NotificationStatusChanged>(_notificationStatusChanged);

    // todo 3: Crear el listener # _onPushMessageReceived
    on<NotificationReceived>(_notificationPushMessage);
    // VERIFICAR ESTADO DE LAS NOTIFICACIONES
    _initialStatusCheck();
    // LISTENER PARA NOTIFICACIONES EN FOREGROUND
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  void _notificationStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(
        // EL NUEVO STATUS VA A SER LO QUE VIENE EN EL EVENTO
        status: event.status));
    //_getFCMToken();
  }

  void _notificationPushMessage(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(state
        // SPREAD DE NOTIFICATIONS PARA CREAR EL NUEVO ESTADO CON LA NUEVA NOTIFICACION
        .copyWith(notifications: [event.pushMessage, ...state.notifications]));
  }

  void _initialStatusCheck() async {
    // CON ESTE SETTINGS YO PUEDE SABER EL ESTADO ACTUAL
    final settings = await messaging.getNotificationSettings();
    // MANDAMOS EL EVENTO
    add(NotificationStatusChanged(settings.authorizationStatus));
    //print('ñaaak');
    _getFCMToken();
  }

  void _getFCMToken() async {
    // ESTO SOLO ES PARA SABER EL ESTADO
    //final settings = await messaging.getNotificationSettings();
    //if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print('token $token');
  }

  void handleRemoteMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification == null) return;
    print('Message also contained a notification: ${message.notification}');

    final notification = PushMessage(
        // SE UTILIZA EL REPLACE ALL, PORQUE ESOS DOS PUNTOS PUEDEN ROMPER MI SISTEMA DE GO ROUTER
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sendDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

    print(notification);

    // todo: add de un nuevo evento
    // DISPARAR EVENTO
    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // SOLICITAR PERMISO A LOCAL NOTIFICATIONS
    await requestPermissionLocalNotifications();
    // MANDAMOS EL EVENTO
    add(NotificationStatusChanged(settings.authorizationStatus));
    _getFCMToken();
  }

  PushMessage? getMessageById(String pushMessageId) {
    // (.any()) regresa cualquier elemento que cumpla esta condicion
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);

    if (!exist) return null;
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}
