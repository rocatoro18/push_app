part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  // CLEAN CODE: SI SE RECIBE MAS DE TRES ARGUMENTOS,
  // ES RECOMENDABLE HACE UN OBJETO, SI SON TRES O MENOS
  // PUEDE SER ARGUMENTO POSICIONAL
  NotificationStatusChanged(this.status);
}

// todo 2: notification received #PushMessage podemos recibir este argumento posicional o con nombre
class NotificationReceived extends NotificationsEvent {
  final PushMessage pushMessage;

  NotificationReceived(this.pushMessage);
}
