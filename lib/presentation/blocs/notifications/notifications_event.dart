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
