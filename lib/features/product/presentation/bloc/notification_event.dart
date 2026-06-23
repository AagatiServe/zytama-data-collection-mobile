part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

class NotificationLoadMoreRequested extends NotificationEvent {
  const NotificationLoadMoreRequested();
}
