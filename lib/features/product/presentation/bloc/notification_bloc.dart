import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationBloc(this.getNotificationsUseCase)
      : super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await getNotificationsUseCase(cursor: null);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (page) => emit(NotificationLoaded(
        items: List.unmodifiable(page.items),
        nextCursor: page.nextCursor,
        unreadCount: page.unreadCount,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadMore(
    NotificationLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded || current.nextCursor == null) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await getNotificationsUseCase(cursor: current.nextCursor);
    result.fold(
      (failure) => emit(
          current.copyWith(isLoadingMore: false, loadMoreError: failure.message)),
      (page) => emit(NotificationLoaded(
        items: List.unmodifiable([...current.items, ...page.items]),
        nextCursor: page.nextCursor,
        unreadCount: page.unreadCount,
        isLoadingMore: false,
      )),
    );
  }
}
