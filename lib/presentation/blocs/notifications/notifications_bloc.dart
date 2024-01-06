import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  // INSTANCIA DE FIREBASE MESSAGING
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationsBloc() : super(const NotificationsState()) {
    //on<NotificationsEvent>((event, emit) {
    //  // TODO: implement event handler
    //});
    // EVENTO
    on<NotificationStatusChanged>(_notificationStatusChanged);
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

  void _handleRemoteMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification == null) return;
    print('Message also contained a notification: ${message.notification}');
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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
    // MANDAMOS EL EVENTO
    add(NotificationStatusChanged(settings.authorizationStatus));
    _getFCMToken();
  }
}
