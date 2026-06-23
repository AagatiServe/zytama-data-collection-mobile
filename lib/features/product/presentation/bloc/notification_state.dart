part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationItemModel> items;
  final String? nextCursor;
  final int unreadCount;
  final bool isLoadingMore;
  final String? loadMoreError;

  const NotificationLoaded({
    required this.items,
    required this.nextCursor,
    required this.unreadCount,
    required this.isLoadingMore,
    this.loadMoreError,
  });

  NotificationLoaded copyWith({
    List<NotificationItemModel>? items,
    String? nextCursor,
    int? unreadCount,
    bool? isLoadingMore,
    String? loadMoreError,
  }) {
    return NotificationLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props =>
      [items, nextCursor, unreadCount, isLoadingMore, loadMoreError];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
