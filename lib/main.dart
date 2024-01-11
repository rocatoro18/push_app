import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTIFICACIONES CUANDO LA APP ESTA TERMINADA
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // ASEGURA TENER CONFIGURADA APLICACION DE FIREBASE
  await NotificationsBloc.initializeFCM();
  // INICIALIZAR LOCAL NOTIFICATIONS
  await LocalNotifications.initializeLocalNotifications();

  runApp(MultiBlocProvider(
      // CASO DE USO PARA PEDIR USAR EL LOCALNOTIFICATIONS
      providers: [
        BlocProvider(
            create: (_) => NotificationsBloc(
                requestLocalNotificationPermissions:
                    LocalNotifications.requestPermissionLocalNotifications,
                showLocalNotification:
                    LocalNotifications.showLocalNotification))
      ],
      child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      /*
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
      */
      builder: (context, child) =>
          HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() =>
      _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState
    extends State<HandleNotificationInteractions> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // ABRIR LA NOTIFICACION DIRECTAMENTE ESTANDO FUERA DE LA APP
  void _handleMessage(RemoteMessage message) {
    // ALMACENAR NOTIFICACION EN EL BLOC,
    // EN ESTE MOMENTO DE LA APLICACION YA
    // SE INICIO LA INSTANCIA DE LA APLICACION

    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId =
        message.messageId?.replaceAll(':', '').replaceAll('%', '');

    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
