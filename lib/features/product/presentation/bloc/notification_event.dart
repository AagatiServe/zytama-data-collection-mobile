part of 'notification_bloc.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

class NotificationLoadMoreRequested extends NotificationEvent {
  const NotificationLoadMoreRequested();
}
